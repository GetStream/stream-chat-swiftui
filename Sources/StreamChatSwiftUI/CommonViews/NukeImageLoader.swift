//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import UIKit

/// Internal helper that bridges the vendored Nuke pipeline with CDN requester
/// transformations. Isolates all Nuke-specific code so views remain agnostic
/// of the underlying image loading library.
enum NukeImageLoader {
    /// Loads an image from the given URL, applying CDN transformations and
    /// optional resize processing.
    ///
    /// Uses Nuke's async `ImageTask.response` which propagates Swift
    /// concurrency cancellation to the underlying download automatically.
    @MainActor
    static func loadImage(
        url: URL,
        resize: ImageResize?,
        cdnRequester: CDNRequester
    ) async throws -> StreamAsyncImageResult {
        let cdnResize = resize.map {
            CDNImageResize(width: $0.width, height: $0.height, resizeMode: $0.mode.value, crop: $0.mode.cropValue)
        }
        let cdnRequest = try await cdnRequester.imageRequest(for: url, options: .init(resize: cdnResize))

        var urlRequest = URLRequest(url: cdnRequest.url)
        if let headers = cdnRequest.headers {
            for (key, value) in headers {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }

        var processors = [ImageProcessing]()
        if let resize {
            let size = CGSize(width: resize.width, height: resize.height)
            if size != .zero {
                processors.append(ImageProcessors.Resize(size: size))
            }
        }

        let request = ImageRequest(
            urlRequest: urlRequest,
            processors: processors,
            userInfo: cdnRequest.cachingKey.map { [ImageRequest.UserInfoKey.imageIdKey: $0 as Any] }
        )

        let task = ImagePipeline.shared.imageTask(with: request)
        let response = try await task.response
        return StreamAsyncImageResult(
            image: response.image,
            isAnimated: response.container.type == .gif,
            animatedImageData: response.container.data
        )
    }
}
