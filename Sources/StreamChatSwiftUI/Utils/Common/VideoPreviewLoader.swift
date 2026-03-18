//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import AVKit
import StreamChat
import UIKit

/// A protocol the video preview uploader implementation must conform to.
@MainActor public protocol VideoPreviewLoader: AnyObject {
    /// Loads a preview for a local video attachment at a given URL.
    /// - Parameters:
    ///   - url: The video URL.
    ///   - completion: A completion that is called when a preview is loaded. Must be invoked on main queue.
    func loadPreviewForVideo(at url: URL, completion: @escaping @MainActor (Result<UIImage, Error>) -> Void)

    /// Loads a preview for the given remote video attachment.
    ///
    /// The default implementation calls ``loadPreviewForVideo(at:completion:)`` with the video URL.
    /// Override this method to use the attachment's thumbnail URL or other metadata for preview generation.
    /// - Parameters:
    ///   - attachment: A video attachment containing the video URL and optional thumbnail URL.
    ///   - completion: A completion that is called when a preview is loaded. Must be invoked on main queue.
    func loadPreviewForVideo(
        with attachment: ChatMessageVideoAttachment,
        completion: @escaping (Result<UIImage, Error>) -> Void
    )
}

extension VideoPreviewLoader {
    public func loadPreviewForVideo(
        with attachment: ChatMessageVideoAttachment,
        completion: @Sendable @escaping (Result<UIImage, Error>) -> Void
    ) {
        loadPreviewForVideo(at: attachment.videoURL, completion: completion)
    }
}

/// The `VideoPreviewLoader` implemenation used by default.
public final class DefaultVideoPreviewLoader: VideoPreviewLoader {
    @Injected(\.utils) var utils

    private let cache: Cache<URL, UIImage>

    public init(countLimit: Int = 50) {
        cache = .init(countLimit: countLimit)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning(_:)),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public func loadPreviewForVideo(at url: URL, completion: @escaping @MainActor (Result<UIImage, Error>) -> Void) {
        if let cached = cache[url] {
            Task { @MainActor in
                completion(.success(cached))
            }
            return
        }

        generateVideoPreview(for: url, completion: completion)
    }

    public func loadPreviewForVideo(
        with attachment: ChatMessageVideoAttachment,
        completion: @escaping (Result<UIImage, Error>) -> Void
    ) {
        let videoURL = attachment.videoURL
        if let cached = cache[videoURL] {
            return call(completion, with: .success(cached))
        }

        if let thumbnailURL = attachment.payload.thumbnailURL {
            utils.imageLoader.loadImage(
                url: thumbnailURL,
                imageCDN: utils.imageCDN,
                resize: false,
                preferredSize: nil
            ) { [weak self] result in
                guard let self else { return }
                switch result {
                case let .success(image):
                    self.cache[videoURL] = image
                    self.call(completion, with: .success(image))
                case .failure:
                    self.generateVideoPreview(for: videoURL, completion: completion)
                }
            }
        } else {
            generateVideoPreview(for: videoURL, completion: completion)
        }
    }

    private func generateVideoPreview(for url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
        utils.fileCDN.adjustedURL(for: url) { result in
            let adjustedUrl: URL
            switch result {
            case let .success(url):
                adjustedUrl = url
            case let .failure(error):
                Task { @MainActor in
                    completion(.failure(error))
                }
                return
            }

            let asset = AVURLAsset(url: adjustedUrl)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            let frameTime = CMTime(seconds: 0.1, preferredTimescale: 600)

            imageGenerator.appliesPreferredTrackTransform = true
            imageGenerator.generateCGImagesAsynchronously(forTimes: [.init(time: frameTime)]) { [cache] _, image, _, _, error in
                let result: Result<UIImage, Error>
                if let thumbnail = image {
                    result = .success(.init(cgImage: thumbnail))
                } else if let error {
                    result = .failure(error)
                } else {
                    log.error("Both error and image are `nil`.")
                    return
                }

                cache[url] = try? result.get()
                Task { @MainActor in
                    completion(result)
                }
            }
        }
    }

    @objc private func handleMemoryWarning(_ notification: NSNotification) {
        cache.removeAllObjects()
    }
}
