//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Photos
import StreamChat
import StreamChatCommonUI
import SwiftUI

/// View for the media attachment picker.
/// Handles three states: loading (assets not yet fetched),
/// access denied / empty library, and the asset grid.
public struct AttachmentMediaPickerView: View {
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images
    @Injected(\.tokens) private var tokens
    
    @StateObject var assetLoader: PhotoAssetLoader
    
    var photoLibraryAssets: PHFetchResult<PHAsset>?
    var onImageTap: (AddedAsset) -> Void
    var imageSelected: (String) -> Bool
    var selectedAssetIds: [String]?
    
    private var selectedAssetIdsSet: Set<String>? {
        guard let selectedAssetIds else { return nil }
        return Set(selectedAssetIds)
    }
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)

    public init(
        assetLoader: PhotoAssetLoader = PhotoAssetLoader(),
        photoLibraryAssets: PHFetchResult<PHAsset>?,
        onImageTap: @escaping (AddedAsset) -> Void,
        imageSelected: @escaping (String) -> Bool,
        selectedAssetIds: [String]? = nil
    ) {
        _assetLoader = StateObject(wrappedValue: assetLoader)
        self.photoLibraryAssets = photoLibraryAssets
        self.onImageTap = onImageTap
        self.imageSelected = imageSelected
        self.selectedAssetIds = selectedAssetIds
    }
    
    public var body: some View {
        Group {
            if let fetchResult = photoLibraryAssets {
                let collection = PHFetchResultCollection(fetchResult: fetchResult)
                if !collection.isEmpty {
                    assetGridContent(collection: collection)
                } else {
                    accessDeniedContent
                }
            } else {
                LoadingView()
            }
        }
        .background(Color(colors.backgroundCoreElevation1))
    }

    // MARK: - Private

    private func assetGridContent(collection: PHFetchResultCollection) -> some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(collection) { asset in
                    AttachmentMediaPickerItemView(
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

    private var accessDeniedContent: some View {
        PhotoLibraryAccessPromptView()
    }
}

/// Prompt view displayed when the user has not granted access to the photo library.
public struct PhotoLibraryAccessPromptView: View {
    @Injected(\.images) private var images

    public init() {}

    public var body: some View {
        AttachmentPickerPromptView(
            image: Image(uiImage: images.attachmentPhotoIcon),
            description: L10n.Composer.Images.noAccessLibrary,
            buttonText: L10n.Composer.Images.accessSettings,
            onTap: {
                openSettings()
            }
        )
    }
}
