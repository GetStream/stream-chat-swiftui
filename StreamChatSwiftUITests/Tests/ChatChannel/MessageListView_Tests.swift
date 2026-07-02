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

    func test_messageListView_systemMessageOnly() {
        // Given
        let channel = ChatChannel.mockDMChannel()
        let systemMessageId = MessageId.unique
        let systemMessage = ChatMessage.mock(
            id: systemMessageId,
            cid: channel.cid,
            text: "Martin created the channel",
            type: .system,
            author: .mock(id: "system")
        )
        let view = MessageListView(
            factory: DefaultViewFactory.shared,
            channel: channel,
            messages: [systemMessage],
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

    func test_messageListView_systemMessageWithNewMessagesSeparator() {
        // Given
        let messageListConfig = MessageListConfig(showNewMessagesSeparator: true)
        let utils = Utils(dateFormatter: EmptyDateFormatter(), messageListConfig: messageListConfig)
        streamChat = StreamChat(chatClient: chatClient, utils: utils)

        let channel = ChatChannel.mockDMChannel(unreadCount: .mock(messages: 1))
        let systemMessageId = MessageId.unique
        let systemMessage = ChatMessage.mock(
            id: systemMessageId,
            cid: channel.cid,
            text: "Martin created the channel",
            type: .system,
            author: .mock(id: "system")
        )
        let view = MessageListView(
            factory: DefaultViewFactory.shared,
            channel: channel,
            messages: [systemMessage],
            messagesGroupingInfo: [:],
            scrolledId: .constant(nil),
            showScrollToLatestButton: .constant(false),
            quotedMessage: .constant(nil),
            currentDateString: nil,
            listId: "listId",
            isMessageThread: false,
            shouldShowTypingIndicator: false,
            firstUnreadMessageId: .constant(systemMessageId),
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

    func test_jumpToUnreadButton_snapshotSingleUnread() {
        // Given
        let button = JumpToUnreadButton(unreadCount: 1, onTap: {}, onClose: {})
            .padding()

        // Then
        AssertSnapshot(button, size: CGSize(width: 250, height: 60))
    }

    func test_jumpToUnreadButton_snapshotMultipleUnread() {
        // Given
        let button = JumpToUnreadButton(unreadCount: 17, onTap: {}, onClose: {})
            .padding()

        // Then
        AssertSnapshot(button, size: CGSize(width: 250, height: 60))
    }

    func test_jumpToUnreadButton_snapshotHighUnreadCount() {
        // Given
        let button = JumpToUnreadButton(unreadCount: 99, onTap: {}, onClose: {})
            .padding()

        // Then
        AssertSnapshot(button, size: CGSize(width: 250, height: 60))
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

    // MARK: - Dividers

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

    func test_messageListView_threadRepliesSeparator_accessibilityExtraExtraExtraLarge() {
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
        .frame(width: defaultScreenSize.width, height: 1000)

        // Then
        let traits = UITraitCollection(traitsFrom: [
            UITraitCollection(displayScale: 1),
            UITraitCollection(preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge),
            UITraitCollection(userInterfaceStyle: .light)
        ])
        assertSnapshot(
            matching: view,
            as: .image(perceptualPrecision: precision, traits: traits)
        )
    }

    func test_messageListView_dateSeparator_accessibilityExtraExtraExtraLarge() {
        // Given
        let channel = ChatChannel.mockDMChannel()
        let day1 = Date(timeIntervalSince1970: 1_688_256_000) // 2023-07-02
        let day2 = day1.addingTimeInterval(60 * 60 * 24) // 2023-07-03
        let older = ChatMessage.mock(
            id: "older",
            cid: channel.cid,
            text: "Are we still on for the venue visit?",
            author: .mock(id: "user2", name: "Emma"),
            createdAt: day1
        )
        let newer = ChatMessage.mock(
            id: "newer",
            cid: channel.cid,
            text: "Yes, see you there!",
            author: .mock(id: "user1", name: "Wesley"),
            createdAt: day2,
            isSentByCurrentUser: true
        )
        let messages: [ChatMessage] = [newer, older]
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
            shouldShowTypingIndicator: false,
            onMessageAppear: { _, _ in },
            onScrollToBottom: {},
            onLongPress: { _ in }
        )
        .frame(width: defaultScreenSize.width, height: 1000)

        // Then
        let traits = UITraitCollection(traitsFrom: [
            UITraitCollection(displayScale: 1),
            UITraitCollection(preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge),
            UITraitCollection(userInterfaceStyle: .light)
        ])
        assertSnapshot(
            matching: view,
            as: .image(perceptualPrecision: precision, traits: traits)
        )
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

    // MARK: - Grouped Messages with Annotations

    func test_messageListView_groupedMessages_withThreadReplyAnnotation() {
        // Given
        let channel = ChatChannel.mockNonDMChannel()
        let author = ChatUser.mock(id: "martin", name: "Martin")
        let baseTime = Date(timeIntervalSince1970: 1000)
        let msg1 = ChatMessage.mock(
            id: "msg1",
            cid: channel.cid,
            text: "Let me check the latest updates.",
            author: author,
            createdAt: baseTime.addingTimeInterval(-20)
        )
        let msg2 = ChatMessage.mock(
            id: "msg2",
            cid: channel.cid,
            text: "I found the issue in the logs.",
            author: author,
            createdAt: baseTime.addingTimeInterval(-10),
            parentMessageId: .unique,
            showReplyInChannel: true
        )
        let msg3 = ChatMessage.mock(
            id: "msg3",
            cid: channel.cid,
            text: "Looks like it was a timeout.",
            author: author,
            createdAt: baseTime
        )
        let messages = [msg3, msg2, msg1]
        let messagesGroupingInfo: [String: [String]] = [
            msg3.id: [firstMessageKey],
            msg1.id: [lastMessageKey]
        ]
        let view = MessageListView(
            factory: DefaultViewFactory.shared,
            channel: channel,
            messages: messages,
            messagesGroupingInfo: messagesGroupingInfo,
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

    func test_messageListView_groupedMessages_withAllAnnotations() {
        // Given
        streamChat = StreamChat(chatClient: chatClient, utils: Utils(
            messageListConfig: .init(messageDisplayOptions: MessageDisplayOptions(showOriginalTranslatedButton: true))
        ))

        let channel = ChatChannel.mock(
            cid: .unique,
            config: .mock(messageRemindersEnabled: true),
            membership: .mock(id: .unique, language: .spanish)
        )
        let author = ChatUser.mock(id: "martin", name: "Martin")
        let baseTime = Date(timeIntervalSince1970: 1000)
        let msg1 = ChatMessage.mock(
            id: "msg1",
            cid: channel.cid,
            text: "Let me check the latest updates.",
            author: author,
            createdAt: baseTime.addingTimeInterval(-20)
        )
        let msg2 = ChatMessage.mock(
            id: "msg2",
            cid: channel.cid,
            text: "I found the issue in the logs.",
            author: author,
            createdAt: baseTime.addingTimeInterval(-10),
            parentMessageId: .unique,
            showReplyInChannel: true,
            translations: [.spanish: "Encontré el problema en los registros."],
            pinDetails: MessagePinDetails(
                pinnedAt: Date(),
                pinnedBy: .mock(id: .unique, name: "Martin"),
                expiresAt: nil
            ),
            reminder: MessageReminderInfo(
                remindAt: Date().addingTimeInterval(3600),
                createdAt: Date(),
                updatedAt: Date()
            )
        )
        let msg3 = ChatMessage.mock(
            id: "msg3",
            cid: channel.cid,
            text: "Looks like it was a timeout.",
            author: author,
            createdAt: baseTime
        )
        let messages = [msg3, msg2, msg1]
        let messagesGroupingInfo: [String: [String]] = [
            msg3.id: [firstMessageKey],
            msg1.id: [lastMessageKey]
        ]
        let view = MessageListView(
            factory: DefaultViewFactory.shared,
            channel: channel,
            messages: messages,
            messagesGroupingInfo: messagesGroupingInfo,
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
