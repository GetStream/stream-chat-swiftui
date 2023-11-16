//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

@testable import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

class MessageListView_Tests: StreamChatTestCase {

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

    // MARK: - private

    func makeMessageListView(
        channelConfig: ChannelConfig,
        currentlyTypingUsers: Set<ChatUser> = []
    ) -> MessageListView<DefaultViewFactory> {
        let reactions = [MessageReactionType(rawValue: "like"): 2]
        let channel = ChatChannel.mockDMChannel(
            config: channelConfig,
            currentlyTypingUsers: currentlyTypingUsers
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
            onMessageAppear: { _ in },
            onScrollToBottom: {},
            onLongPress: { _ in }
        )

        return messageListView
    }
}
