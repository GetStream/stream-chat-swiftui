//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChatCommonUI
import UIKit

/// Internal helper for synchronous Nuke memory-cache lookups.
///
/// ``StreamAsyncImage`` uses this to compute an instant `initialPhase`
/// when a previously loaded image is still in memory. All actual image
/// loading goes through ``MediaLoader``.
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
            animatedImageData: container.type == .gif ? container.data : nil
        )
    }

    /// Stores a caching key for a given URL and resize combination.
    ///
    /// Called by ``StreamAsyncImage`` after a successful load through
    /// ``MediaLoader/loadImage(url:options:completion:)`` so that
    /// ``cachedResult(url:resize:)`` can find the image in Nuke's
    /// memory cache on subsequent lookups.
    static func storeCachingKey(_ cachingKey: String, url: URL, resize: ImageResize?) {
        let key = inputKey(url: url, resize: resize) as NSString
        cachingKeyMap.setObject(StringBox(cachingKey), forKey: key)
    }

    // MARK: - Private

    private nonisolated(unsafe) static let cachingKeyMap = NSCache<NSString, StringBox>()

    private static func inputKey(url: URL, resize: ImageResize?) -> String {
        let urlPart = url.absoluteString
        guard let resize else { return urlPart }
        return "\(urlPart)-\(resize.width)x\(resize.height)-\(resize.mode.value)"
    }

    static func makeProcessors(resize: ImageResize?) -> [any ImageProcessing] {
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
