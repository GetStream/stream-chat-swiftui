//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Photos
import SwiftUI

/// Media item displayed in the attachment picker view.
public struct AttachmentMediaPickerItemView: View {
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens
    @Injected(\.utils) private var utils
    
    var assetLoader: PhotoAssetLoader

    @State private var thumbnail: UIImage?
    @State private var assetURL: URL?
    @State private var jpgURL: URL?
    @State private var compressing = false
    @State private var loading = false
    @State var requestId: PHContentEditingInputRequestID?
    @State var idOverlay = UUID()
    
    var asset: PHAsset
    var onImageTap: (AddedAsset) -> Void
    var imageSelected: (String) -> Bool
    var selectedAssetIds: Set<String>?
    
    private var assetType: AssetType {
        asset.mediaType == .video ? .video : .image
    }

    public init(
        assetLoader: PhotoAssetLoader,
        requestId: PHContentEditingInputRequestID? = nil,
        asset: PHAsset,
        onImageTap: @escaping (AddedAsset) -> Void,
        imageSelected: @escaping (String) -> Bool,
        selectedAssetIds: Set<String>? = nil
    ) {
        self.assetLoader = assetLoader
        _requestId = State(initialValue: requestId)
        self.asset = asset
        self.onImageTap = onImageTap
        self.imageSelected = imageSelected
        self.selectedAssetIds = selectedAssetIds
    }
 
    public var body: some View {
        let selected = isAssetSelected(asset.localIdentifier)
        let image = currentImage
        ZStack {
            if let image {
                GeometryReader { reader in
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: reader.size.width, height: reader.size.height)
                            .allowsHitTesting(false)
                            .clipped()
                        
                        // Needed because of SwiftUI bug with tap area of Image.
                        Rectangle()
                            .fill(.clear)
                            .frame(width: reader.size.width, height: reader.size.height)
                            .contentShape(.rect)
                            .clipped()
                            .allowsHitTesting(true)
                            .onTapGesture {
                                handleTap(image: image, currentlySelected: selected)
                            }
                    }
                    .overlay(
                        (compressing || loading) ? ProgressView() : nil
                    )
                }
            } else {
                Color(colors.backgroundCoreSurfaceDefault)
                    .aspectRatio(1, contentMode: .fill)
                
                Image(uiImage: images.imagePlaceholder)
                    .customizable()
                    .frame(height: 56)
                    .foregroundColor(Color(colors.textTertiary))
            }
        }
        .aspectRatio(1, contentMode: .fill)
        .clipShape(RoundedRectangle(cornerRadius: tokens.radiusXxs))
        .overlay(
            ZStack {
                // Selected dimming overlay
                if selected {
                    RoundedRectangle(cornerRadius: tokens.radiusXxs)
                        .fill(Color(colors.backgroundUtilitySelected))
                }

                // Selection indicator (top-right)
                SelectionBadgeView(isSelected: selected)
                    .padding(tokens.spacingXs)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)

                // Video duration badge (bottom-left)
                if asset.mediaType == .video {
                    VideoMediaBadge(durationText: assetDurationText)
                        .padding(tokens.spacingXs)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                }
            }
            .allowsHitTesting(false)
            .accessibilityHidden(true)
            .id(idOverlay)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(.isButton)
        .accessibilityAddTraits(selected ? .isSelected : [])
        .accessibilityAction {
            guard let image = currentImage else { return }
            handleTap(image: image, currentlySelected: selected)
        }
        .onAppear {
            loadThumbnail()
            prepareLocalImageIfNeeded()
        }
        .onDisappear {
            assetLoader.cancelImageLoad(for: asset)
            cancelAssetURLRequest()
            // Rows scrolled past stay instantiated in the lazy grid, so holding the
            // decoded thumbnail in row state would bypass the loader's bounded cache.
            thumbnail = nil
        }
    }

    private var currentImage: UIImage? {
        thumbnail ?? assetLoader.cachedImage(for: asset)
    }

    private func loadThumbnail() {
        guard thumbnail == nil, assetLoader.cachedImage(for: asset) == nil else { return }
        assetLoader.loadImage(for: asset, targetSize: CGSize(width: 250, height: 250)) { image in
            thumbnail = image
        }
    }

    // Converts an already on-device image to JPG up front so that selecting it is
    // instant. Videos are skipped: their compression is expensive, so it only runs
    // when one is actually picked. iCloud assets are never fetched here.
    private func prepareLocalImageIfNeeded() {
        guard assetType == .image, assetURL == nil, requestId == nil else { return }
        requestContentEditingInput(allowNetwork: false) { input in
            guard let url = input?.fullSizeImageURL else { return }
            assetURL = url
            Task {
                jpgURL = await Self.makeJpgURL(for: url)
            }
        }
    }

    private var assetDurationText: String {
        utils.mediaBadgeDurationFormatter.longFormat(asset.duration)
    }

    private var accessibilityLabel: String {
        switch asset.mediaType {
        case .video:
            let duration = Self.accessibilityDurationFormatter.string(from: asset.duration) ?? assetDurationText
            return L10n.Composer.MediaPicker.Accessibility.video(duration)
        default:
            return L10n.Composer.MediaPicker.Accessibility.photo
        }
    }

    private static let accessibilityDurationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .dropLeading
        return formatter
    }()

    // Toggling off, or an asset that is already prepared, is applied immediately.
    // Otherwise the asset is resolved on demand, downloading it from iCloud when
    // needed, so that an idle picker never downloads anything.
    private func handleTap(image: UIImage, currentlySelected: Bool) {
        if currentlySelected || readyURL != nil {
            guard !compressing else { return }
            withAnimation {
                selectAsset(image: image, currentlySelected: currentlySelected)
            }
            return
        }

        guard !loading, !compressing else { return }

        resolveAssetURL {
            guard assetURL != nil else { return }
            withAnimation {
                selectAsset(image: image, currentlySelected: false)
            }
        }
    }

    private var readyURL: URL? {
        assetType == .image ? jpgURL : assetURL
    }

    private func resolveAssetURL(completion: @escaping () -> Void) {
        cancelAssetURLRequest()
        loading = true

        // Downloads the asset from iCloud when it is not available on the device.
        requestContentEditingInput(allowNetwork: true) { input in
            applyContentEditingInput(input)
            compressVideoIfNeeded {
                loading = false
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
        newRequestId = asset.requestContentEditingInput(with: options) { input, _ in
            isCompleted = true
            if let newRequestId, requestId == newRequestId {
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
        assetLoader.compressAsset(at: assetURL, type: assetType) { url in
            self.assetURL = url
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

    private func selectAsset(image: UIImage, currentlySelected: Bool) {
        let resolvedURL = assetType == .image ? (jpgURL ?? assetJpgURL()) : assetURL
        guard let url = resolvedURL else { return }
        let width = Double(asset.pixelWidth)
        let height = Double(asset.pixelHeight)
        let durationSeconds: TimeInterval? = asset.mediaType == .video ? asset.duration : nil
        onImageTap(
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
        idOverlay = UUID()
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
    /// This way it is more compatible with other platforms.
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
    
    private func isAssetSelected(_ id: String) -> Bool {
        if let selectedAssetIds {
            return selectedAssetIds.contains(id)
        }
        return imageSelected(id)
    }
}

extension UIImage {
    func saveAsJpgToTemporaryUrl() throws -> URL? {
        guard let imageData = jpegData(compressionQuality: 1.0) else { return nil }
        let imageName = "\(UUID().uuidString).jpg"
        let documentDirectory = NSTemporaryDirectory()
        let localPath = documentDirectory.appending(imageName)
        let photoURL = URL(fileURLWithPath: localPath)
        try imageData.write(to: photoURL)
        return photoURL
    }
}
