//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Photos
import StreamChat
import SwiftUI

/// View for the media attachment picker.
/// Handles three states: loading (assets not yet fetched),
/// access denied / empty library, and the asset grid.
public struct AttachmentMediaPickerView: View {
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images
    @Injected(\.tokens) private var tokens
    
    // Held as state so that the loader, and with it its cache and in-flight requests, survives
    // view updates. It publishes nothing, so there is nothing to observe.
    @State var assetLoader: PhotoAssetLoader

    var photoLibraryAssets: PHFetchResult<PHAsset>?
    var onImageTap: (AddedAsset) -> Void
    var imageSelected: (String) -> Bool
    var selectedAssetIds: [String]?
    var isDisplayed: Bool

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
        selectedAssetIds: [String]? = nil,
        isDisplayed: Bool = false
    ) {
        _assetLoader = State(initialValue: assetLoader)
        self.photoLibraryAssets = photoLibraryAssets
        self.onImageTap = onImageTap
        self.imageSelected = imageSelected
        self.selectedAssetIds = selectedAssetIds
        self.isDisplayed = isDisplayed
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
        ScrollViewReader { scrollView in
            ScrollView {
                LazyVGrid(columns: columns, spacing: 2) {
                    // Keyed by index so ForEach updates never touch the fetch result.
                    // Asset-keyed ForEach re-materializes PHAssets from Photos for every
                    // instantiated row on each update, which hangs large libraries.
                    ForEach(0..<collection.count, id: \.self) { index in
                        MediaPickerCellView(
                            assetLoader: assetLoader,
                            assets: collection,
                            index: index,
                            onImageTap: onImageTap,
                            imageSelected: imageSelected,
                            selectedAssetIds: selectedAssetIdsSet
                        )
                        .equatable()
                    }
                }
                .animation(nil)
            }
            .onChange(of: collection.count) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    UIAccessibility.post(notification: .screenChanged, argument: nil)
                }
            }
            .onChange(of: isDisplayed) { displayed in
                if displayed {
                    // The picker stays in the view hierarchy while hidden, so reset to
                    // the top when it is shown again.
                    scrollView.scrollTo(0, anchor: .top)
                } else {
                    // Cells do not disappear when the picker is only hidden, so cancel
                    // explicitly. A fast scroll can also leave requests that never got an
                    // onDisappear.
                    assetLoader.cancelAllImageLoads()
                }
            }
        }
    }

    private var accessDeniedContent: some View {
        PhotoLibraryAccessPromptView()
    }
}

/// Defers `PHAsset` resolution until the body runs, and skips that body for off-screen
/// rows via `Equatable` so composer updates do not hit the Photos database.
private struct MediaPickerCellView: View, Equatable {
    let assetLoader: PhotoAssetLoader
    let assets: PHFetchResultCollection
    let index: Int
    let onImageTap: (AddedAsset) -> Void
    let imageSelected: (String) -> Bool
    let selectedAssetIds: Set<String>?

    var body: some View {
        let asset = assets[index]
        AttachmentMediaPickerItemView(
            assetLoader: assetLoader,
            asset: asset,
            onImageTap: onImageTap,
            imageSelected: imageSelected,
            selectedAssetIds: selectedAssetIds
        )
        // Reset item state if a different asset lands on this index.
        .id(asset.localIdentifier)
    }

    // Selection flows through `selectedAssetIds`. When it is nil, selection comes from
    // the uncomparable `imageSelected` closure, so the cell is treated as always changed.
    nonisolated static func == (lhs: MediaPickerCellView, rhs: MediaPickerCellView) -> Bool {
        guard lhs.selectedAssetIds != nil, rhs.selectedAssetIds != nil else { return false }
        return lhs.index == rhs.index
            && lhs.assets.fetchResult === rhs.assets.fetchResult
            && lhs.selectedAssetIds == rhs.selectedAssetIds
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
