//
// Copyright © 2023 Stream.io Inc. All rights reserved.
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

    func test_channelDataSource_messages() {
        // Given
        let expected: [ChatMessage] = [message]
        let channelDataSource = makeChannelDataSource(messages: expected)

        // When
        let messages = channelDataSource.messages

        // Then
        XCTAssert(messages[0] == expected[0])
        XCTAssert(messages.count == expected.count)
    }

    func test_channelDataSource_updatedMessages() {
        // Given
        let handler = MockMessagesDataSourceHandler()
        let expected: [ChatMessage] = [message]
        let controller = makeChannelController(messages: expected)
        let channelDataSource = ChatChannelDataSource(controller: controller)
        channelDataSource.delegate = handler

        // When
        let noMessagesCall = handler.updateMessagesCalled
        controller.simulate(messages: expected, changes: [])
        let messagesCall = handler.updateMessagesCalled
        let noChannelCall = handler.updateChannelCalled

        // Then
        XCTAssert(noMessagesCall == false)
        XCTAssert(messagesCall == true)
        XCTAssert(noChannelCall == false)
    }

    func test_channelDataSource_updatedChannel() {
        // Given
        let channel = ChatChannel.mockDMChannel()
        let handler = MockMessagesDataSourceHandler()
        let expected: [ChatMessage] = [message]
        let controller = makeChannelController(messages: expected)
        let channelDataSource = ChatChannelDataSource(controller: controller)
        channelDataSource.delegate = handler

        // When
        let noChannelCall = handler.updateChannelCalled
        controller.simulate(
            channel: channel,
            change: .update(channel),
            typingUsers: []
        )
        let noMessagesCall = handler.updateMessagesCalled
        let channelCall = handler.updateChannelCalled

        // Then
        XCTAssert(noMessagesCall == false)
        XCTAssert(channelCall == true)
        XCTAssert(noChannelCall == false)
    }
    
    func test_channelDataSource_hasLoadedAllNextMessages() {
        // Given
        let expected: [ChatMessage] = [message]
        let channelDataSource = makeChannelDataSource(messages: expected)
        
        // When
        let messages = channelDataSource.messages
        channelDataSource.loadFirstPage(nil)
        
        // Then
        XCTAssert(messages[0] == expected[0])
        XCTAssert(messages.count == expected.count)
        XCTAssert(channelDataSource.hasLoadedAllNextMessages == true)
    }
    
    func test_channelDataSource_loadPageAroundMessageId() {
        // Given
        let handler = MockMessagesDataSourceHandler()
        let expected: [ChatMessage] = [message]
        let controller = makeChannelController(messages: expected)
        let channelDataSource = ChatChannelDataSource(controller: controller)
        channelDataSource.delegate = handler

        // When
        channelDataSource.loadPageAroundMessageId(.unique, completion: nil)
        let loadPageCall = controller.loadPageAroundMessageIdCallCount

        // Then
        XCTAssert(loadPageCall == 1)
    }

    func test_messageThreadDataSource_messages() {
        // Given
        let channel = ChatChannel.mockDMChannel()
        let expected: [ChatMessage] = [message]
        let messageController = ChatMessageControllerSUI_Mock.mock(
            chatClient: chatClient,
            cid: channel.cid,
            messageId: message.id
        )
        let threadDataSource = makeMessageThreadDataSource(
            messages: expected,
            messageController: messageController
        )

        // When
        var messages = threadDataSource.messages
        let initialCount = messages.count
        messageController.simulate(replies: [reply], changes: [])
        messages = threadDataSource.messages
        let count = messages.count

        // Then
        XCTAssert(initialCount == 0)
        XCTAssert(count == 1)
        XCTAssert(messages[0] == reply)
    }

    func test_messageThreadDataSource_updatedMessages() {
        // Given
        let channel = ChatChannel.mockDMChannel()
        let expected: [ChatMessage] = [message]
        let messageController = ChatMessageControllerSUI_Mock.mock(
            chatClient: chatClient,
            cid: channel.cid,
            messageId: message.id
        )
        let handler = MockMessagesDataSourceHandler()
        let threadDataSource = makeMessageThreadDataSource(
            messages: expected,
            messageController: messageController
        )
        threadDataSource.delegate = handler

        // When
        let noMessagesCall = handler.updateMessagesCalled
        messageController.simulate(replies: [reply], changes: [])
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
            didUpdateMessages messages: LazyCachedMapCollection<ChatMessage>,
            changes: [ListChange<ChatMessage>]
        ) {
            updateMessagesCalled = true
        }

        func dataSource(
            channelDataSource: ChannelDataSource,
            didUpdateChannel channel: EntityChange<ChatChannel>,
            channelController: ChatChannelController
        ) {
            updateChannelCalled = true
        }
    }

    private func makeChannelDataSource(messages: [ChatMessage]) -> ChatChannelDataSource {
        let channelController = makeChannelController(messages: messages)
        let channelDataSource = ChatChannelDataSource(controller: channelController)
        return channelDataSource
    }

    private func makeMessageThreadDataSource(
        messages: [ChatMessage],
        messageController: ChatMessageController_Mock
    ) -> MessageThreadDataSource {
        let channelController = makeChannelController(messages: messages)
        let threadDataSource = MessageThreadDataSource(
            channelController: channelController,
            messageController: messageController
        )

        return threadDataSource
    }

    private func makeChannelController(messages: [ChatMessage]) -> ChatChannelController_Mock {
        let channelController = ChatChannelTestHelpers.makeChannelController(
            chatClient: chatClient,
            messages: messages
        )
        channelController.simulateInitial(
            channel: .mockDMChannel(),
            messages: messages,
            state: .initialized
        )
        return channelController
    }
}
