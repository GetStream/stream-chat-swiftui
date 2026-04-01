//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

@MainActor class MessageListView_Tests: StreamChatTestCase {
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
        let button = ScrollToBottomButton(factory: DefaultViewFactory.shared, unreadCount: 3, onScrollToBottom: {})

        // Then
        AssertSnapshot(button)
    }

    func test_scrollToBottomButton_snapshotEmptyCount() {
        // Given
        let button = ScrollToBottomButton(factory: DefaultViewFactory.shared, unreadCount: 0, onScrollToBottom: {})

        // Then
        AssertSnapshot(button)
    }

    func test_scrollToBottomButton_snapshotHighUnreadCount() {
        // Given
        let button = ScrollToBottomButton(factory: DefaultViewFactory.shared, unreadCount: 16, onScrollToBottom: {})

        // Then
        AssertSnapshot(button)
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
    
    func test_messageListView_systemMessage() {
        // Given
        let channel = ChatChannel.mockDMChannel()
        let author1 = ChatUser.mock(id: "martin", name: "Martin")
        let author2 = ChatUser.mock(id: "system", name: "system")
        let systemMessage = ChatMessage.mock(
            id: .unique,
            cid: channel.cid,
            text: "Martin created the channel",
            type: .system,
            author: author2
        )
        let messages: [ChatMessage] = [
            systemMessage,
            .mock(id: .unique, cid: channel.cid, text: "Hey, welcome everyone!", author: author1),
            .mock(id: .unique, cid: channel.cid, text: "Thanks for adding me!", author: author1),
            .mock(id: .unique, cid: channel.cid, text: "Hello!", author: author1)
        ]
        let view = MessageListView(
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
        .applyDefaultSize()

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
        AssertSnapshot(view)
    }

    func test_messageListView_groupChannel_withReactions() {
        // Given
        let channelConfig = ChannelConfig(reactionsEnabled: true)
        let channel = ChatChannel.mockNonDMChannel(config: channelConfig)
        let author1 = ChatUser.mock(id: "alice", name: "Alice")
        let author2 = ChatUser.mock(id: "bob", name: "Bob")
        let author3 = ChatUser.mock(id: "charlie", name: "Charlie")
        let messages: [ChatMessage] = [
            .mock(
                id: .unique,
                cid: channel.cid,
                text: "Hey everyone, good morning!",
                author: author1,
                reactionScores: [
                    MessageReactionType(rawValue: "like"): 3,
                    MessageReactionType(rawValue: "love"): 1
                ],
                reactionCounts: [
                    MessageReactionType(rawValue: "like"): 3,
                    MessageReactionType(rawValue: "love"): 1
                ]
            ),
            .mock(
                id: .unique,
                cid: channel.cid,
                text: "Good morning! Hope you all have a great day.",
                author: author2,
                reactionScores: [
                    MessageReactionType(rawValue: "like"): 1
                ],
                reactionCounts: [
                    MessageReactionType(rawValue: "like"): 1
                ]
            ),
            .mock(
                id: .unique,
                cid: channel.cid,
                text: "Same to you!",
                author: author3
            ),
            .mock(
                id: .unique,
                cid: channel.cid,
                text: "Has anyone seen the latest updates?",
                author: author1,
                reactionScores: [
                    MessageReactionType(rawValue: "haha"): 2,
                    MessageReactionType(rawValue: "like"): 4
                ],
                reactionCounts: [
                    MessageReactionType(rawValue: "haha"): 2,
                    MessageReactionType(rawValue: "like"): 4
                ]
            ),
            .mock(
                id: .unique,
                cid: channel.cid,
                text: "Yes, they look amazing!",
                author: author2
            )
        ]
        let view = MessageListView(
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
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    // MARK: - MessageListDivider

    func test_messageListView_threadRepliesSeparator() {
        // Given
        let channel = ChatChannel.mockDMChannel()
        let parentId: MessageId = "parent-id"
        let parentMessage = ChatMessage.mock(
            id: parentId,
            cid: channel.cid,
            text: "Which item has priority?",
            author: .mock(id: "user1", name: "Wesley"),
            replyCount: 2
        )
        let reply1 = ChatMessage.mock(
            id: "reply1",
            cid: channel.cid,
            text: "I think the first one is the most important.",
            author: .mock(id: "user2", name: "Emma"),
            parentMessageId: parentId
        )
        let reply2 = ChatMessage.mock(
            id: "reply2",
            cid: channel.cid,
            text: "Agreed, let's prioritize that.",
            author: .mock(id: "user1", name: "Wesley"),
            parentMessageId: parentId,
            isSentByCurrentUser: true
        )
        let messages: [ChatMessage] = [reply2, reply1, parentMessage]
        let view = MessageListView(
            factory: DefaultViewFactory.shared,
            channel: channel,
            messages: messages,
            messagesGroupingInfo: [:],
            scrolledId: .constant(nil),
            showScrollToLatestButton: .constant(false),
            quotedMessage: .constant(nil),
            currentDateString: nil,
            listId: "listId",
            isMessageThread: true,
            shouldShowTypingIndicator: false,
            onMessageAppear: { _, _ in },
            onScrollToBottom: {},
            onLongPress: { _ in }
        )
        .applyDefaultSize()

        // Then
        AssertSnapshot(view)
    }

    func test_messageListView_threadRepliesSeparator_hiddenWhenNotAllLoaded() {
        // Given
        let channel = ChatChannel.mockDMChannel()
        let parentId: MessageId = "parent-id"
        let parentMessage = ChatMessage.mock(
            id: parentId,
            cid: channel.cid,
            text: "Which item has priority?",
            author: .mock(id: "user1", name: "Wesley"),
            replyCount: 5
        )
        let reply1 = ChatMessage.mock(
            id: "reply1",
            cid: channel.cid,
            text: "I think the first one is the most important.",
            author: .mock(id: "user2", name: "Emma"),
            parentMessageId: parentId
        )
        let messages: [ChatMessage] = [reply1, parentMessage]
        let view = MessageListView(
            factory: DefaultViewFactory.shared,
            channel: channel,
            messages: messages,
            messagesGroupingInfo: [:],
            scrolledId: .constant(nil),
            showScrollToLatestButton: .constant(false),
            quotedMessage: .constant(nil),
            currentDateString: nil,
            listId: "listId",
            isMessageThread: true,
            shouldShowTypingIndicator: false,
            onMessageAppear: { _, _ in },
            onScrollToBottom: {},
            onLongPress: { _ in }
        )
        .applyDefaultSize()

        // Then
        AssertSnapshot(view)
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
