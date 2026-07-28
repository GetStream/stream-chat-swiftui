//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Photos
@testable import StreamChatSwiftUI
import UIKit

/// Records the asset requests made by the media picker, without touching the Photos library.
final class PhotoAssetLoader_Mock: PhotoAssetLoader {
    var loadImageCalls = [(asset: PHAsset, targetSize: CGSize)]()
    var cancelledImageLoads = [PHAsset]()
    var cancelAllImageLoadsCallCount = 0
    var compressAssetCalls = [(url: URL, type: AssetType)]()

    /// Result of `assetExceedsAllowedSize`.
    var exceedsAllowedSize = false
    /// Result handed to the completion of `compressAsset`.
    var compressedURL: URL?
    /// When true, `compressAsset` records the call but never invokes its completion.
    var hangCompression = false

    override func loadImage(
        for asset: PHAsset,
        targetSize: CGSize,
        completion: @escaping (UIImage?) -> Void
    ) {
        loadImageCalls.append((asset, targetSize))
        if let cached = cachedImage(for: asset) {
            completion(cached)
        }
    }

    override func cancelImageLoad(for asset: PHAsset) {
        cancelledImageLoads.append(asset)
    }

    override func cancelAllImageLoads() {
        cancelAllImageLoadsCallCount += 1
    }

    override func compressAsset(
        at url: URL,
        type: AssetType,
        completion: @escaping @MainActor (URL?) -> Void
    ) {
        compressAssetCalls.append((url, type))
        guard !hangCompression else { return }
        completion(compressedURL)
    }

    override func assetExceedsAllowedSize(url: URL?) -> Bool {
        exceedsAllowedSize
    }
}
