//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import AVKit
import StreamChat
import UIKit

/// A protocol the video preview uploader implementation must conform to.
public protocol VideoPreviewLoader: AnyObject {
    /// Loads a preview for the video at given URL.
    /// - Parameters:
    ///   - url: A video URL.
    ///   - completion: A completion that is called when a preview is loaded. Must be invoked on main queue.
    func loadPreviewForVideo(at url: URL, completion: @escaping @MainActor(Result<UIImage, Error>) -> Void)
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

    public func loadPreviewForVideo(at url: URL, completion: @escaping @MainActor(Result<UIImage, Error>) -> Void) {
        if let cached = cache[url] {
            Task { @MainActor in
                completion(.success(cached))
            }
            return
        }

        utils.fileCDN.adjustedURL(for: url) { [cache] result in

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
                } else if let error = error {
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
