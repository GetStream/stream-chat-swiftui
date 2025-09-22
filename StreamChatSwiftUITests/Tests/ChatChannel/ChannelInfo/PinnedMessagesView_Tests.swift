//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

@testable import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

class PinnedMessagesView_Tests: StreamChatTestCase {
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
        AssertSnapshot(view, size: defaultScreenSize)
    }
    
    func test_pinnedMessagesView_themedSnapshot() {
        // Given
        setThemedNavigationBarAppearance()
        let channel = ChatChannel.mockDMChannel(
            pinnedMessages: [ChannelInfoMockUtils.pinnedMessage]
        )

        // When
        let view = NavigationContainerView(embedInNavigationView: true) {
            PinnedMessagesView(channel: channel)
        }.applyDefaultSize()

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
