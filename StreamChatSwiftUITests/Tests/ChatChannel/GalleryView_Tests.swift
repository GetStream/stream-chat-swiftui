//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

class GalleryView_Tests: StreamChatTestCase {

    func test_galleryView_snapshotLoading() {
        // Given
        let imageMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "test message",
            author: .mock(id: .unique),
            attachments: ChatChannelTestHelpers.imageAttachments
        )

        // When
        let view = GalleryView(
            imageAttachments: imageMessage.imageAttachments,
            author: imageMessage.author,
            isShown: .constant(true),
            selected: 0
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_galleryHeader_snapshot() {
        // Given
        let header = GalleryHeaderView(
            title: "Test",
            subtitle: "Subtitle",
            isShown: .constant(true)
        )
        .frame(width: defaultScreenSize.width, height: 44)

        // Then
        assertSnapshot(matching: header, as: .image(perceptualPrecision: precision))
    }

    func test_gridView_snapshotLoading() {
        // Given
        let view = GridPhotosView(
            imageURLs: [ChatChannelTestHelpers.testURL],
            isShown: .constant(true)
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
}
