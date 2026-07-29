//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Photos
@testable import StreamChat
@testable import StreamChatSwiftUI
import SwiftUI
import XCTest

/// The behavior itself lives in `MediaPickerAssetHandler` and is covered synchronously in
/// `MediaPickerAssetHandler_Tests`. These tests only verify that the view forwards its
/// lifecycle to the handler.
@MainActor class AttachmentMediaPickerItemView_Tests: StreamChatTestCase {
    func test_itemView_onAppear_startsThumbnailLoad() {
        // Given
        let assetLoader = PhotoAssetLoader_Mock()
        let asset = PHAsset_Mock(mediaType: .image)
        let thumbnailLoaded = expectation(description: "Thumbnail load started")
        assetLoader.onLoadImage = { thumbnailLoaded.fulfill() }

        // When
        showView(
            AttachmentMediaPickerItemView(
                assetLoader: assetLoader,
                asset: asset,
                onImageTap: { _ in },
                imageSelected: { _ in false }
            )
        )

        // Then
        wait(for: [thumbnailLoaded], timeout: defaultTimeout)
        XCTAssertEqual(assetLoader.loadImageCalls.count, 1)
        XCTAssertTrue(assetLoader.loadImageCalls.first?.asset === asset)
        XCTAssertTrue(assetLoader.assetURLRequests.isEmpty, "Assets are only resolved on tap")
    }

    func test_itemView_onDisappear_cancelsThumbnailLoad() {
        // Given
        let assetLoader = PhotoAssetLoader_Mock()
        let asset = PHAsset_Mock(mediaType: .image)
        let thumbnailLoaded = expectation(description: "Thumbnail load started")
        assetLoader.onLoadImage = { thumbnailLoaded.fulfill() }
        let hostingController = showView(
            AttachmentMediaPickerItemVisibilityTestView(
                assetLoader: assetLoader,
                asset: asset,
                isVisible: true
            )
        )
        wait(for: [thumbnailLoaded], timeout: defaultTimeout)

        // When
        let thumbnailLoadCancelled = expectation(description: "Thumbnail load cancelled")
        assetLoader.onCancelImageLoad = { thumbnailLoadCancelled.fulfill() }
        hostingController.rootView = AttachmentMediaPickerItemVisibilityTestView(
            assetLoader: assetLoader,
            asset: asset,
            isVisible: false
        )
        hostingController.view.layoutIfNeeded()

        // Then
        wait(for: [thumbnailLoadCancelled], timeout: defaultTimeout)
        XCTAssertEqual(assetLoader.cancelledImageLoads.count, 1)
        XCTAssertTrue(assetLoader.cancelledImageLoads.first === asset)
    }
}

@MainActor
private struct AttachmentMediaPickerItemVisibilityTestView: View {
    let assetLoader: PhotoAssetLoader
    let asset: PHAsset
    var isVisible: Bool

    var body: some View {
        VStack {
            if isVisible {
                AttachmentMediaPickerItemView(
                    assetLoader: assetLoader,
                    asset: asset,
                    onImageTap: { _ in },
                    imageSelected: { _ in false }
                )
            }
        }
    }
}
