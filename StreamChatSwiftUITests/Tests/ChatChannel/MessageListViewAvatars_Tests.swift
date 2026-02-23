//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import XCTest

@MainActor class MessageListViewAvatars_Tests: StreamChatTestCase {
    override func setUp() {
        super.setUp()
        DelayedRenderingViewModifier.isEnabled = false
    }
    
    override func tearDown() {
        super.tearDown()
        DelayedRenderingViewModifier.isEnabled = true
    }
    
    func test_messageListView_defaultDMChannel() {
        // Given
        setupConfig(showIncomingMessageAvatar: true)
        let channel = ChatChannel.mockDMChannel()

        // When
        let view = makeMessageListView(with: channel).applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_messageListView_defaultGroupsChannel() {
        // Given
        setupConfig(showIncomingMessageAvatar: true)
        let channel = ChatChannel.mockNonDMChannel()

        // When
        let view = makeMessageListView(with: channel).applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_messageListView_dmChannelAvatarsOff() {
        // Given
        setupConfig(showIncomingMessageAvatar: false)
        let channel = ChatChannel.mockDMChannel()

        // When
        let view = makeMessageListView(with: channel).applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_messageListView_groupsChannelAvatarsOff() {
        // Given
        setupConfig(showIncomingMessageAvatar: true, showAvatarsInGroups: false)
        let channel = ChatChannel.mockNonDMChannel()

        // When
        let view = makeMessageListView(with: channel).applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    private func setupConfig(
        showIncomingMessageAvatar: Bool = true,
        showOutgoingMessageAvatar: Bool = false,
        showAvatarsInGroups: Bool = true
    ) {
        let messageDisplayOptions = MessageDisplayOptions(
            showIncomingMessageAvatar: showIncomingMessageAvatar,
            showOutgoingMessageAvatar: showOutgoingMessageAvatar,
            showAvatarsInGroups: showAvatarsInGroups
        )
        let messageListConfig = MessageListConfig(messageDisplayOptions: messageDisplayOptions)
        let utils = Utils(messageListConfig: messageListConfig)
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
    }

    private func makeMessageListView(with channel: ChatChannel) -> MessageListView<DefaultViewFactory> {
        let temp = [ChatMessage.mock(
            id: .unique,
            cid: channel.cid,
            text: "Test",
            author: .mock(id: .unique)
        )]
        let messages = temp
        let messageListView = MessageListView(
            factory: DefaultViewFactory.shared,
            channel: channel,
            messages: messages,
            messagesGroupingInfo: [:],
            scrolledId: .constant(nil),
            showScrollToLatestButton: .constant(false),
            quotedMessage: .constant(nil),
            currentDateString: nil,
            listId: "listId",
            isMessageThread: false,
            shouldShowTypingIndicator: false,
            onMessageAppear: { _, _ in },
            onScrollToBottom: {},
            onLongPress: { _ in }
        )

        return messageListView
    }
}
