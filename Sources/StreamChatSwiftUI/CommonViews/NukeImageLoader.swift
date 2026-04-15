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
    /// Checks Nuke's memory cache (using the ``CDNRequest/cachingKey``) after
    /// CDN transformation. If the image is already cached, it returns
    /// immediately without a network request. Otherwise, calls `onCacheMiss`
    /// (so callers can show a loading state) and fetches from the network.
    ///
    /// Uses Nuke's async `ImageTask.response` which propagates Swift
    /// concurrency cancellation to the underlying download automatically.
    @MainActor
    static func loadImage(
        url: URL,
        resize: ImageResize?,
        cdnRequester: CDNRequester,
        onCacheMiss: @MainActor () -> Void = {}
    ) async throws -> StreamAsyncImageResult {
        let cdnResize = resize.map {
            CDNImageResize(width: $0.width, height: $0.height, resizeMode: $0.mode.value, crop: $0.mode.cropValue)
        }
        let cdnRequest = try await cdnRequester.imageRequest(for: url, options: .init(resize: cdnResize))

        let processors = makeProcessors(resize: resize)
        let userInfo = cdnRequest.cachingKey.map { [ImageRequest.UserInfoKey.imageIdKey: $0 as Any] }

        let cacheRequest = ImageRequest(
            url: cdnRequest.url,
            processors: processors,
            userInfo: userInfo
        )

        if let container = ImagePipeline.shared.cache[cacheRequest] {
            return StreamAsyncImageResult(
                image: container.image,
                isAnimated: container.type == .gif,
                animatedImageData: container.data
            )
        }

        onCacheMiss()

        var urlRequest = URLRequest(url: cdnRequest.url)
        if let headers = cdnRequest.headers {
            for (key, value) in headers {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }

        let networkRequest = ImageRequest(
            urlRequest: urlRequest,
            processors: processors,
            userInfo: userInfo
        )

        let task = ImagePipeline.shared.imageTask(with: networkRequest)
        let response = try await task.response
        return StreamAsyncImageResult(
            image: response.image,
            isAnimated: response.container.type == .gif,
            animatedImageData: response.container.data
        )
    }

    // MARK: - Private

    private static func makeProcessors(resize: ImageResize?) -> [any ImageProcessing] {
        guard let resize else { return [] }
        let size = CGSize(width: resize.width, height: resize.height)
        guard size != .zero else { return [] }
        return [ImageProcessors.Resize(size: size)]
    }
}
