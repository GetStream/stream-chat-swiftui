//
// Copyright © 2026 Stream.io Inc. All rights reserved.
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

    func test_galleryHeader_withMessageCreatedToday_snapshot() {
        // Given
        let imageMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "test message",
            author: .mock(id: .unique),
            createdAt: .now,
            attachments: ChatChannelTestHelpers.imageAttachments
        )

        // When
        let view = GalleryView(
            imageAttachments: imageMessage.imageAttachments,
            author: imageMessage.author,
            isShown: .constant(true),
            selected: 0,
            message: imageMessage
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_galleryHeader_withMessageExactDate_snapshot() {
        // Given
        let imageMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "test message",
            author: .mock(id: .unique),
            createdAt: Date(timeIntervalSince1970: 1_726_662_904),
            attachments: ChatChannelTestHelpers.imageAttachments
        )

        // When
        let view = GalleryView(
            imageAttachments: imageMessage.imageAttachments,
            author: imageMessage.author,
            isShown: .constant(true),
            selected: 0,
            message: imageMessage
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_gridView_snapshotLoading() {
        // Given
        let view = GridMediaView(
            attachments: [MediaAttachment(url: ChatChannelTestHelpers.testURL, type: .image)],
            isShown: .constant(true)
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_gridViewVideoAndImage_snapshotLoading() {
        // Given
        let view = GridMediaView(
            attachments: [
                MediaAttachment(url: ChatChannelTestHelpers.testURL, type: .image),
                MediaAttachment(url: ChatChannelTestHelpers.testURL.appendingPathComponent("test"), type: .video)
            ],
            isShown: .constant(true)
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
}
