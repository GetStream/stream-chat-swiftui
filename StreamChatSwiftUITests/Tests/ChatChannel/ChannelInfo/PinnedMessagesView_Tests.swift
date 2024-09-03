//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

@testable import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

class PinnedMessagesView_Tests: StreamChatTestCase {

    override func setUp() {
        super.setUp()
        let utils = Utils(dateFormatter: EmptyDateFormatter())
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
    }

    func test_pinnedMessagesView_notEmptySnapshot() {
        // Given
        let channel = ChatChannel.mockDMChannel(
            pinnedMessages: [ChannelInfoMockUtils.pinnedMessage]
        )

        // When
        let view = PinnedMessagesView(channel: channel)
            .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_pinnedMessagesView_imageSnapshot() {
        // Given
        let pinnedMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: .mock(id: .unique, name: "Test User"),
            attachments: ChatChannelTestHelpers.imageAttachments,
            pinDetails: MessagePinDetails(
                pinnedAt: Date(),
                pinnedBy: .mock(id: .unique),
                expiresAt: nil
            )
        )
        let channel = ChatChannel.mockDMChannel(
            pinnedMessages: [pinnedMessage]
        )

        // When
        let view = PinnedMessagesView(channel: channel)
            .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_pinnedMessagesView_videoSnapshot() {
        // Given
        let pinnedMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: .mock(id: .unique, name: "Test User"),
            attachments: ChatChannelTestHelpers.videoAttachments,
            pinDetails: MessagePinDetails(
                pinnedAt: Date(),
                pinnedBy: .mock(id: .unique),
                expiresAt: nil
            )
        )
        let channel = ChatChannel.mockDMChannel(
            pinnedMessages: [pinnedMessage]
        )

        // When
        let view = PinnedMessagesView(channel: channel)
            .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_pinnedMessagesView_pollSnapshot() {
        // Given
        let pinnedMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: .mock(id: .unique, name: "Test User"),
            pinDetails: MessagePinDetails(
                pinnedAt: Date(),
                pinnedBy: .mock(id: .unique),
                expiresAt: nil
            ),
            poll: .mock()
        )
        let channel = ChatChannel.mockDMChannel(
            pinnedMessages: [pinnedMessage]
        )

        // When
        let view = PinnedMessagesView(channel: channel)
            .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_pinnedMessagesView_emptySnapshot() {
        // Given
        let channel = ChatChannel.mockDMChannel()

        // When
        let view = PinnedMessagesView(channel: channel)
            .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
}

// Temp solution for failing tests.
class EmptyDateFormatter: DateFormatter {

    override func string(from date: Date) -> String {
        ""
    }
}
