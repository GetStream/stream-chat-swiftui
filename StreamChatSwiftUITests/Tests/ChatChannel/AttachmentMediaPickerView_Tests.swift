//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Photos
@testable import StreamChat
@testable import StreamChatSwiftUI
import SwiftUI
import XCTest

@MainActor class AttachmentMediaPickerView_Tests: StreamChatTestCase {
    func test_mediaPickerView_whenNoLongerDisplayed_cancelsAllImageLoads() {
        // Given
        let assetLoader = PhotoAssetLoader_Mock()
        let fetchResult = PHFetchResult_Mock(assets: [PHAsset_Mock(id: "asset-0")])
        let hostingController = showView(
            makePickerView(assetLoader: assetLoader, fetchResult: fetchResult, isDisplayed: true)
        )

        // When
        let imageLoadsCancelled = expectation(description: "Image loads cancelled")
        assetLoader.onCancelAllImageLoads = { imageLoadsCancelled.fulfill() }
        hostingController.rootView = makePickerView(
            assetLoader: assetLoader,
            fetchResult: fetchResult,
            isDisplayed: false
        )
        hostingController.view.layoutIfNeeded()

        // Then
        wait(for: [imageLoadsCancelled], timeout: defaultTimeout)
        XCTAssertEqual(assetLoader.cancelAllImageLoadsCallCount, 1)
    }

    func test_mediaPickerView_whenStillDisplayed_doesNotCancelImageLoads() {
        // Given
        let assetLoader = PhotoAssetLoader_Mock()
        let fetchResult = PHFetchResult_Mock(assets: [PHAsset_Mock(id: "asset-0")])
        let hostingController = showView(
            makePickerView(assetLoader: assetLoader, fetchResult: fetchResult, isDisplayed: true)
        )

        // When
        let imageLoadsCancelled = expectation(description: "Image loads cancelled")
        imageLoadsCancelled.isInverted = true
        assetLoader.onCancelAllImageLoads = { imageLoadsCancelled.fulfill() }
        hostingController.rootView = makePickerView(
            assetLoader: assetLoader,
            fetchResult: fetchResult,
            isDisplayed: true
        )
        hostingController.view.layoutIfNeeded()

        // Then
        wait(for: [imageLoadsCancelled], timeout: defaultTimeoutForInversedExpecations)
        XCTAssertEqual(assetLoader.cancelAllImageLoadsCallCount, 0)
    }

    // MARK: - Helpers

    private func makePickerView(
        assetLoader: PhotoAssetLoader,
        fetchResult: PHFetchResult<PHAsset>,
        isDisplayed: Bool
    ) -> AttachmentMediaPickerView {
        AttachmentMediaPickerView(
            assetLoader: assetLoader,
            photoLibraryAssets: fetchResult,
            onImageTap: { _ in },
            imageSelected: { _ in false },
            selectedAssetIds: [],
            isDisplayed: isDisplayed
        )
    }
}
