//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Photos
import StreamChatCommonUI
import SwiftUI

/// View for the media attachment picker.
public struct AttachmentMediaPickerView: View {
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
}
