//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Combine
import Photos
import StreamChat
import SwiftUI
import UniformTypeIdentifiers

/// Helper class that loads assets from the photo library.
@MainActor public class PhotoAssetLoader: NSObject, ObservableObject {
    @Injected(\.chatClient) private var chatClient
    @Injected(\.utils) private var utils

    // Thumbnails are requested one by one as cells appear and are kept in `imageCache`, so
    // there is nothing for `PHCachingImageManager` to prefetch. Prefetching would mean
    // resolving assets ahead of the visible range, which is the main-thread Photos work the
    // grid deliberately avoids.
    private let imageManager: PHImageManager

    // Bounded so that scrolling through a large library does not retain every
    // decoded thumbnail. NSCache also evicts automatically under memory pressure.
    private let imageCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 200
        cache.totalCostLimit = 50 * 1024 * 1024
        return cache
    }()

    private var inFlightImageRequests = [String: PHImageRequestID]()

    override public init() {
        imageManager = .default()
        super.init()
    }

    init(imageManager: PHImageManager) {
        self.imageManager = imageManager
        super.init()
    }

    /// Returns an already-loaded thumbnail for the asset, if available.
    func cachedImage(for asset: PHAsset) -> UIImage? {
        imageCache.object(forKey: asset.localIdentifier as NSString)
    }

    func cache(_ image: UIImage, for asset: PHAsset) {
        imageCache.setObject(
            image,
            forKey: asset.localIdentifier as NSString,
            cost: image.cgImage.map { $0.bytesPerRow * $0.height } ?? 0
        )
    }

    /// Loads a thumbnail for the asset, delivering it (possibly progressively) via `completion`.
    func loadImage(
        for asset: PHAsset,
        targetSize: CGSize,
        completion: @escaping (UIImage?) -> Void
    ) {
        if let cached = cachedImage(for: asset) {
            completion(cached)
            return
        }

        let assetId = asset.localIdentifier
        cancelImageLoad(for: asset)

        let options = PHImageRequestOptions()
        options.version = .current
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = false

        var isCompleted = false
        let requestId = imageManager.requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: options
        ) { [weak self] image, info in
            guard let self, let image else { return }
            let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
            if !isDegraded {
                isCompleted = true
                inFlightImageRequests[assetId] = nil
                cache(image, for: asset)
            }
            completion(image)
        }
        // The final image can be delivered synchronously, in which case the request
        // must not be tracked, otherwise a later cancel would target a finished request.
        if !isCompleted {
            inFlightImageRequests[assetId] = requestId
        }
    }

    func cancelImageLoad(for asset: PHAsset) {
        guard let requestId = inFlightImageRequests.removeValue(forKey: asset.localIdentifier) else { return }
        imageManager.cancelImageRequest(requestId)
    }

    /// Resolves a local file url for the asset, downloading it from iCloud when allowed.
    ///
    /// Images are delivered as JPG, since the originals are usually HEIC. These requests are
    /// served by the Photos image pipeline, unlike `PHAsset.requestContentEditingInput`, which
    /// needs the asset's adjustment properties and fetches them on demand on the main queue.
    func requestAssetURL(
        for asset: PHAsset,
        allowsNetworkAccess: Bool,
        completion: @escaping @MainActor (URL?) -> Void
    ) -> PHImageRequestID {
        asset.mediaType == .video
            ? requestVideoURL(for: asset, allowsNetworkAccess: allowsNetworkAccess, completion: completion)
            : requestImageURL(for: asset, allowsNetworkAccess: allowsNetworkAccess, completion: completion)
    }

    func cancelRequest(_ requestId: PHImageRequestID) {
        imageManager.cancelImageRequest(requestId)
    }

    /// Cancels every thumbnail request still in flight, so that a fast scroll followed by
    /// dismissing the picker does not leave the remaining requests running.
    func cancelAllImageLoads() {
        for requestId in inFlightImageRequests.values {
            imageManager.cancelImageRequest(requestId)
        }
        inFlightImageRequests.removeAll()
    }

    func compressAsset(at url: URL, type: AssetType, completion: @escaping @MainActor (URL?) -> Void) {
        // The completion has to run on every path, otherwise callers wait forever.
        guard type == .video else {
            completion(nil)
            return
        }
        let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + UUID().uuidString + ".mp4")
        compressVideo(inputURL: url, outputURL: compressedURL) { exportSession in
            let didComplete = exportSession?.status == .completed
            Task { @MainActor in
                completion(didComplete ? compressedURL : nil)
            }
        }
    }

    func assetExceedsAllowedSize(url: URL?) -> Bool {
        _ = url?.startAccessingSecurityScopedResource()
        if let assetURL = url,
           let file = try? AttachmentFile(url: assetURL),
           file.size >= chatClient.maxAttachmentSize(for: assetURL, fallbackSize: utils.composerConfig.maxAttachmentSize) {
            return true
        } else {
            return false
        }
    }

    private func requestImageURL(
        for asset: PHAsset,
        allowsNetworkAccess: Bool,
        completion: @escaping @MainActor (URL?) -> Void
    ) -> PHImageRequestID {
        let options = PHImageRequestOptions()
        options.version = .current
        options.isNetworkAccessAllowed = allowsNetworkAccess

        // Marked Sendable so the handler makes no isolation assumption about the delivery queue.
        return imageManager.requestImageDataAndOrientation(for: asset, options: options) { @Sendable data, dataUTI, _, _ in
            Task { @MainActor in
                completion(data.flatMap { PhotoAssetLoader.temporaryJpgURL(for: $0, dataUTI: dataUTI) })
            }
        }
    }

    private func requestVideoURL(
        for asset: PHAsset,
        allowsNetworkAccess: Bool,
        completion: @escaping @MainActor (URL?) -> Void
    ) -> PHImageRequestID {
        let options = PHVideoRequestOptions()
        options.version = .current
        options.isNetworkAccessAllowed = allowsNetworkAccess

        // The handler runs on a Photos queue, so it must not inherit the main actor isolation.
        return imageManager.requestAVAsset(forVideo: asset, options: options) { @Sendable avAsset, _, _ in
            // Only the url is handed back, the asset itself is not safe to send across isolation.
            let url = (avAsset as? AVURLAsset)?.url
            Task { @MainActor in
                completion(url)
            }
        }
    }

    private func compressVideo(
        inputURL: URL,
        outputURL: URL,
        handler: @escaping @Sendable (_ exportSession: AVAssetExportSession?) -> Void
    ) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)

        guard let exportSession = AVAssetExportSession(
            asset: urlAsset,
            presetName: AVAssetExportPresetMediumQuality
        ) else {
            handler(nil)
            return
        }

        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        nonisolated(unsafe) let unsafeSession = exportSession
        exportSession.exportAsynchronously {
            handler(unsafeSession)
        }
    }

    /// Clears the cache when there's memory warning.
    func didReceiveMemoryWarning() {
        imageCache.removeAllObjects()
    }

    /// Writes image data to a temporary JPG file, converting it first when it is not JPG already.
    nonisolated static func temporaryJpgURL(for data: Data, dataUTI: String?) -> URL? {
        // Data that already is JPG is written as is, which skips a full decode and re-encode.
        guard dataUTI == UTType.jpeg.identifier else {
            return try? UIImage(data: data)?.saveAsJpgToTemporaryUrl()
        }
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("\(UUID().uuidString).jpg")
        do {
            try data.write(to: url)
            return url
        } catch {
            return nil
        }
    }
}

extension PHAsset: @retroactive Identifiable {
    public var id: String {
        localIdentifier
    }
}

/// Helper collection that allows iteration over the fetched assets from the photo library.
public final class PHFetchResultCollection: RandomAccessCollection, Equatable, Sendable {
    public typealias Element = PHAsset
    public typealias Index = Int

    public let fetchResult: PHFetchResult<PHAsset>

    public var endIndex: Int { fetchResult.count }
    public var startIndex: Int { 0 }

    public init(fetchResult: PHFetchResult<PHAsset>) {
        self.fetchResult = fetchResult
    }

    public subscript(position: Int) -> PHAsset {
        fetchResult.object(at: position)
    }

    public static func == (lhs: PHFetchResultCollection, rhs: PHFetchResultCollection) -> Bool {
        lhs.fetchResult == rhs.fetchResult
    }
}
