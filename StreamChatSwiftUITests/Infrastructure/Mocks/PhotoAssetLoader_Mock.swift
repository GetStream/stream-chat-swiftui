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
    var assetURLRequests = [(asset: PHAsset, allowsNetworkAccess: Bool)]()
    var cancelledRequestIds = [PHImageRequestID]()

    /// Result of `assetExceedsAllowedSize`.
    var exceedsAllowedSize = false
    /// Result handed to the completion of `compressAsset`.
    var compressedURL: URL?
    /// When true, `compressAsset` records the call but never invokes its completion.
    var hangCompression = false
    /// Result handed to the completion of `requestAssetURL`.
    var assetURL: URL?
    /// Id returned by `requestAssetURL`.
    var assetURLRequestId: PHImageRequestID = 1
    /// When false, `requestAssetURL` records the call but never invokes its completion.
    var completesAssetURLRequests = true
    /// When true, `requestAssetURL` only delivers `assetURL` when network access is allowed.
    var assetIsInCloud = false

    // Called after each recorded request, so that tests can wait for the calls made by a
    // hosted view instead of waiting for a fixed duration.
    var onLoadImage: (() -> Void)?
    var onCancelImageLoad: (() -> Void)?
    var onCancelAllImageLoads: (() -> Void)?
    var onAssetURLRequest: (() -> Void)?
    var onCancelRequest: (() -> Void)?

    override func loadImage(
        for asset: PHAsset,
        targetSize: CGSize,
        completion: @escaping (UIImage?) -> Void
    ) {
        loadImageCalls.append((asset, targetSize))
        if let cached = cachedImage(for: asset) {
            completion(cached)
        }
        onLoadImage?()
    }

    override func cancelImageLoad(for asset: PHAsset) {
        cancelledImageLoads.append(asset)
        onCancelImageLoad?()
    }

    override func cancelAllImageLoads() {
        cancelAllImageLoadsCallCount += 1
        onCancelAllImageLoads?()
    }

    override func requestAssetURL(
        for asset: PHAsset,
        allowsNetworkAccess: Bool,
        completion: @escaping @MainActor (URL?) -> Void
    ) -> PHImageRequestID {
        assetURLRequests.append((asset, allowsNetworkAccess))
        if completesAssetURLRequests {
            let isAvailable = allowsNetworkAccess || !assetIsInCloud
            completion(isAvailable ? assetURL : nil)
        }
        onAssetURLRequest?()
        return assetURLRequestId
    }

    override func cancelRequest(_ requestId: PHImageRequestID) {
        cancelledRequestIds.append(requestId)
        onCancelRequest?()
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
