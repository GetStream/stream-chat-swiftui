//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Photos
import SwiftUI

/// Owns the non-UI work for a single media-picker cell: thumbnail loading,
/// local image preparation, on-tap resolution / compression, and selection.
@MainActor
final class MediaPickerAssetHandler: ObservableObject {
    @Published private(set) var thumbnail: UIImage?
    @Published private(set) var loading = false
    @Published private(set) var compressing = false
    @Published private(set) var overlayID = UUID()

    private(set) var requestId: PHContentEditingInputRequestID?
    private(set) var assetURL: URL?
    private(set) var jpgURL: URL?

    private let asset: PHAsset
    private let assetLoader: PhotoAssetLoader

    var assetType: AssetType {
        asset.mediaType == .video ? .video : .image
    }

    var isBusy: Bool {
        loading || compressing
    }

    var currentImage: UIImage? {
        thumbnail ?? assetLoader.cachedImage(for: asset)
    }

    var readyURL: URL? {
        assetType == .image ? jpgURL : assetURL
    }

    init(asset: PHAsset, assetLoader: PhotoAssetLoader) {
        self.asset = asset
        self.assetLoader = assetLoader
    }

    // MARK: - Lifecycle

    func onAppear() {
        loadThumbnail()
        prepareLocalImageIfNeeded()
    }

    func onDisappear() {
        assetLoader.cancelImageLoad(for: asset)
        cancelAssetURLRequest()
        // Rows scrolled past stay instantiated in the lazy grid, so holding the
        // decoded thumbnail in row state would bypass the loader's bounded cache.
        thumbnail = nil
    }

    // MARK: - Selection

    // Toggling off, or an asset that is already prepared, is applied immediately.
    // Otherwise the asset is resolved on demand, downloading it from iCloud when
    // needed, so that an idle picker never downloads anything.
    func handleTap(
        image: UIImage,
        currentlySelected: Bool,
        onSelect: @escaping (AddedAsset) -> Void
    ) {
        if currentlySelected || readyURL != nil {
            guard !compressing else { return }
            withAnimation {
                selectAsset(image: image, currentlySelected: currentlySelected, onSelect: onSelect)
            }
            return
        }

        guard !loading, !compressing else { return }

        resolveAssetURL {
            guard self.assetURL != nil else { return }
            withAnimation {
                self.selectAsset(image: image, currentlySelected: false, onSelect: onSelect)
            }
        }
    }

    // MARK: - Private

    private func loadThumbnail() {
        guard thumbnail == nil, assetLoader.cachedImage(for: asset) == nil else { return }
        assetLoader.loadImage(for: asset, targetSize: CGSize(width: 250, height: 250)) { [weak self] image in
            self?.thumbnail = image
        }
    }

    // Converts an already on-device image to JPG up front so that selecting it is
    // instant. Videos are skipped: their compression is expensive, so it only runs
    // when one is actually picked. iCloud assets are never fetched here.
    private func prepareLocalImageIfNeeded() {
        guard assetType == .image, assetURL == nil, requestId == nil else { return }
        requestContentEditingInput(allowNetwork: false) { [weak self] input in
            guard let self, let url = input?.fullSizeImageURL else { return }
            assetURL = url
            Task {
                jpgURL = await Self.makeJpgURL(for: url)
            }
        }
    }

    private func resolveAssetURL(completion: @escaping () -> Void) {
        cancelAssetURLRequest()
        loading = true

        // Downloads the asset from iCloud when it is not available on the device.
        requestContentEditingInput(allowNetwork: true) { [weak self] input in
            guard let self else { return }
            applyContentEditingInput(input)
            compressVideoIfNeeded {
                self.loading = false
                completion()
            }
        }
    }

    private func requestContentEditingInput(
        allowNetwork: Bool,
        completion: @escaping (PHContentEditingInput?) -> Void
    ) {
        let options = PHContentEditingInputRequestOptions()
        options.isNetworkAccessAllowed = allowNetwork
        // Cancelled requests still report back, so the id is only cleared while it is
        // the one in flight. A synchronous completion is not tracked at all.
        var isCompleted = false
        var newRequestId: PHContentEditingInputRequestID?
        newRequestId = asset.requestContentEditingInput(with: options) { [weak self] input, _ in
            isCompleted = true
            if let self, let newRequestId, requestId == newRequestId {
                requestId = nil
            }
            completion(input)
        }
        if !isCompleted {
            requestId = newRequestId
        }
    }

    private func applyContentEditingInput(_ input: PHContentEditingInput?) {
        if asset.mediaType == .image {
            assetURL = input?.fullSizeImageURL
        } else if let url = (input?.audiovisualAsset as? AVURLAsset)?.url {
            assetURL = url
        }
    }

    private func compressVideoIfNeeded(completion: @escaping () -> Void) {
        guard assetType == .video,
              let assetURL,
              assetLoader.assetExceedsAllowedSize(url: assetURL) else {
            completion()
            return
        }
        compressing = true
        assetLoader.compressAsset(at: assetURL, type: assetType) { [weak self] url in
            guard let self else { return }
            // Keeping the original url when compression fails leaves the composer's size
            // validation in charge of reporting it, instead of the tap doing nothing.
            if let url {
                self.assetURL = url
            }
            compressing = false
            completion()
        }
    }

    private func cancelAssetURLRequest() {
        if let requestId {
            asset.cancelContentEditingInputRequest(requestId)
            self.requestId = nil
        }
        loading = false
    }

    private func selectAsset(
        image: UIImage,
        currentlySelected: Bool,
        onSelect: @escaping (AddedAsset) -> Void
    ) {
        let resolvedURL = assetType == .image ? (jpgURL ?? assetJpgURL()) : assetURL
        guard let url = resolvedURL else { return }
        let width = Double(asset.pixelWidth)
        let height = Double(asset.pixelHeight)
        let durationSeconds: TimeInterval? = asset.mediaType == .video ? asset.duration : nil
        onSelect(
            AddedAsset(
                image: image,
                id: asset.localIdentifier,
                url: url,
                type: assetType,
                extraData: asset.mediaType == .video ? ["duration": .number(asset.duration)] : [:],
                originalWidth: width > 0 ? width : nil,
                originalHeight: height > 0 ? height : nil,
                duration: durationSeconds
            )
        )
        overlayID = UUID()
        announceSelectionChange(willBeSelected: !currentlySelected)
    }

    private func announceSelectionChange(willBeSelected: Bool) {
        let message: String
        switch (asset.mediaType, willBeSelected) {
        case (.video, true):
            message = L10n.Composer.MediaPicker.Accessibility.videoAdded
        case (.video, false):
            message = L10n.Composer.MediaPicker.Accessibility.videoRemoved
        case (_, true):
            message = L10n.Composer.MediaPicker.Accessibility.photoAdded
        case (_, false):
            message = L10n.Composer.MediaPicker.Accessibility.photoRemoved
        }
        ComposerAccessibilityAnnouncer.announce(message)
    }

    /// The original photo is usually in HEIC format.
    /// This makes sure that the photo is converted to JPG.
    private func assetJpgURL() -> URL? {
        guard let assetURL else { return nil }
        return Self.convertToJpg(at: assetURL)
    }

    private static func makeJpgURL(for url: URL) async -> URL? {
        await Task.detached(priority: .utility) {
            convertToJpg(at: url)
        }.value
    }

    private nonisolated static func convertToJpg(at url: URL) -> URL? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? UIImage(data: data)?.saveAsJpgToTemporaryUrl()
    }
}
