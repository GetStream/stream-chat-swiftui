//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChatCommonUI
import UIKit

/// Nuke-backed implementation of ``ImageDownloading`` for the SwiftUI SDK.
public final class StreamImageDownloader: ImageDownloading, Sendable {
    public init() {}

    public func downloadImage(
        url: URL,
        options: ImageDownloadingOptions,
        completion: @escaping @MainActor (Result<DownloadedImage, Error>) -> Void
    ) {
        var urlRequest = URLRequest(url: url)
        if let headers = options.headers {
            for (key, value) in headers {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }

        var processors = [ImageProcessing]()
        if let resize = options.resize, resize != .zero {
            processors.append(ImageProcessors.Resize(size: resize))
        }

        let request = ImageRequest(
            urlRequest: urlRequest,
            processors: processors,
            userInfo: options.cachingKey.map { [.imageIdKey: $0] }
        )

        Self.pipeline.loadImage(with: request) { result in
            Task { @MainActor in
                switch result {
                case let .success(imageResponse):
                    completion(.success(DownloadedImage(
                        image: imageResponse.image,
                        animatedImageData: imageResponse.container.type == .gif ? imageResponse.container.data : nil
                    )))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        }
    }
}

// MARK: - Image Pipeline

extension StreamImageDownloader {
    /// The Nuke pipeline backing all image loading in the SwiftUI SDK.
    ///
    /// The stock pipeline only persists the *original* downloaded data to an HTTP
    /// `URLCache`, so processed images live solely in the cost-limited in-memory
    /// cache. When scrolling a long channel list, the memory cache evicts resized
    /// avatars and every reappearance re-decodes and re-resizes them on the CPU
    /// (the `byResizing` / `UIImage.draw` hot path).
    ///
    /// This pipeline instead uses an aggressive on-disk ``DataCache`` together
    /// with the ``ImagePipeline/DataCachePolicy/automatic`` policy, which stores
    /// the *processed* (resized) image for any request that carries a resize
    /// processor. Subsequent loads decode the already-resized thumbnail straight
    /// from disk instead of downscaling the full-size source again. The
    /// processing and decompression queues are also widened so bursts of avatar
    /// loads during fast scrolling can use more cores.
    static let pipeline: ImagePipeline = {
        var configuration = ImagePipeline.Configuration.withDataCache(
            name: "com.getstream.StreamChatSwiftUI.imageCache"
        )
        configuration.dataCachePolicy = .automatic
        configuration.imageProcessingQueue = OperationQueue(maxConcurrentCount: 4)
        configuration.imageDecompressingQueue = OperationQueue(maxConcurrentCount: 4)
        return ImagePipeline(configuration: configuration)
    }()
}
