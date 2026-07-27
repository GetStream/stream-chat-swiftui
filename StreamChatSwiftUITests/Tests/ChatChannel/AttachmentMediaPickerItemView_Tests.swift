//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Photos
@testable import StreamChat
@testable import StreamChatSwiftUI
import SwiftUI
import XCTest

@MainActor class AttachmentMediaPickerItemView_Tests: StreamChatTestCase {
    // MARK: - Appear

    func test_itemView_onAppear_loadsThumbnailWithExpectedTargetSize() {
        // Given
        let assetLoader = PhotoAssetLoader_Mock()
        let asset = PHAsset_Mock()

        // When
        showView(makeItemView(assetLoader: assetLoader, asset: asset))
        waitForViewUpdates()

        // Then
        XCTAssertEqual(assetLoader.loadImageCalls.count, 1)
        XCTAssertTrue(assetLoader.loadImageCalls.first?.asset === asset)
        XCTAssertEqual(assetLoader.loadImageCalls.first?.targetSize, CGSize(width: 250, height: 250))
    }

    func test_itemView_onAppearWithImageAsset_requestsContentEditingInputWithoutNetworkAccess() {
        // Given
        let assetLoader = PhotoAssetLoader_Mock()
        let asset = PHAsset_Mock(mediaType: .image)

        // When
        showView(makeItemView(assetLoader: assetLoader, asset: asset))
        waitForViewUpdates()

        // Then
        XCTAssertEqual(asset.contentEditingInputRequests.count, 1)
        XCTAssertEqual(asset.contentEditingInputRequests.first?.isNetworkAccessAllowed, false)
    }

    func test_itemView_onAppearWithVideoAsset_doesNotRequestContentEditingInput() {
        // Given
        let assetLoader = PhotoAssetLoader_Mock()
        let asset = PHAsset_Mock(mediaType: .video, duration: 12)

        // When
        showView(makeItemView(assetLoader: assetLoader, asset: asset))
        waitForViewUpdates()

        // Then
        XCTAssertTrue(asset.contentEditingInputRequests.isEmpty)
        XCTAssertEqual(assetLoader.loadImageCalls.count, 1)
    }

    // MARK: - Disappear

    func test_itemView_onDisappear_cancelsThumbnailLoad() {
        // Given
        let assetLoader = PhotoAssetLoader_Mock()
        let asset = PHAsset_Mock()
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
    }

    func test_itemView_onDisappear_cancelsPendingContentEditingInputRequest() {
        // Given
        let assetLoader = PhotoAssetLoader_Mock()
        let asset = PHAsset_Mock(mediaType: .image)
        asset.contentEditingInputRequestId = 7
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
        XCTAssertEqual(asset.cancelledContentEditingInputRequestIds, [7])
    }

    func test_itemView_onDisappear_whenContentEditingInputResolvedSynchronously_doesNotCancelIt() {
        // Given
        let assetLoader = PhotoAssetLoader_Mock()
        let asset = PHAsset_Mock(mediaType: .image)
        asset.contentEditingInput = PHContentEditingInput_Mock(
            fullSizeImageURL: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("photo.heic")
        )
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
        XCTAssertTrue(asset.cancelledContentEditingInputRequestIds.isEmpty)
    }

    // MARK: - Helpers

    private func makeItemView(
        assetLoader: PhotoAssetLoader,
        asset: PHAsset,
        onImageTap: @escaping (AddedAsset) -> Void = { _ in }
    ) -> AttachmentMediaPickerItemView {
        AttachmentMediaPickerItemView(
            assetLoader: assetLoader,
            asset: asset,
            onImageTap: onImageTap,
            imageSelected: { _ in false }
        )
    }

    private func waitForViewUpdates(_ duration: TimeInterval = 0.5) {
        let expectation = expectation(description: "View updates processed")
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: duration + 2)
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
