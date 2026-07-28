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

    @StateObject private var handler: MediaPickerAssetHandler

    var asset: PHAsset
    var onImageTap: (AddedAsset) -> Void
    var imageSelected: (String) -> Bool
    var selectedAssetIds: Set<String>?

    public init(
        assetLoader: PhotoAssetLoader,
        asset: PHAsset,
        onImageTap: @escaping (AddedAsset) -> Void,
        imageSelected: @escaping (String) -> Bool,
        selectedAssetIds: Set<String>? = nil
    ) {
        _handler = StateObject(wrappedValue: MediaPickerAssetHandler(
            asset: asset,
            assetLoader: assetLoader
        ))
        self.asset = asset
        self.onImageTap = onImageTap
        self.imageSelected = imageSelected
        self.selectedAssetIds = selectedAssetIds
    }

    @available(*, deprecated, message: "requestId is no longer used. Use init(assetLoader:asset:onImageTap:imageSelected:selectedAssetIds:) instead.")
    public init(
        assetLoader: PhotoAssetLoader,
        requestId: PHContentEditingInputRequestID?,
        asset: PHAsset,
        onImageTap: @escaping (AddedAsset) -> Void,
        imageSelected: @escaping (String) -> Bool,
        selectedAssetIds: Set<String>? = nil
    ) {
        self.init(
            assetLoader: assetLoader,
            asset: asset,
            onImageTap: onImageTap,
            imageSelected: imageSelected,
            selectedAssetIds: selectedAssetIds
        )
    }

    public var body: some View {
        let selected = isAssetSelected(asset.localIdentifier)
        ZStack {
            if let image = handler.currentImage {
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
                                handler.handleTap(
                                    image: image,
                                    currentlySelected: selected,
                                    onSelect: onImageTap
                                )
                            }
                    }
                    .overlay(
                        handler.isBusy ? ProgressView() : nil
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
            .id(handler.overlayID)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(.isButton)
        .accessibilityAddTraits(selected ? .isSelected : [])
        .accessibilityAction {
            guard let image = handler.currentImage else { return }
            handler.handleTap(
                image: image,
                currentlySelected: selected,
                onSelect: onImageTap
            )
        }
        .onAppear {
            handler.onAppear()
        }
        .onDisappear {
            handler.onDisappear()
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
