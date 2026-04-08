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
                                withAnimation {
                                    let resolvedURL = asset.mediaType == .image ? assetJpgURL() : assetURL
                                    if let url = resolvedURL {
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

    private var assetDurationText: String {
        utils.mediaBadgeDurationFormatter.longFormat(asset.duration)
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
