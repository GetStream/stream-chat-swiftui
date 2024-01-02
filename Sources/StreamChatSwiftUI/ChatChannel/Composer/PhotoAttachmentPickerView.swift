//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Photos
import SwiftUI

/// View for the photo attachment picker.
public struct PhotoAttachmentPickerView: View {
    
    @Injected(\.colors) private var colors
    
    @StateObject var assetLoader = PhotoAssetLoader()
    
    var assets: PHFetchResultCollection
    var onImageTap: (AddedAsset) -> Void
    var imageSelected: (String) -> Bool
    
    let columns = [GridItem(.adaptive(minimum: 120), spacing: 2)]
    
    public init(
        assets: PHFetchResultCollection,
        onImageTap: @escaping (AddedAsset) -> Void,
        imageSelected: @escaping (String) -> Bool
    ) {
        self.assets = assets
        self.onImageTap = onImageTap
        self.imageSelected = imageSelected
    }
    
    public var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(assets) { asset in
                    PhotoAttachmentCell(
                        assetLoader: assetLoader,
                        asset: asset,
                        onImageTap: onImageTap,
                        imageSelected: imageSelected
                    )
                }
            }
            .padding(.horizontal, 2)
            .animation(nil)
        }
    }
}

/// Photo cell displayed in the picker view.
public struct PhotoAttachmentCell: View {
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images
    @Injected(\.fonts) private var fonts
    
    @StateObject var assetLoader: PhotoAssetLoader
    
    @State private var assetURL: URL?
    @State private var compressing = false
    @State private var loading = false
    @State var requestId: PHContentEditingInputRequestID?
    
    var asset: PHAsset
    var onImageTap: (AddedAsset) -> Void
    var imageSelected: (String) -> Bool
    
    private var assetType: AssetType {
        asset.mediaType == .video ? .video : .image
    }
    
    public var body: some View {
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
                            .opacity(0.000001)
                            .frame(width: reader.size.width, height: reader.size.height)
                            .clipped()
                            .allowsHitTesting(true)
                            .onTapGesture {
                                withAnimation {
                                    if let assetURL = assetURL {
                                        onImageTap(
                                            AddedAsset(
                                                image: image,
                                                id: asset.localIdentifier,
                                                url: assetURL,
                                                type: assetType,
                                                extraData: asset
                                                    .mediaType == .video ? ["duration": .string(asset.durationString)] : [:]
                                            )
                                        )
                                    }
                                }
                            }
                    }
                    .overlay(
                        (compressing || loading) ? ProgressView() : nil
                    )
                }
            } else {
                Color(colors.background1)
                    .aspectRatio(1, contentMode: .fill)
                
                Image(uiImage: images.imagePlaceholder)
                    .customizable()
                    .frame(height: 56)
                    .foregroundColor(Color(colors.background2))
            }
        }
        .aspectRatio(1, contentMode: .fill)
        .overlay(
            ZStack {
                if imageSelected(asset.localIdentifier) {
                    TopRightView {
                        Image(uiImage: images.checkmarkFilled)
                            .renderingMode(.template)
                            .scaledToFit()
                            .applyDefaultIconOverlayStyle()
                    }
                }
                
                if asset.mediaType == .video {
                    VideoIndicatorView()
                    
                    VideoDurationIndicatorView(
                        duration: asset.durationString
                    )
                }
            }
        )
        .onAppear {
            self.loading = false
            
            assetLoader.loadImage(from: asset)
            
            if self.assetURL != nil {
                return
            }
            
            let options = PHContentEditingInputRequestOptions()
            options.isNetworkAccessAllowed = true
            self.loading = true
            
            self.requestId = asset.requestContentEditingInput(with: options) { input, _ in
                self.loading = false
                if asset.mediaType == .image {
                    self.assetURL = input?.fullSizeImageURL
                } else if let url = (input?.audiovisualAsset as? AVURLAsset)?.url {
                    self.assetURL = url
                }
                
                // Check file size.
                if let assetURL = assetURL, assetLoader.assetExceedsAllowedSize(url: assetURL) {
                    compressing = true
                    assetLoader.compressAsset(at: assetURL, type: assetType) { url in
                        self.assetURL = url
                        self.compressing = false
                    }
                }
            }
        }
        .onDisappear() {
            if let requestId = requestId {
                asset.cancelContentEditingInputRequest(requestId)
                self.requestId = nil
                loading = false
            }
        }
    }
}
