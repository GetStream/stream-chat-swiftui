//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

class MessageContainerView_Tests: StreamChatTestCase {

    override func setUp() {
        super.setUp()
        let utils = Utils(dateFormatter: EmptyDateFormatter())
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
    }

    func test_messageContainerViewSentThisUser_snapshot() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Message sent by current user",
            author: .mock(id: Self.currentUserId, name: "Martin"),
            isSentByCurrentUser: true
        )

        // When
        let view = testMessageViewContainer(message: message)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_messageContainerViewSentOtherUser_snapshot() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Message sent by other user",
            author: .mock(id: .unique, name: "Martin")
        )

        // When
        let view = testMessageViewContainer(message: message)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_messageContainerViewPinned_snapshot() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "This is a pinned message",
            author: .mock(id: .unique, name: "Martin"),
            pinDetails: MessagePinDetails(
                pinnedAt: Date(),
                pinnedBy: .mock(id: .unique, name: "Martin"),
                expiresAt: nil
            )
        )

        // When
        let view = testMessageViewContainer(message: message)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_videoAttachment_snapshotNoText() {
        // Given
        let attachment = ChatChannelTestHelpers.videoAttachment
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: .mock(id: .unique)
        )

        // When
        let view = VideoAttachmentView(
            attachment: attachment,
            message: message,
            width: 2 * defaultScreenSize.width / 3
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_videoAttachment_snapshotText() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Test message",
            author: .mock(id: .unique),
            attachments: ChatChannelTestHelpers.videoAttachments
        )

        // When
        let view = VideoAttachmentsContainer(
            factory: DefaultViewFactory.shared,
            message: message,
            width: 2 * defaultScreenSize.width / 3,
            scrolledId: .constant(nil)
        )
        .frame(width: 200)
        .padding()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_imageAttachments_snapshot() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Test message",
            author: .mock(id: .unique),
            attachments: ChatChannelTestHelpers.imageAttachments
        )

        // When
        let view = ImageAttachmentContainer(
            factory: DefaultViewFactory.shared,
            message: message,
            width: 200,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .frame(width: 200)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_imageAttachments_snapshotFiveImages() {
        // Given
        let attachment = ChatChannelTestHelpers.imageAttachments[0]
        let attachments = [AnyChatMessageAttachment](repeating: attachment, count: 5)
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Test message",
            author: .mock(id: .unique),
            attachments: attachments
        )

        // When
        let view = ImageAttachmentContainer(
            factory: DefaultViewFactory.shared,
            message: message,
            width: 200,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .frame(width: 200)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    // MARK: - private

    func testMessageViewContainer(message: ChatMessage) -> some View {
        MessageContainerView(
            factory: DefaultViewFactory.shared,
            channel: .mockDMChannel(),
            message: message,
            width: defaultScreenSize.width,
            showsAllInfo: true,
            isInThread: false,
            isLast: false,
            scrolledId: .constant(nil),
            quotedMessage: .constant(nil),
            onLongPress: { _ in }
        )
        .frame(width: 375, height: 200)
    }
}
