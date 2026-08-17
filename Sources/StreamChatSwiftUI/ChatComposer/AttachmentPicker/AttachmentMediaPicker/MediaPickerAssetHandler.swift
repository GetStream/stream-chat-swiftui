//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Photos
import SwiftUI

/// Owns the non-UI work for a single media-picker cell: thumbnail loading,
/// on-tap resolution / compression, and selection.
@MainActor
final class MediaPickerAssetHandler: ObservableObject {
    @Published private(set) var thumbnail: UIImage?
    @Published private(set) var loading = false
    @Published private(set) var compressing = false
    @Published private(set) var overlayID = UUID()

    private(set) var requestId: PHImageRequestID?
    private(set) var assetURL: URL?

    private let asset: PHAsset
    private let assetLoader: PhotoAssetLoader
    private var requestToken: UUID?

    var assetType: AssetType {
        asset.mediaType == .video ? .video : .image
    }

    var isBusy: Bool {
        loading || compressing
    }

    var currentImage: UIImage? {
        thumbnail ?? assetLoader.cachedImage(for: asset)
    }

    init(asset: PHAsset, assetLoader: PhotoAssetLoader) {
        self.asset = asset
        self.assetLoader = assetLoader
    }

    // MARK: - Lifecycle

    func onAppear() {
        loadThumbnail()
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
        if currentlySelected || assetURL != nil {
            guard !compressing else { return }
            withAnimation {
                selectAsset(image: image, currentlySelected: currentlySelected, onSelect: onSelect)
            }
            return
        }

        guard !loading, !compressing, requestId == nil else { return }

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

    // On-device assets resolve without the spinner, since that is fast. Only an iCloud
    // download, which the local-only attempt rules out first, shows it.
    private func resolveAssetURL(completion: @escaping () -> Void) {
        cancelAssetURLRequest()

        requestAssetURL(allowsNetworkAccess: false) { [weak self] url in
            guard let self else { return }
            if let url {
                assetURL = url
                compressVideoIfNeeded(completion: completion)
            } else {
                downloadAssetURL(completion: completion)
            }
        }
    }

    private func downloadAssetURL(completion: @escaping () -> Void) {
        loading = true

        requestAssetURL(allowsNetworkAccess: true) { [weak self] url in
            guard let self else { return }
            assetURL = url
            compressVideoIfNeeded {
                self.loading = false
                completion()
            }
        }
    }

    private func requestAssetURL(
        allowsNetworkAccess: Bool,
        completion: @escaping (URL?) -> Void
    ) {
        // Cancelled requests still report back, so the id is only cleared while it is
        // the one in flight. A synchronous completion is not tracked at all.
        let token = UUID()
        requestToken = token
        let newRequestId = assetLoader.requestAssetURL(
            for: asset,
            allowsNetworkAccess: allowsNetworkAccess
        ) { [weak self] url in
            if let self, requestToken == token {
                requestId = nil
                requestToken = nil
            }
            completion(url)
        }
        if requestToken == token {
            requestId = newRequestId
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
            assetLoader.cancelRequest(requestId)
            self.requestId = nil
        }
        requestToken = nil
        loading = false
    }

    private func selectAsset(
        image: UIImage,
        currentlySelected: Bool,
        onSelect: @escaping (AddedAsset) -> Void
    ) {
        guard let url = assetURL else { return }
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
}
