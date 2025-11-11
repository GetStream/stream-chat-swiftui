//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

@testable import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

class MessageListView_Tests: StreamChatTestCase {
    override func setUp() {
        super.setUp()
        DelayedRenderingViewModifier.isEnabled = false
    }
    
    override func tearDown() {
        super.tearDown()
        DelayedRenderingViewModifier.isEnabled = true
    }
    
    func test_messageListView_withReactions() {
        // Given
        let channelConfig = ChannelConfig(reactionsEnabled: true)
        let messageListView = makeMessageListView(channelConfig: channelConfig)
            .applyDefaultSize()

        // Then
        assertSnapshot(matching: messageListView, as: .image(perceptualPrecision: precision))
    }

    func test_messageListView_noReactions() {
        // Given
        let channelConfig = ChannelConfig(reactionsEnabled: false)
        let messageListView = makeMessageListView(channelConfig: channelConfig)
            .applyDefaultSize()

        // Then
        assertSnapshot(matching: messageListView, as: .image(perceptualPrecision: precision))
    }

    func test_scrollToBottomButton_snapshotUnreadCount() {
        // Given
        let button = ScrollToBottomButton(unreadCount: 3, onScrollToBottom: {})

        // Then
        assertSnapshot(matching: button, as: .image(perceptualPrecision: precision))
    }

    func test_scrollToBottomButton_snapshotEmptyCount() {
        // Given
        let button = ScrollToBottomButton(unreadCount: 0, onScrollToBottom: {})

        // Then
        assertSnapshot(matching: button, as: .image(perceptualPrecision: precision))
    }

    func test_messageListView_typingIndicator() {
        // Given
        let channelConfig = ChannelConfig(reactionsEnabled: true)
        let typingUser = ChatUser.mock(id: "martin", name: "Martin")
        let messageListView = makeMessageListView(
            channelConfig: channelConfig,
            currentlyTypingUsers: [typingUser]
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: messageListView, as: .image(perceptualPrecision: precision))
    }

    func test_messageListView_snapshotFallback() {
        // Given
        let channelConfig = ChannelConfig(reactionsEnabled: true)
        let messageListView = makeMessageListView(channelConfig: channelConfig)
            .applyDefaultSize()

        // When
        let snapshotCreator = DefaultSnapshotCreator()
        let snapshot = snapshotCreator.makeSnapshot(for: AnyView(messageListView))
        let view = Image(uiImage: snapshot)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_messageListView_jumpToUnreadButton() {
        // Given
        let channelConfig = ChannelConfig(reactionsEnabled: true)
        let view = makeMessageListView(
            channelConfig: channelConfig,
            unreadCount: .mock(messages: 3)
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    // MARK: - Init with ChatChannelViewModel snapshot tests

    func test_messageListView_viewModelInit_withReactions() {
        // Given
        let channel = ChatChannel.mockDMChannel(config: .init(reactionsEnabled: true))
        let view = makeMessageListViewWithViewModel(channel: channel, messages: [.mock(id: .unique, cid: channel.cid, text: "Hello", author: .mock(id: .unique), reactionScores: [MessageReactionType(rawValue: "like"): 1])])
            .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_messageListView_viewModelInit_noReactions() {
        // Given
        let channel = ChatChannel.mockDMChannel(config: .init(reactionsEnabled: false))
        let view = makeMessageListViewWithViewModel(channel: channel, messages: [.mock(id: .unique, cid: channel.cid, text: "Hello", author: .mock(id: .unique))])
            .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_messageListView_viewModelInit_unreadIndicator() {
        // Given
        var channel = ChatChannel.mockDMChannel()
        // Set unread count on the channel
        channel = ChatChannel.mockDMChannel(unreadCount: .mock(messages: 2))
        let view = makeMessageListViewWithViewModel(channel: channel, messages: [.mock(id: .unique, cid: channel.cid, text: "Unread 1", author: .mock(id: .unique))])
            .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    // MARK: - private

    func makeMessageListView(
        channelConfig: ChannelConfig,
        unreadCount: ChannelUnreadCount = .noUnread,
        currentlyTypingUsers: Set<ChatUser> = []
    ) -> MessageListView<DefaultViewFactory> {
        let reactions = [MessageReactionType(rawValue: "like"): 2]
        let channel = ChatChannel.mockDMChannel(
            config: channelConfig,
            currentlyTypingUsers: currentlyTypingUsers,
            unreadCount: unreadCount
        )
        let temp = [ChatMessage.mock(
            id: .unique,
            cid: channel.cid,
            text: "Test",
            author: .mock(id: .unique),
            reactionScores: reactions
        )]
        let messages = LazyCachedMapCollection(source: temp, map: { $0 })
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
            shouldShowTypingIndicator: !currentlyTypingUsers.isEmpty,
            onMessageAppear: { _, _ in },
            onScrollToBottom: {},
            onLongPress: { _ in }
        )

        return messageListView
    }

    private func makeMessageListViewWithViewModel(
        channel: ChatChannel,
        messages: [ChatMessage]
    ) -> MessageListView<DefaultViewFactory> {
        // Create a mock channel controller seeded with channel and messages
        let controller = ChatChannelTestHelpers.makeChannelController(
            chatClient: chatClient,
            chatChannel: channel,
            messages: messages
        )

        // Build the view model
        let viewModel = ChatChannelViewModel(channelController: controller)

        // Return the view using the new initializer
        return MessageListView(
            factory: DefaultViewFactory.shared,
            channel: channel,
            viewModel: viewModel
        )
    }
}
