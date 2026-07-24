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
    
    @ObservedObject var assetLoader: PhotoAssetLoader
    
    @State private var assetURL: URL?
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
        ZStack {
            if let image = assetLoader.loadedImages[asset.localIdentifier] {
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
            guard let image = assetLoader.loadedImages[asset.localIdentifier] else { return }
            handleTap(image: image, currentlySelected: selected)
        }
        .onAppear {
            assetLoader.loadImage(from: asset)
        }
        .onDisappear {
            cancelAssetURLRequest()
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

    // Toggling off, or an already-downloaded asset, is applied immediately.
    // Otherwise the asset (which may live in iCloud) is downloaded on demand and
    // only selected once the download finishes, so an idle picker never downloads.
    private func handleTap(image: UIImage, currentlySelected: Bool) {
        if currentlySelected || assetURL != nil {
            withAnimation {
                selectAsset(image: image, currentlySelected: currentlySelected)
            }
            return
        }

        guard !loading, !compressing else { return }

        loadAssetURL {
            guard assetURL != nil else { return }
            withAnimation {
                selectAsset(image: image, currentlySelected: false)
            }
        }
    }

    private func loadAssetURL(completion: @escaping () -> Void) {
        let options = PHContentEditingInputRequestOptions()
        options.isNetworkAccessAllowed = true
        loading = true

        requestId = asset.requestContentEditingInput(with: options) { input, _ in
            loading = false
            if asset.mediaType == .image {
                assetURL = input?.fullSizeImageURL
            } else if let url = (input?.audiovisualAsset as? AVURLAsset)?.url {
                assetURL = url
            }

            // Check file size.
            if assetType == .video, let assetURL, assetLoader.assetExceedsAllowedSize(url: assetURL) {
                compressing = true
                assetLoader.compressAsset(at: assetURL, type: assetType) { url in
                    self.assetURL = url
                    compressing = false
                    completion()
                }
            } else {
                completion()
            }
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
        let resolvedURL = asset.mediaType == .image ? assetJpgURL() : assetURL
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
        guard let assetData = try? Data(contentsOf: assetURL) else { return nil }
        return try? UIImage(data: assetData)?.saveAsJpgToTemporaryUrl()
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
