//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import SwiftUI
import XCTest

class ChatChannelDataSource_Tests: StreamChatTestCase {

    private let message = ChatMessage.mock(
        id: .unique,
        cid: .unique,
        text: "message",
        author: ChatUser.mock(id: .unique)
    )

    private let reply = ChatMessage.mock(
        id: .unique,
        cid: .unique,
        text: "reply",
        author: ChatUser.mock(id: .unique)
    )

    @MainActor func test_channelDataSource_messages() {
        // Given
        let expected: [ChatMessage] = [message]
        let channelDataSource = makeChannelDataSource(messages: expected)

        // When
        let messages = channelDataSource.messages

        // Then
        XCTAssert(messages[0] == expected[0])
        XCTAssert(messages.count == expected.count)
    }

    @MainActor func test_channelDataSource_updatedMessages() {
        // Given
        let handler = MockMessagesDataSourceHandler()
        let expected: [ChatMessage] = [message]
        let chat = makeChat(messages: expected)
        let channelDataSource = ChatChannelDataSource(chat: chat)
        channelDataSource.delegate = handler

        // When
        let noMessagesCall = handler.updateMessagesCalled
        chat.simulate(messages: expected, changes: [])
        let messagesCall = handler.updateMessagesCalled
        let noChannelCall = handler.updateChannelCalled

        // Then
        XCTAssert(noMessagesCall == false)
        XCTAssert(messagesCall == true)
        XCTAssert(noChannelCall == false)
    }

    @MainActor func test_channelDataSource_updatedChannel() {
        // Given
        let channel = ChatChannel.mockDMChannel()
        let handler = MockMessagesDataSourceHandler()
        let expected: [ChatMessage] = [message]
        let chat = makeChat(channel: channel, messages: expected)
        let channelDataSource = ChatChannelDataSource(chat: chat)
        channelDataSource.delegate = handler

        // When
        let noChannelCall = handler.updateChannelCalled
        chat.simulate(channel: channel, change: .update(channel))
        let noMessagesCall = handler.updateMessagesCalled
        let channelCall = handler.updateChannelCalled

        // Then
        XCTAssert(noMessagesCall == false)
        XCTAssert(channelCall == true)
        XCTAssert(noChannelCall == false)
    }
    
    @MainActor func test_channelDataSource_hasLoadedAllNextMessages() async throws {
        // Given
        let expected: [ChatMessage] = [message]
        let channelDataSource = makeChannelDataSource(messages: expected)
        
        // When
        let messages = channelDataSource.messages
        try await channelDataSource.loadFirstPage()
        
        // Then
        XCTAssertEqual(messages.first, expected.first)
        XCTAssertEqual(messages.count, expected.count)
        XCTAssert(channelDataSource.hasLoadedAllNextMessages == true)
    }
    
    @MainActor func test_channelDataSource_loadPageAroundMessageId() async throws {
        // Given
        let handler = MockMessagesDataSourceHandler()
        let expected: [ChatMessage] = [message]
        let chat = makeChat(messages: expected)
        let channelDataSource = ChatChannelDataSource(chat: chat)
        channelDataSource.delegate = handler

        // When
        try await channelDataSource.loadPageAroundMessageId(.unique)
        let loadPageCall = chat.loadPageAroundMessageIdCallCount

        // Then
        XCTAssert(loadPageCall == 1)
    }

    @MainActor func test_messageThreadDataSource_messages() async throws {
        // Given
        let expected: [ChatMessage] = [message]
        let messageState = MessageState(
            message: message,
            messageOrder: .topToBottom,
            database: .init(kind: .inMemory, bundle: Bundle(for: Self.self)),
            clientConfig: .init(apiKey: .init(.unique)),
            replyPaginationHandler: chatClient.makeMessagesPaginationStateHandler()
        )
        let threadDataSource = makeMessageThreadDataSource(
            messages: expected,
            messageId: message.id,
            messageState: messageState
        )

        // When
        var messages = threadDataSource.messages
        let initialCount = messages.count
        messageState.replies = StreamCollection([reply])
        messages = threadDataSource.messages
        let count = messages.count

        // Then
        XCTAssert(initialCount == 0)
        XCTAssert(count == 1)
        XCTAssert(messages.first == reply)
    }

    @MainActor func test_messageThreadDataSource_updatedMessages() async throws {
        // Given
        let expected: [ChatMessage] = [message]
        let handler = MockMessagesDataSourceHandler()
        let threadDataSource = makeMessageThreadDataSource(
            messages: expected,
            messageId: message.id
        )
        threadDataSource.delegate = handler
        
        // When
        let noMessagesCall = handler.updateMessagesCalled
        threadDataSource.messageState?.replies = StreamCollection([reply])
        
        try await Task.sleep(nanoseconds: 1_000_000)
                
        let messagesCall = handler.updateMessagesCalled

        // Then
        XCTAssert(noMessagesCall == false)
        XCTAssert(messagesCall == true)
    }

    // MARK: - private

    private class MockMessagesDataSourceHandler: MessagesDataSource {

        var updateMessagesCalled = false
        var updateChannelCalled = false

        func dataSource(
            channelDataSource: ChannelDataSource,
            didUpdateMessages messages: StreamCollection<ChatMessage>
        ) {
            updateMessagesCalled = true
        }

        func dataSource(
            channelDataSource: ChannelDataSource,
            didUpdateChannel channel: EntityChange<ChatChannel>
        ) {
            updateChannelCalled = true
        }
    }

    @MainActor private func makeChannelDataSource(messages: [ChatMessage]) -> ChatChannelDataSource {
        let chat = makeChat(messages: messages)
        let channelDataSource = ChatChannelDataSource(chat: chat)
        return channelDataSource
    }

    @MainActor private func makeMessageThreadDataSource(
        chat: Chat? = nil,
        messages: [ChatMessage],
        messageId: MessageId,
        messageState: MessageState? = nil
    ) -> MessageThreadDataSource {
        let chat = chat ?? makeChat(messages: messages)
        let messageState = messageState ?? MessageState(
            message: message,
            messageOrder: .topToBottom,
            database: .init(
                kind: .inMemory,
                bundle: Bundle(for: Self.self)), 
            clientConfig: .init(apiKey: .init(.unique)),
            replyPaginationHandler: chatClient.makeMessagesPaginationStateHandler()
        )
        let threadDataSource = MessageThreadDataSource(
            chat: chat,
            messageId: messageId,
            messageState: messageState
        )

        return threadDataSource
    }

    @MainActor private func makeChat(channel: ChatChannel? = nil, messages: [ChatMessage]) -> Chat_Mock {
        let chat = ChatChannelTestHelpers.makeChat(chatClient: chatClient, messages: messages)
        return chat
    }
}
