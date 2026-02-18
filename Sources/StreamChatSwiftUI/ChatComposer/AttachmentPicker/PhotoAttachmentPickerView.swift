//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Photos
import StreamChatCommonUI
import SwiftUI

/// View for the photo attachment picker.
public struct PhotoAttachmentPickerView: View {
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens
    
    @StateObject var assetLoader = PhotoAssetLoader()
    
    var assets: PHFetchResultCollection
    var onImageTap: (AddedAsset) -> Void
    var imageSelected: (String) -> Bool
    var selectedAssetIds: [String]?
    
    private var selectedAssetIdsSet: Set<String>? {
        guard let selectedAssetIds else { return nil }
        return Set(selectedAssetIds)
    }
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)

    public init(
        assets: PHFetchResultCollection,
        onImageTap: @escaping (AddedAsset) -> Void,
        imageSelected: @escaping (String) -> Bool,
        selectedAssetIds: [String]? = nil
    ) {
        self.assets = assets
        self.onImageTap = onImageTap
        self.imageSelected = imageSelected
        self.selectedAssetIds = selectedAssetIds
    }
    
    public var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(assets) { asset in
                    PhotoAttachmentCell(
                        assetLoader: assetLoader,
                        asset: asset,
                        onImageTap: onImageTap,
                        imageSelected: imageSelected,
                        selectedAssetIds: selectedAssetIdsSet
                    )
                }
            }
            .animation(nil)
        }
    }
}

/// Photo cell displayed in the picker view.
public struct PhotoAttachmentCell: View {
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
                                withAnimation {
                                    let resolvedURL = asset.mediaType == .image ? assetJpgURL() : assetURL
                                    if let url = resolvedURL {
                                        onImageTap(
                                            AddedAsset(
                                                image: image,
                                                id: asset.localIdentifier,
                                                url: url,
                                                type: assetType,
                                                extraData: asset.mediaType == .video ? ["duration": .number(asset.duration)] : [:]
                                            )
                                        )
                                    }
                                    idOverlay = UUID()
                                }
                            }
                    }
                    .overlay(
                        (compressing || loading) ? ProgressView() : nil
                    )
                }
            } else {
                Color(colors.backgroundCoreSurface)
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
                        .fill(Color(colors.backgroundCoreSelected))
                }

                // Selection indicator (top-right)
                GallerySelectionIndicator(isSelected: selected)
                    .frame(width: 24, height: 24)
                    .padding(tokens.spacingXs)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)

                // Video duration badge (bottom-left)
                if asset.mediaType == .video {
                    VideoMediaBadge(durationText: utils.videoDurationFormatter.format(asset.duration) ?? "0:00")
                        .padding(tokens.spacingXs)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                }
            }
            .allowsHitTesting(false)
            .id(idOverlay)
        )
        .onAppear {
            loading = false
            
            assetLoader.loadImage(from: asset)
            
            if assetURL != nil {
                return
            }
            
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
                if let assetURL, assetLoader.assetExceedsAllowedSize(url: assetURL) {
                    compressing = true
                    assetLoader.compressAsset(at: assetURL, type: assetType) { url in
                        self.assetURL = url
                        compressing = false
                    }
                }
            }
        }
        .onDisappear {
            if let requestId {
                asset.cancelContentEditingInputRequest(requestId)
                self.requestId = nil
                loading = false
            }
        }
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

/// A circular selection indicator for gallery items.
///
/// - Unselected: A 24×24 hollow circle with a 2px white border.
/// - Selected: A 24×24 filled primary-blue circle with a white checkmark.
public struct GallerySelectionIndicator: View {
    @Injected(\.colors) private var colors

    public let isSelected: Bool

    public init(isSelected: Bool) {
        self.isSelected = isSelected
    }

    public var body: some View {
        ZStack {
            if isSelected {
                Circle()
                    .fill(Color(colors.accentPrimary))
                    .overlay(
                        Circle()
                            .strokeBorder(Color.white, lineWidth: 2)
                    )
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            } else {
                Circle()
                    .strokeBorder(Color.white, lineWidth: 2)
            }
        }
        .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
        .accessibilityLabel(isSelected ? "Selected" : "Not selected")
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
