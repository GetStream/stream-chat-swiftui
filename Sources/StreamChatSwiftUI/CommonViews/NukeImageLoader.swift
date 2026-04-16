//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import UIKit

/// Internal helper that bridges the vendored Nuke pipeline with CDN requester
/// transformations. Isolates all Nuke-specific code so views remain agnostic
/// of the underlying image loading library.
enum NukeImageLoader {
    // MARK: - Synchronous Cache Lookup

    /// Synchronous lookup that queries Nuke's memory cache using a previously
    /// stored ``CDNRequest/cachingKey``.
    ///
    /// After the first load for a given `(url, resize)` pair, the CDN
    /// requester's `cachingKey` is remembered. Because the `cachingKey`
    /// already encodes all resize parameters, it is the only identifier
    /// needed to look up Nuke's memory cache (via `imageIdKey`).
    ///
    /// Returns `nil` when the image has never been loaded (no stored key)
    /// or when Nuke has evicted it from memory.
    static func cachedResult(url: URL, resize: ImageResize?) -> StreamAsyncImageResult? {
        let key = inputKey(url: url, resize: resize) as NSString
        guard let storedKey = cachingKeyMap.object(forKey: key)?.value else { return nil }

        let request = ImageRequest(
            url: url,
            processors: makeProcessors(resize: resize),
            userInfo: [ImageRequest.UserInfoKey.imageIdKey: storedKey as Any]
        )
        guard let container = ImagePipeline.shared.cache[request] else { return nil }
        return StreamAsyncImageResult(
            image: container.image,
            isAnimated: container.type == .gif,
            animatedImageData: container.data
        )
    }

    // MARK: - Async Loading

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
        mediaLoader: MediaLoader,
        onCacheMiss: @MainActor () -> Void = {}
    ) async throws -> StreamAsyncImageResult {
        let cdnRequester = (mediaLoader as? StreamMediaLoader)?.cdnRequester ?? StreamCDNRequester()
        let cdnResize = resize.map {
            CDNImageResize(width: $0.width, height: $0.height, resizeMode: $0.mode.value, crop: $0.mode.cropValue)
        }
        let cdnRequest = try await cdnRequester.imageRequest(for: url, options: .init(resize: cdnResize))

        if let cachingKey = cdnRequest.cachingKey {
            let key = inputKey(url: url, resize: resize) as NSString
            cachingKeyMap.setObject(StringBox(cachingKey), forKey: key)
        }

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

    /// Maps `(url + resize)` → `cachingKey` so ``cachedResult(url:resize:)``
    /// can query Nuke's memory cache using the correct `imageIdKey`.
    /// Populated on the first successful CDN transform for each pair.
    private nonisolated(unsafe) static let cachingKeyMap = NSCache<NSString, StringBox>()

    private static func inputKey(url: URL, resize: ImageResize?) -> String {
        let urlPart = url.absoluteString
        guard let resize else { return urlPart }
        return "\(urlPart)-\(resize.width)x\(resize.height)-\(resize.mode.value)"
    }

    private static func makeProcessors(resize: ImageResize?) -> [any ImageProcessing] {
        guard let resize else { return [] }
        let size = CGSize(width: resize.width, height: resize.height)
        guard size != .zero else { return [] }
        return [ImageProcessors.Resize(size: size)]
    }
}

private final class StringBox: @unchecked Sendable {
    let value: String
    init(_ value: String) { self.value = value }
}
