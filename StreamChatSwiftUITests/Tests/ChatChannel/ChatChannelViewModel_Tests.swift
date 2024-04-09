//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import SwiftUI
import XCTest

class ChatChannelViewModel_Tests: StreamChatTestCase {

    func test_chatChannelVM_messagesLoaded() {
        // Given
        let chat = makeChat()
        let viewModel = ChatChannelViewModel(chat: chat)

        // When
        let messages = viewModel.messages

        // Then
        XCTAssert(messages.count == 1)
        XCTAssert(viewModel.isMessageThread == false)
    }

    func test_chatChannelVM_messageGrouping() {
        // Given
        var messages = [ChatMessage]()
        var offset: Double = 200
        for i in 0..<16 {
            if i % 2 == 0 {
                offset += 200
            }
            let createdAt = Date(timeIntervalSince1970: offset)
            let message = ChatMessage.mock(
                id: .unique,
                cid: .unique,
                text: "Test Message \(i)",
                author: ChatUser.mock(id: Self.currentUserId),
                createdAt: createdAt
            )

            messages.append(message)
        }
        let chat = makeChat(messages: messages)
        let viewModel = ChatChannelViewModel(chat: chat)

        // When
        let messagesGroupingInfo = viewModel.messagesGroupingInfo

        // Then
        XCTAssert(messagesGroupingInfo.count == 2)
        for (_, groupingInfo) in messagesGroupingInfo {
            XCTAssert(groupingInfo.count == 1)
        }
    }

    func test_chatChannelVM_scrollToLastMessage() {
        // Given
        let messageId: String = .unique
        let message = ChatMessage.mock(
            id: messageId,
            cid: .unique,
            text: "Test message",
            author: ChatUser.mock(id: Self.currentUserId)
        )
        let chat = makeChat(messages: [message])
        let viewModel = ChatChannelViewModel(chat: chat)

        // When
        viewModel.scrollToLastMessage()

        // Then
        XCTAssert(viewModel.scrolledId?.contains(messageId) == true)
    }

    func test_chatChannelVM_currentDateString() {
        // Given
        let expectedDate = "Jan 01"
        let chat = makeChat()
        let viewModel = ChatChannelViewModel(chat: chat)

        // When
        viewModel.showScrollToLatestButton = true
        viewModel.handleMessageAppear(index: 0, scrollDirection: .up)

        // Then
        let dateString = viewModel.currentDateString
        XCTAssert(dateString == expectedDate)
    }

    func test_chatChannelVM_showReactionsOverlay() {
        // Given
        let chat = makeChat()
        let viewModel = ChatChannelViewModel(chat: chat)

        // When
        viewModel.showReactionOverlay(for: AnyView(EmptyView()))

        // Then
        XCTAssert(viewModel.currentSnapshot != nil)
        XCTAssert(viewModel.reactionsShown == true)
    }

    func test_chatChannelVM_listRefresh() {
        // Given
        var messages = [ChatMessage]()
        for i in 0..<250 {
            let message = ChatMessage.mock(
                id: .unique,
                cid: .unique,
                text: "Test Message \(i)",
                author: ChatUser.mock(id: Self.currentUserId)
            )
            messages.append(message)
        }
        let chat = makeChat(messages: messages)
        let viewModel = ChatChannelViewModel(chat: chat)

        // When
        let initialListId = viewModel.listId
        chat.simulate(messages: messages, changes: [])

        // Then
        let newListId = viewModel.listId
        XCTAssert(initialListId != newListId)
    }

    func test_chatChannelVM_listNoRefresh() {
        // Given
        var messages = [ChatMessage]()
        for i in 0..<200 {
            let message = ChatMessage.mock(
                id: .unique,
                cid: .unique,
                text: "Test Message \(i)",
                author: ChatUser.mock(id: Self.currentUserId)
            )
            messages.append(message)
        }
        let chat = makeChat(messages: messages)
        let viewModel = ChatChannelViewModel(chat: chat)

        // When
        let initialListId = viewModel.listId
//        channelController.simulate(messages: messages, changes: [])

        // Then
        let newListId = viewModel.listId
        XCTAssert(initialListId == newListId)
    }

    func test_chatChannelVM_messageThread() {
        // Given
        let chat = makeChat()
        let viewModel = ChatChannelViewModel(
            chat: chat,
            messageId: .unique
        )

        // When
        let isMessageThread = viewModel.isMessageThread

        // Then
        XCTAssert(isMessageThread == true)
    }

    func test_chatChannelVM_messageActionInlineReplyExecuted() {
        // Given
        let chat = makeChat()
        let viewModel = ChatChannelViewModel(chat: chat)
        let messageActionInfo = MessageActionInfo(
            message: viewModel.messages[0],
            identifier: "inlineReply"
        )

        // When
        viewModel.messageActionExecuted(messageActionInfo)

        // Then
        XCTAssert(viewModel.quotedMessage != nil)
        XCTAssert(viewModel.quotedMessage == viewModel.messages[0])
    }

    func test_chatChannelVM_messageActionEditExecuted() {
        // Given
        let chat = makeChat()
        let viewModel = ChatChannelViewModel(chat: chat)
        let messageActionInfo = MessageActionInfo(
            message: viewModel.messages[0],
            identifier: "edit"
        )

        // When
        viewModel.messageActionExecuted(messageActionInfo)

        // Then
        XCTAssert(viewModel.editedMessage != nil)
        XCTAssert(viewModel.editedMessage == viewModel.messages[0])
    }

    func test_chatChannelVM_regularMessageHeader() {
        // Given
        let chat = makeChat()
        let viewModel = ChatChannelViewModel(chat: chat)

        // When
        let headerType = viewModel.channelHeaderType

        // Then
        XCTAssert(headerType == .regular)
        XCTAssert(viewModel.shouldShowTypingIndicator == false)
    }

    func test_chatChannelVM_typingIndicatorMessageHeader() async throws {
        // Given
        let utils = Utils(
            messageListConfig: MessageListConfig(typingIndicatorPlacement: .navigationBar)
        )
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
        let typingUser: ChatChannelMember = ChatChannelMember.mock(id: .unique)
        let chat = makeChat(typingUsers: [typingUser])
        let viewModel = ChatChannelViewModel(chat: chat)

        // When
        let channel: ChatChannel = .mockDMChannel(currentlyTypingUsers: Set(arrayLiteral: typingUser))
        chat.simulate(
            channel: channel,
            change: .update(channel),
            typingUsers: Set(arrayLiteral: typingUser)
        )
        try await waitForTask(nanoseconds: 500_000_000)
        let headerType = viewModel.channelHeaderType
        
        // Then
        XCTAssert(headerType == .typingIndicator)
    }

    func test_chatChannelVM_typingIndicatorMessageList() async throws {
        // Given
        let typingUser: ChatChannelMember = ChatChannelMember.mock(id: .unique)
        let chat = makeChat(typingUsers: [typingUser])
        let viewModel = ChatChannelViewModel(chat: chat)

        // When
        let channel: ChatChannel = .mockDMChannel(currentlyTypingUsers: Set(arrayLiteral: typingUser))
        chat.simulate(
            channel: channel,
            change: .update(channel),
            typingUsers: Set(arrayLiteral: typingUser)
        )
        
        // Then
        XCTAssert(viewModel.shouldShowTypingIndicator == true)
    }

    func test_chatChannelVM_skipChanges() {
        // Given
        let chat = makeChat()
        let viewModel = ChatChannelViewModel(chat: chat)
        let messageId = String.unique
        let message = ChatMessage.mock(
            id: messageId,
            cid: .unique,
            text: "Some text",
            author: .mock(id: .unique)
        )

        // When
        chat.simulate(
            messages: [message],
            changes: [.update(message, index: .init(row: 0, section: 0))]
        )
        let initial = viewModel.messages
        chat.simulate(
            messages: [message],
            changes: [.update(message, index: .init(row: 0, section: 0))]
        )
        let after = viewModel.messages

        // Then
        XCTAssert(initial.first?.messageId == after.first?.messageId)
    }

    func test_chatChannelVM_ephemeral() {
        // Given
        let chat = makeChat()
        let viewModel = ChatChannelViewModel(chat: chat)
        let messageId = String.unique
        let message = ChatMessage.mock(
            id: messageId,
            cid: .unique,
            text: "Some text",
            author: .mock(id: .unique)
        )
        let newMessage = ChatMessage.mock(
            id: messageId,
            cid: .unique,
            text: "Some text",
            type: .ephemeral,
            author: .mock(id: .unique)
        )

        // When
        chat.simulate(
            messages: [message],
            changes: [.update(message, index: .init(row: 0, section: 0))]
        )
        let initial = viewModel.messages
        chat.simulate(
            messages: [newMessage],
            changes: [.update(newMessage, index: .init(row: 0, section: 0))]
        )
        let after = viewModel.messages

        // Then
        XCTAssert(initial[0].type != after[0].type)
    }

    func test_chatChannelVM_animatedChanges() {
        // Given
        let chat = makeChat()
        let viewModel = ChatChannelViewModel(chat: chat)
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Some text",
            author: .mock(id: .unique)
        )
        let newMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "New message",
            author: .mock(id: .unique)
        )

        // When
        chat.simulate(
            messages: [message],
            changes: [.update(message, index: .init(row: 0, section: 0))]
        )
        let initial = viewModel.messages
        chat.simulate(
            messages: [message, newMessage],
            changes: [.insert(newMessage, index: .init(row: 1, section: 0))]
        )
        let after = viewModel.messages

        // Then
        XCTAssert(initial.count < after.count)
    }

    func test_chatChannelVM_updateReadIndicators() {
        // Given
        let chat = makeChat()
        let viewModel = ChatChannelViewModel(chat: chat)
        let channel = ChatChannel.mockDMChannel()
        let read = ChatChannelRead.mock(
            lastReadAt: Date(),
            lastReadMessageId: nil,
            unreadMessagesCount: 1,
            user: .mock(id: .unique)
        )
        let newChannel = ChatChannel.mockDMChannel(reads: [read])

        // When
        chat.simulate(
            channel: channel,
            change: .update(channel),
            typingUsers: nil
        )
        let readsString = channel.readsString
        chat.simulate(
            channel: newChannel,
            change: .update(newChannel),
            typingUsers: nil
        )
        let newChannelReadsString = newChannel.readsString

        // Then
        XCTAssert(viewModel.channel! == newChannel)
        XCTAssert(readsString != newChannelReadsString)
    }

    func test_chatChannelVM_threadMessage() {
        // Given
        let chat = makeChat()
        let viewModel = ChatChannelViewModel(chat: chat)
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Some text",
            author: .mock(id: .unique)
        )

        // When
        NotificationCenter.default.post(
            name: NSNotification.Name(MessageRepliesConstants.selectedMessageThread),
            object: nil,
            userInfo: [MessageRepliesConstants.selectedMessage: message]
        )

        // Then
        XCTAssert(viewModel.threadMessage == message)
        XCTAssert(viewModel.threadMessageShown == true)

        // When
        viewModel.threadMessageShown = false

        // Then
        XCTAssert(viewModel.threadMessage == nil)
    }
    
    func test_chatChannelVM_jumpToInitialMessage() {
        // Given
        let message = ChatMessage.mock()
        let chat = makeChat(messages: [message])
        let viewModel = ChatChannelViewModel(chat: chat)
        
        // When
        let shouldJump = viewModel.jumpToMessage(messageId: message.messageId)
    
        // Then
        XCTAssert(shouldJump == true)
    }
    
    func test_chatChannelVM_jumpToAvailableMessage() {
        // Given
        let message1 = ChatMessage.mock()
        let message2 = ChatMessage.mock()
        let chat = makeChat(messages: [message1, message2])
        let viewModel = ChatChannelViewModel(chat: chat)
        
        // When
        let shouldJump = viewModel.jumpToMessage(messageId: message2.messageId)
    
        // Then
        XCTAssert(shouldJump == true)
    }
    
    func test_chatChannelVM_jumpToUnavailableMessage() {
        // Given
        let message1 = ChatMessage.mock()
        let message2 = ChatMessage.mock()
        let message3 = ChatMessage.mock()
        let chat = makeChat(messages: [message1, message2])
        let viewModel = ChatChannelViewModel(chat: chat)
        
        // When
        let shouldJump = viewModel.jumpToMessage(messageId: message3.messageId)
    
        // Then
        XCTAssert(shouldJump == false)
    }
    
    func test_chatChannelVM_jumpToUnknownMessage() {
        // Given
        let message1 = ChatMessage.mock()
        let message2 = ChatMessage.mock()
        let chat = makeChat(messages: [message1, message2])
        let viewModel = ChatChannelViewModel(chat: chat)
        
        // When
        let shouldJump = viewModel.jumpToMessage(messageId: .unknownMessageId)
    
        // Then
        XCTAssert(shouldJump == false)
    }

    // MARK: - private

    private func makeChat(
        channel: ChatChannel? = nil,
        messages: [ChatMessage] = [],
        watchers: [ChatUser] = [],
        typingUsers: Set<ChatUser> = []
    ) -> Chat_Mock {
        let chat = ChatChannelTestHelpers.makeChat(
            chatClient: ChatClient.mock(bundle: Bundle(for: Self.self)),
            chatChannel: channel,
            messages: messages,
            lastActiveWatchers: watchers,
            currentlyTypingUsers: typingUsers
        )
        return chat
    }
}
