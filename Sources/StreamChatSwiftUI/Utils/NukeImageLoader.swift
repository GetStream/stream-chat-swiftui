//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import StreamChat
import UIKit

/// The class which is resposible for loading images from URLs.
/// Internally uses `Nuke`'s shared object of `ImagePipeline` to load the image.
open class NukeImageLoader: ImageLoading {
    
    public init() {
        // Public init.
    }

    open func loadImage(
        using urlRequest: URLRequest,
        cachingKey: String?,
        completion: @escaping ((Result<UIImage, Error>) -> Void)
    ) {
        var userInfo: [ImageRequest.UserInfoKey: Any]?
        if let cachingKey = cachingKey {
            userInfo = [.imageIdKey: cachingKey]
        }

        let request = ImageRequest(
            urlRequest: urlRequest,
            userInfo: userInfo
        )

        ImagePipeline.shared.loadImage(with: request) { result in
            switch result {
            case let .success(imageResponse):
                completion(.success(imageResponse.image))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    open func loadImages(
        from urls: [URL],
        placeholders: [UIImage],
        loadThumbnails: Bool,
        thumbnailSize: CGSize,
        imageCDN: ImageCDN,
        completion: @escaping (([UIImage]) -> Void)
    ) {
        let group = DispatchGroup()
        var images: [UIImage] = []

        for avatarUrl in urls {
            var placeholderIndex = 0

            let thumbnailUrl = imageCDN.thumbnailURL(originalURL: avatarUrl, preferredSize: .avatarThumbnailSize)
            var imageRequest = imageCDN.urlRequest(forImage: thumbnailUrl)
            imageRequest.timeoutInterval = 8
            let cachingKey = imageCDN.cachingKey(forImage: avatarUrl)

            group.enter()

            loadImage(using: imageRequest, cachingKey: cachingKey) { result in
                switch result {
                case let .success(image):
                    images.append(image)
                case .failure:
                    if !placeholders.isEmpty {
                        // Rotationally use the placeholders
                        images.append(placeholders[placeholderIndex])
                        placeholderIndex += 1
                        if placeholderIndex == placeholders.count {
                            placeholderIndex = 0
                        }
                    }
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(images)
        }
    }

    open func loadImage(
        url: URL?,
        imageCDN: ImageCDN,
        resize: Bool = true,
        preferredSize: CGSize? = nil,
        completion: @escaping ((Result<UIImage, Error>) -> Void)
    ) {
        guard var url = url else {
            completion(.failure(ClientError.Unknown()))
            return
        }

        let urlRequest = imageCDN.urlRequest(forImage: url)

        var processors = [ImageProcessing]()
        if let preferredSize = preferredSize, resize == true {
            processors = [ImageProcessors.LateResize(sizeProvider: {
                preferredSize
            })]
        }

        let size = preferredSize ?? .zero
        if resize && size != .zero {
            url = imageCDN.thumbnailURL(originalURL: url, preferredSize: size)
        }

        let cachingKey = imageCDN.cachingKey(forImage: url)

        let request = ImageRequest(
            urlRequest: urlRequest,
            processors: processors,
            userInfo: [.imageIdKey: cachingKey]
        )

        ImagePipeline.shared.loadImage(with: request) { result in
            switch result {
            case let .success(imageResponse):
                completion(.success(imageResponse.image))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

private extension UIImageView {
    static var nukeLoadingTaskKey: UInt8 = 0

    var currentImageLoadingTask: ImageTask? {
        get { objc_getAssociatedObject(self, &Self.nukeLoadingTaskKey) as? ImageTask }
        set { objc_setAssociatedObject(self, &Self.nukeLoadingTaskKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
}
