//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

final class MessageListViewNewMessages_Tests: StreamChatTestCase {

    override func setUp() {
        super.setUp()
        let messageListConfig = MessageListConfig(showNewMessagesSeparator: true)
        let utils = Utils(dateFormatter: EmptyDateFormatter(), messageListConfig: messageListConfig)
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
    }
    
    func test_messageListViewNewMessages_singleMessage() {
        // Given
        let message = ChatMessage.mock(text: "Test message")
        let channel = ChatChannel.mockDMChannel(unreadCount: .mock(messages: 1))
        
        // When
        let messageListView = makeMessageListView(
            messages: [message],
            channel: channel
        )
        .applyDefaultSize()
        
        // Then
        assertSnapshot(matching: messageListView, as: .image(perceptualPrecision: precision))
    }
    
    func test_messageListViewNewMessages_moreMessages() {
        // Given
        let message1 = ChatMessage.mock(text: "Test message 1")
        let message2 = ChatMessage.mock(text: "Test message 2")
        let message3 = ChatMessage.mock(text: "Test message 3")
        let channel = ChatChannel.mockDMChannel(unreadCount: .mock(messages: 3))
        
        // When
        let messageListView = makeMessageListView(
            messages: [message1, message2, message3],
            channel: channel
        )
        .applyDefaultSize()
        
        // Then
        assertSnapshot(matching: messageListView, as: .image(perceptualPrecision: precision))
    }
    
    func test_messageListViewNewMessages_moreMessagesInBetween() {
        // Given
        let message1 = ChatMessage.mock(text: "Test message 1")
        let message2 = ChatMessage.mock(text: "Test message 2")
        let message3 = ChatMessage.mock(text: "Test message 3")
        let channel = ChatChannel.mockDMChannel(unreadCount: .mock(messages: 1))
        
        // When
        let messageListView = makeMessageListView(
            messages: [message1, message2, message3],
            channel: channel
        )
        .applyDefaultSize()
        
        // Then
        assertSnapshot(matching: messageListView, as: .image(perceptualPrecision: precision))
    }
    
    func test_messageListViewNewMessages_noMessages() {
        // Given
        let message1 = ChatMessage.mock(text: "Test message 1")
        let message2 = ChatMessage.mock(text: "Test message 2")
        let message3 = ChatMessage.mock(text: "Test message 3")
        let channel = ChatChannel.mockDMChannel(unreadCount: .mock(messages: 0))
        
        // When
        let messageListView = makeMessageListView(
            messages: [message1, message2, message3],
            channel: channel
        )
        .applyDefaultSize()
        
        // Then
        assertSnapshot(matching: messageListView, as: .image(perceptualPrecision: precision))
    }
    
    // MARK: - private
    
    func makeMessageListView(
        messages: [ChatMessage],
        channel: ChatChannel
    ) -> some View {
        let messages = LazyCachedMapCollection(source: messages, map: { $0 })
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
            onMessageAppear: { _ in },
            onScrollToBottom: {},
            onLongPress: { _ in }
        )

        return messageListView
    }
}
