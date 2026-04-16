//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

class MediaViewer_Tests: StreamChatTestCase {
    func test_mediaViewer_snapshotLoading() {
        // Given
        let imageMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "test message",
            author: .mock(id: .unique, name: "Test"),
            attachments: ChatChannelTestHelpers.imageAttachments
        )

        // When
        let view = MediaViewer(
            imageAttachments: imageMessage.imageAttachments,
            author: imageMessage.author,
            isShown: .constant(true),
            selected: 0
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_mediaViewerHeader_snapshot() {
        // Given
        let header = MediaViewerHeader(
            title: "Test",
            subtitle: "Subtitle",
            isShown: .constant(true)
        )
        .frame(width: defaultScreenSize.width, height: 44)

        // Then
        assertSnapshot(matching: header, as: .image(perceptualPrecision: precision))
    }

    func test_mediaViewerHeader_withMessageCreatedToday_snapshot() {
        // Given
        let imageMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "test message",
            author: .mock(id: .unique, name: "Test"),
            createdAt: .now,
            attachments: ChatChannelTestHelpers.imageAttachments
        )

        // When
        let view = MediaViewer(
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

    func test_mediaViewerHeader_withMessageExactDate_snapshot() {
        // Given
        let imageMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "test message",
            author: .mock(id: .unique, name: "Test"),
            createdAt: Date(timeIntervalSince1970: 1_726_662_904),
            attachments: ChatChannelTestHelpers.imageAttachments
        )

        // When
        let view = MediaViewer(
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
            factory: DefaultViewFactory.shared,
            attachments: [MediaAttachment(url: ChatChannelTestHelpers.testURL, type: .image)]
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_gridViewVideoAndImage_snapshotLoading() {
        // Given
        let dummyVideoURL = URL(string: "https://example.com/test.mp4")!
        let videoAttachment = ChatMessageVideoAttachment(
            id: .unique,
            type: .video,
            payload: VideoAttachmentPayload(
                title: "test",
                videoRemoteURL: dummyVideoURL,
                file: AttachmentFile(type: .mp4, size: 0, mimeType: "video/mp4"),
                extraData: nil
            ),
            downloadingState: nil,
            uploadingState: nil
        )
        let view = GridMediaView(
            factory: DefaultViewFactory.shared,
            attachments: [
                MediaAttachment(url: ChatChannelTestHelpers.testURL, type: .image),
                MediaAttachment(from: videoAttachment)
            ]
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
}
