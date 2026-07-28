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
    func test_itemView_onAppear_startsThumbnailLoadAndAssetPreparation() {
        // Given
        let assetLoader = PhotoAssetLoader_Mock()
        let asset = PHAsset_Mock(mediaType: .image)

        // When
        showView(
            AttachmentMediaPickerItemView(
                assetLoader: assetLoader,
                asset: asset,
                onImageTap: { _ in },
                imageSelected: { _ in false }
            )
        )
        waitForViewUpdates()

        // Then
        XCTAssertEqual(assetLoader.loadImageCalls.count, 1)
        XCTAssertTrue(assetLoader.loadImageCalls.first?.asset === asset)
        XCTAssertEqual(assetLoader.assetURLRequests.count, 1)
        XCTAssertEqual(assetLoader.assetURLRequests.first?.allowsNetworkAccess, false)
    }

    func test_itemView_onDisappear_cancelsPendingWork() {
        // Given
        let assetLoader = PhotoAssetLoader_Mock()
        assetLoader.completesAssetURLRequests = false
        assetLoader.assetURLRequestId = 7
        let asset = PHAsset_Mock(mediaType: .image)
        let hostingController = showView(
            AttachmentMediaPickerItemVisibilityTestView(
                assetLoader: assetLoader,
                asset: asset,
                isVisible: true
            )
        )
        waitForViewUpdates()

        // When
        hostingController.rootView = AttachmentMediaPickerItemVisibilityTestView(
            assetLoader: assetLoader,
            asset: asset,
            isVisible: false
        )
        hostingController.view.layoutIfNeeded()
        waitForViewUpdates()

        // Then
        XCTAssertEqual(assetLoader.cancelledImageLoads.count, 1)
        XCTAssertTrue(assetLoader.cancelledImageLoads.first === asset)
        XCTAssertEqual(assetLoader.cancelledRequestIds, [7])
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
