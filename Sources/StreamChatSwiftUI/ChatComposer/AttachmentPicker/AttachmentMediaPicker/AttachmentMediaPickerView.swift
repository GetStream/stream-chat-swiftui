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
    
    @StateObject var assetLoader: PhotoAssetLoader

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
        _assetLoader = StateObject(wrappedValue: assetLoader)
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
                    // Keyed by index so that ForEach updates never touch the fetch result.
                    // An asset-keyed ForEach re-materializes a `PHAsset` from the Photos
                    // database for every instantiated row on each update, which hangs the
                    // main thread for large libraries.
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
                if !displayed {
                    // The picker stays in the view hierarchy while hidden, so scroll
                    // back to the top for the next presentation and drop any pending
                    // thumbnail work from the previous scroll position.
                    assetLoader.cancelAllImageLoads()
                    scrollView.scrollTo(0, anchor: .top)
                }
            }
        }
    }

    private var accessDeniedContent: some View {
        PhotoLibraryAccessPromptView()
    }
}

/// Grid cell that defers resolving the `PHAsset` until its body runs, so that only
/// rows that actually render hit the Photos database. The `Equatable` conformance lets
/// SwiftUI skip the body of the (potentially thousands of) instantiated off-screen rows
/// on every composer update.
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
        // Rows are keyed by index, so if the library changes and another asset lands on
        // this position, this identity change resets the item's internal state.
        .id(asset.localIdentifier)
    }

    // Selection changes flow through `selectedAssetIds`; the callbacks are intentionally
    // not compared. When `selectedAssetIds` is nil the selection state comes from the
    // `imageSelected` closure, which cannot be compared, so the cell is treated as
    // always changed.
    nonisolated static func == (lhs: MediaPickerCellView, rhs: MediaPickerCellView) -> Bool {
        guard lhs.selectedAssetIds != nil, rhs.selectedAssetIds != nil else { return false }
        return lhs.index == rhs.index
            && lhs.assets.fetchResult === rhs.assets.fetchResult
            && lhs.selectedAssetIds == rhs.selectedAssetIds
            && lhs.assetLoader === rhs.assetLoader
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
