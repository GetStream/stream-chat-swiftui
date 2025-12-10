//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import SwiftUI
import XCTest

class ChatChannelViewModel_Tests: StreamChatTestCase {
    func test_chatChannelVM_channelIsUpdated() {
        // Given
        let cid = ChannelId.unique
        let initialChannel = ChatChannel.mock(cid: cid)
        let channelController = makeChannelController()
        channelController.channel_mock = initialChannel
        let viewModel = ChatChannelViewModel(channelController: channelController)
        XCTAssertEqual(initialChannel, viewModel.channel)
        
        // When
        let updatedChannel = ChatChannel.mock(cid: cid)
        channelController.channel_mock = updatedChannel
        channelController.delegate?.channelController(
            channelController,
            didUpdateChannel: .update(updatedChannel)
        )
        
        // Then
        XCTAssertEqual(updatedChannel, viewModel.channel)
    }
    
    func test_chatChannelVM_messagesLoaded() {
        // Given
        let channelController = makeChannelController()
        let viewModel = ChatChannelViewModel(channelController: channelController)

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
                author: ChatUser.mock(id: chatClient.currentUserId!),
                createdAt: createdAt
            )

            messages.append(message)
        }
        let channelController = makeChannelController(messages: messages)
        let viewModel = ChatChannelViewModel(channelController: channelController)

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
            author: ChatUser.mock(id: chatClient.currentUserId!)
        )
        let channelController = makeChannelController(messages: [message])
        let viewModel = ChatChannelViewModel(channelController: channelController)

        // When
        viewModel.scrollToLastMessage()

        // Then
        XCTAssert(viewModel.scrolledId!.contains(messageId))
    }

    func test_chatChannelVM_messageSentTapped_whenEditingMessage_shouldNotScroll() {
        // Given
        let messageId: String = .unique
        let message = ChatMessage.mock(
            id: messageId,
            cid: .unique,
            text: "Test message",
            author: ChatUser.mock(id: chatClient.currentUserId!)
        )
        let channelController = makeChannelController(messages: [message])
        let viewModel = ChatChannelViewModel(channelController: channelController)
        viewModel.editedMessage = .unique

        // When
        viewModel.messageSentTapped()

        // Then
        XCTAssertNil(viewModel.scrolledId)
    }

    func test_chatChannelVM_currentDateString() {
        // Given
        let expectedDate = "Jan 01"
        let channelController = makeChannelController()
        let viewModel = ChatChannelViewModel(channelController: channelController)

        // When
        viewModel.showScrollToLatestButton = true
        viewModel.handleMessageAppear(index: 0, scrollDirection: .up)

        // Then
        let dateString = viewModel.currentDateString
        XCTAssertEqual(dateString, expectedDate)
    }

    func test_chatChannelVM_showReactionsOverlay() {
        // Given
        let channelController = makeChannelController()
        let viewModel = ChatChannelViewModel(channelController: channelController)

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
                author: ChatUser.mock(id: chatClient.currentUserId!)
            )
            messages.append(message)
        }
        let channelController = makeChannelController(messages: messages)
        let viewModel = ChatChannelViewModel(channelController: channelController)

        // When
        let initialListId = viewModel.listId
        channelController.simulate(messages: messages, changes: [])

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
                author: ChatUser.mock(id: chatClient.currentUserId!)
            )
            messages.append(message)
        }
        let channelController = makeChannelController(messages: messages)
        let viewModel = ChatChannelViewModel(channelController: channelController)

        // When
        let initialListId = viewModel.listId
        channelController.simulate(messages: messages, changes: [])

        // Then
        let newListId = viewModel.listId
        XCTAssert(initialListId == newListId)
    }

    func test_chatChannelVM_newMessageSentScrollsToNewestMessage() {
        // Given
        var messages = [ChatMessage]()
        for i in 0..<5 {
            let message = ChatMessage.mock(
                id: .unique,
                cid: .unique,
                text: "Test Message \(i)",
                author: ChatUser.mock(id: chatClient.currentUserId!)
            )
            messages.append(message)
        }
        let channelController = makeChannelController(messages: messages)
        let viewModel = ChatChannelViewModel(channelController: channelController)

        // When
        viewModel.showScrollToLatestButton = true
        viewModel.messageSentTapped()
        viewModel.dataSource(
            channelDataSource: ChatChannelDataSource(controller: channelController),
            didUpdateMessages: LazyCachedMapCollection(elements: messages),
            changes: [
                .insert(messages[0], index: .init(item: 0, section: 0)),
                .update(messages[1], index: .init(item: 1, section: 0))
            ]
        )

        // Then
        XCTAssertEqual(viewModel.scrolledId, messages[0].id)
    }

    func test_chatChannelVM_messageThread() {
        // Given
        let channelController = makeChannelController()
        let messageController = ChatMessageControllerSUI_Mock.mock(
            chatClient: chatClient,
            cid: .unique,
            messageId: .unique
        )
        let viewModel = ChatChannelViewModel(
            channelController: channelController,
            messageController: messageController
        )

        // When
        let isMessageThread = viewModel.isMessageThread

        // Then
        XCTAssert(isMessageThread == true)
    }

    func test_chatChannelVM_messageActionInlineReplyExecuted() {
        // Given
        let channelController = makeChannelController()
        let viewModel = ChatChannelViewModel(channelController: channelController)
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
        let channelController = makeChannelController()
        let viewModel = ChatChannelViewModel(channelController: channelController)
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
        let channelController = makeChannelController()
        let viewModel = ChatChannelViewModel(channelController: channelController)

        // When
        let headerType = viewModel.channelHeaderType

        // Then
        XCTAssert(headerType == .regular)
        XCTAssert(viewModel.shouldShowTypingIndicator == false)
    }

    func test_chatChannelVM_typingIndicatorMessageHeader() {
        // Given
        let utils = Utils(
            messageListConfig: MessageListConfig(typingIndicatorPlacement: .navigationBar)
        )
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
        let channelController = makeChannelController()
        let typingUser: ChatChannelMember = ChatChannelMember.mock(id: .unique)
        let viewModel = ChatChannelViewModel(channelController: channelController)

        // When
        let channel: ChatChannel = .mockDMChannel(currentlyTypingUsers: Set(arrayLiteral: typingUser))
        channelController.simulate(
            channel: channel,
            change: .update(channel),
            typingUsers: Set(arrayLiteral: typingUser)
        )
        let headerType = viewModel.channelHeaderType

        // Then
        XCTAssert(headerType == .typingIndicator)
    }

    func test_chatChannelVM_typingIndicatorMessageList() {
        // Given
        let channelController = makeChannelController()
        let typingUser: ChatChannelMember = ChatChannelMember.mock(id: .unique)
        let viewModel = ChatChannelViewModel(channelController: channelController)

        // When
        let channel: ChatChannel = .mockDMChannel(currentlyTypingUsers: Set(arrayLiteral: typingUser))
        channelController.simulate(
            channel: channel,
            change: .update(channel),
            typingUsers: Set(arrayLiteral: typingUser)
        )

        // Then
        XCTAssert(viewModel.shouldShowTypingIndicator == true)
    }

    func test_chatChannelVM_skipChanges() {
        // Given
        let channelController = makeChannelController()
        let viewModel = ChatChannelViewModel(channelController: channelController)
        let messageId = String.unique
        let message = ChatMessage.mock(
            id: messageId,
            cid: .unique,
            text: "Some text",
            author: .mock(id: .unique)
        )

        // When
        channelController.simulate(
            messages: [message],
            changes: [.update(message, index: .init(row: 0, section: 0))]
        )
        let initial = viewModel.messages
        channelController.simulate(
            messages: [message],
            changes: [.update(message, index: .init(row: 0, section: 0))]
        )
        let after = viewModel.messages

        // Then
        XCTAssert(initial[0].messageId == after[0].messageId)
    }

    func test_chatChannelVM_ephemeral() {
        // Given
        let channelController = makeChannelController()
        let viewModel = ChatChannelViewModel(channelController: channelController)
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
        channelController.simulate(
            messages: [message],
            changes: [.update(message, index: .init(row: 0, section: 0))]
        )
        let initial = viewModel.messages
        channelController.simulate(
            messages: [newMessage],
            changes: [.update(newMessage, index: .init(row: 0, section: 0))]
        )
        let after = viewModel.messages

        // Then
        XCTAssert(initial[0].type != after[0].type)
    }

    func test_chatChannelVM_animatedChanges() {
        // Given
        let channelController = makeChannelController()
        let viewModel = ChatChannelViewModel(channelController: channelController)
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
        channelController.simulate(
            messages: [message],
            changes: [.update(message, index: .init(row: 0, section: 0))]
        )
        let initial = viewModel.messages
        channelController.simulate(
            messages: [message, newMessage],
            changes: [.insert(newMessage, index: .init(row: 1, section: 0))]
        )
        let after = viewModel.messages

        // Then
        XCTAssert(initial.count < after.count)
    }

    func test_chatChannelVM_updateReadIndicators() {
        // Given
        let channelController = makeChannelController()
        let viewModel = ChatChannelViewModel(channelController: channelController)
        let channel = ChatChannel.mockDMChannel()
        let read = ChatChannelRead.mock(
            lastReadAt: Date(),
            lastReadMessageId: nil,
            unreadMessagesCount: 1,
            user: .mock(id: .unique)
        )
        let newChannel = ChatChannel.mockDMChannel(reads: [read])

        // When
        channelController.simulate(
            channel: channel,
            change: .update(channel),
            typingUsers: nil
        )
        let readsString = channel.readsString
        channelController.simulate(
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
        let channelController = makeChannelController()
        let viewModel = ChatChannelViewModel(channelController: channelController)
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
        let channelController = makeChannelController(messages: [message])
        let viewModel = ChatChannelViewModel(channelController: channelController)
        
        // When
        let shouldJump = viewModel.jumpToMessage(messageId: message.messageId)
    
        // Then
        XCTAssert(shouldJump == true)
    }
    
    func test_chatChannelVM_jumpToAvailableMessage() {
        // Given
        let message1 = ChatMessage.mock()
        let message2 = ChatMessage.mock()
        let channelController = makeChannelController(messages: [message1, message2])
        let viewModel = ChatChannelViewModel(channelController: channelController)
        
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
        let channelController = makeChannelController(messages: [message1, message2])
        let viewModel = ChatChannelViewModel(channelController: channelController)
        
        // When
        let shouldJump = viewModel.jumpToMessage(messageId: message3.messageId)
    
        // Then
        XCTAssert(shouldJump == false)
    }
    
    func test_chatChannelVM_jumpToUnknownMessage() {
        // Given
        let message1 = ChatMessage.mock()
        let message2 = ChatMessage.mock()
        let channelController = makeChannelController(messages: [message1, message2])
        let viewModel = ChatChannelViewModel(channelController: channelController)

        // When
        let shouldJump = viewModel.jumpToMessage(messageId: .unknownMessageId)

        // Then
        XCTAssert(shouldJump == false)
    }

    func test_chatChannelVM_jumpToMessage_setsHighlightedMessageId() {
        // Given
        let message1 = ChatMessage.mock()
        let message2 = ChatMessage.mock()
        let channelController = makeChannelController(messages: [message1, message2])
        let viewModel = ChatChannelViewModel(channelController: channelController)
        let testExpectation = XCTestExpectation(description: "Highlight should be set")
        testExpectation.assertForOverFulfill = false

        // When
        let shouldJump = viewModel.jumpToMessage(messageId: message2.messageId)

        // Then
        XCTAssert(shouldJump == true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertEqual(viewModel.highlightedMessageId, message2.messageId)
            testExpectation.fulfill()
        }

        wait(for: [testExpectation], timeout: 1.0)
    }

    func test_chatChannelVM_jumpToMessage_clearsHighlightedMessageId() {
        // Given
        let message1 = ChatMessage.mock()
        let message2 = ChatMessage.mock()
        let channelController = makeChannelController(messages: [message1, message2])
        let viewModel = ChatChannelViewModel(channelController: channelController)
        let testExpectation = XCTestExpectation(description: "Highlight should be cleared")

        // When
        _ = viewModel.jumpToMessage(messageId: message2.messageId)

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            XCTAssertNil(viewModel.highlightedMessageId)
            testExpectation.fulfill()
        }

        wait(for: [testExpectation], timeout: 1.5)
    }

    func test_chatChannelVM_jumpToMessage_setsScrolledId() {
        // Given
        let message1 = ChatMessage.mock()
        let message2 = ChatMessage.mock()
        let channelController = makeChannelController(messages: [message1, message2])
        let viewModel = ChatChannelViewModel(channelController: channelController)

        // When
        _ = viewModel.jumpToMessage(messageId: message2.messageId)

        // Then
        XCTAssertEqual(viewModel.scrolledId, message2.messageId)
    }

    func test_chatChannelVM_selectedMessageThread_opensThread() {
        // Given
        let channelController = makeChannelController()
        let viewModel = ChatChannelViewModel(channelController: channelController)
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Test message",
            author: .mock(id: .unique)
        )

        // When
        NotificationCenter.default.post(
            name: NSNotification.Name(MessageRepliesConstants.selectedMessageThread),
            object: nil,
            userInfo: [MessageRepliesConstants.selectedMessage: message]
        )

        // Then
        XCTAssertEqual(viewModel.threadMessage, message)
        XCTAssertTrue(viewModel.threadMessageShown)
    }

    func test_chatChannelVM_selectedMessageThread_withThreadReplyMessage_opensThread() {
        // Given
        let channelController = makeChannelController()
        let viewModel = ChatChannelViewModel(channelController: channelController)
        let parentMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Parent message",
            author: .mock(id: .unique)
        )
        let replyMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Reply message",
            author: .mock(id: .unique),
            parentMessageId: parentMessage.id
        )

        // When
        NotificationCenter.default.post(
            name: NSNotification.Name(MessageRepliesConstants.selectedMessageThread),
            object: nil,
            userInfo: [
                MessageRepliesConstants.selectedMessage: parentMessage,
                MessageRepliesConstants.threadReplyMessage: replyMessage
            ]
        )

        // Then
        XCTAssertEqual(viewModel.threadMessage, parentMessage)
        XCTAssertTrue(viewModel.threadMessageShown)
    }

    func test_chatChannelVM_crashWhenIndexAccess() {
        // Given
        let message1 = ChatMessage.mock()
        let message2 = ChatMessage.mock()
        let message3 = ChatMessage.mock()
        let channelController = makeChannelController(messages: [message1, message2])
        let viewModel = ChatChannelViewModel(channelController: channelController)
        let newMessages = LazyCachedMapCollection(elements: [message1, message2, message3])
        
        // When
        viewModel.dataSource(
            channelDataSource: ChatChannelDataSource(controller: channelController),
            didUpdateMessages: newMessages,
            changes: [
                .insert(message3, index: IndexPath(row: 2, section: 0)),
                .update(message3, index: IndexPath(row: 2, section: 0)),
                .update(message3, index: IndexPath(row: 3, section: 0)) // intentionally invalid path
            ]
        )
        
        // Then
        XCTAssertEqual(3, viewModel.messages.count)
    }
    
    func test_chatChannelVM_keepFirstUnreadIndexSetAfterMarkingTheChannelAsRead() {
        // Given
        let message1 = ChatMessage.mock()
        let message2 = ChatMessage.mock()
        let message3 = ChatMessage.mock()
        let channelController = makeChannelController(messages: [message1, message2, message3])
        channelController.channel_mock = .mock(cid: .unique, unreadCount: ChannelUnreadCount(messages: 1, mentions: 0))
        let viewModel = ChatChannelViewModel(channelController: channelController)
        viewModel.firstUnreadMessageId = message1.id
        viewModel.throttler = Throttler_Mock(interval: 0)
        
        // When
        viewModel.handleMessageAppear(index: 0, scrollDirection: .down)
        
        // Then
        XCTAssertEqual(1, channelController.markReadCallCount)
        XCTAssertNotNil(viewModel.firstUnreadMessageId)
    }
    
    // MARK: - currentUserMarkedMessageUnread Tests
    
    func test_chatChannelVM_currentUserMarkedMessageUnread_initialValue() {
        // Given
        let channelController = makeChannelController()
        let viewModel = ChatChannelViewModel(channelController: channelController)
        
        // Then
        XCTAssertFalse(viewModel.currentUserMarkedMessageUnread)
    }
    
    func test_chatChannelVM_sendReadEventIfNeeded_whenCurrentUserMarkedMessageUnreadIsTrue() {
        // Given
        let message = ChatMessage.mock()
        let channelController = makeChannelController(messages: [message])
        channelController.channel_mock = .mock(cid: .unique, unreadCount: ChannelUnreadCount(messages: 1, mentions: 0))
        let viewModel = ChatChannelViewModel(channelController: channelController)
        viewModel.currentUserMarkedMessageUnread = true
        viewModel.throttler = Throttler_Mock(interval: 0)
        
        // When
        viewModel.handleMessageAppear(index: 0, scrollDirection: .down)
        
        // Then
        XCTAssertEqual(0, channelController.markReadCallCount)
    }
    
    func test_chatChannelVM_sendReadEventIfNeeded_whenCurrentUserMarkedMessageUnreadIsFalse() {
        // Given
        let message = ChatMessage.mock()
        let channelController = makeChannelController(messages: [message])
        channelController.channel_mock = .mock(cid: .unique, unreadCount: ChannelUnreadCount(messages: 1, mentions: 0))
        let viewModel = ChatChannelViewModel(channelController: channelController)
        viewModel.currentUserMarkedMessageUnread = false
        viewModel.throttler = Throttler_Mock(interval: 0)
        
        // When
        viewModel.handleMessageAppear(index: 0, scrollDirection: .down)
        
        // Then
        XCTAssertEqual(1, channelController.markReadCallCount)
    }
    
    func test_chatChannelVM_sendReadEventIfNeeded_whenChannelHasNoUnreadMessages() {
        // Given
        let message = ChatMessage.mock()
        let channelController = makeChannelController(messages: [message])
        channelController.channel_mock = .mock(cid: .unique, unreadCount: ChannelUnreadCount(messages: 0, mentions: 0))
        let viewModel = ChatChannelViewModel(channelController: channelController)
        viewModel.currentUserMarkedMessageUnread = false
        viewModel.throttler = Throttler_Mock(interval: 0)
        
        // When
        viewModel.handleMessageAppear(index: 0, scrollDirection: .down)
        
        // Then
        XCTAssertEqual(0, channelController.markReadCallCount)
    }
    
    func test_chatChannelVM_sendReadEventIfNeeded_whenChannelIsNil() {
        // Given
        let message = ChatMessage.mock()
        let channelController = makeChannelController(messages: [message])
        channelController.channel_mock = nil
        let viewModel = ChatChannelViewModel(channelController: channelController)
        viewModel.currentUserMarkedMessageUnread = false
        viewModel.throttler = Throttler_Mock(interval: 0)
        
        // When
        viewModel.handleMessageAppear(index: 0, scrollDirection: .down)
        
        // Then
        XCTAssertEqual(0, channelController.markReadCallCount)
    }

    func test_chatChannelVM_handleMessageAppear_doesNotCrashWhenDeallocated() {
        let message = ChatMessage.mock()
        let channelController = makeChannelController(messages: [message])
        channelController.hasLoadedAllNextMessages_mock = nil
        channelController.channel_mock = .mock(
            cid: .unique,
            unreadCount: ChannelUnreadCount(messages: 1, mentions: 0)
        )

        for _ in 0..<1000 {
            autoreleasepool {
                let viewModel = ChatChannelViewModel(channelController: channelController)
                viewModel.handleMessageAppear(index: 0, scrollDirection: .down)
                viewModel.handleMessageAppear(index: 0, scrollDirection: .down)
                viewModel.handleMessageAppear(index: 0, scrollDirection: .down)
                viewModel.handleMessageAppear(index: 0, scrollDirection: .down)
                viewModel.handleMessageAppear(index: 0, scrollDirection: .down)
                viewModel.handleMessageAppear(index: 0, scrollDirection: .down)
            }
        }
        
        // Then - Should not crash
        XCTAssert(true)
    }

    // MARK: - highlightMessage Tests
    
    func test_highlightMessage_highlightsWhenSkipHighlightMessageIdIsNotSet() {
        // Given
        let message = ChatMessage.mock()
        let channelController = makeChannelController(messages: [message])
        let viewModel = ChatChannelViewModel(channelController: channelController)
        let testExpectation = XCTestExpectation(description: "Message should be highlighted")
        
        // When
        viewModel.highlightMessage(withId: message.messageId)
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            XCTAssertEqual(viewModel.highlightedMessageId, message.messageId)
            testExpectation.fulfill()
        }
        
        wait(for: [testExpectation], timeout: defaultTimeout)
    }
    
    func test_highlightMessage_highlightsWhenSkipHighlightMessageIdDoesNotMatch() {
        // Given
        let message1 = ChatMessage.mock()
        let message2 = ChatMessage.mock()
        let channelController = makeChannelController(messages: [message1, message2])
        let viewModel = ChatChannelViewModel(channelController: channelController)
        viewModel.skipHighlightMessageId = message1.messageId
        let testExpectation = XCTestExpectation(description: "Message should be highlighted")
        
        // When
        viewModel.highlightMessage(withId: message2.messageId)
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            XCTAssertEqual(viewModel.highlightedMessageId, message2.messageId)
            XCTAssertEqual(viewModel.skipHighlightMessageId, message1.messageId)
            testExpectation.fulfill()
        }
        
        wait(for: [testExpectation], timeout: defaultTimeout)
    }
    
    func test_highlightMessage_doesNotHighlightWhenSkipHighlightMessageIdMatches() {
        // Given
        let message = ChatMessage.mock()
        let channelController = makeChannelController(messages: [message])
        let viewModel = ChatChannelViewModel(channelController: channelController)
        viewModel.skipHighlightMessageId = message.messageId
        let testExpectation = XCTestExpectation(description: "Message should not be highlighted")
        
        // When
        viewModel.highlightMessage(withId: message.messageId)
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            XCTAssertNil(viewModel.highlightedMessageId)
            testExpectation.fulfill()
        }
        
        wait(for: [testExpectation], timeout: defaultTimeout)
    }
    
    func test_highlightMessage_clearsSkipHighlightMessageIdAfterSkipping() {
        // Given
        let message = ChatMessage.mock()
        let channelController = makeChannelController(messages: [message])
        let viewModel = ChatChannelViewModel(channelController: channelController)
        viewModel.skipHighlightMessageId = message.messageId
        
        // When
        viewModel.highlightMessage(withId: message.messageId)
        
        // Then
        XCTAssertNil(viewModel.skipHighlightMessageId)
        XCTAssertNil(viewModel.highlightedMessageId)
    }

    // MARK: - private

    private func makeChannelController(
        messages: [ChatMessage] = []
    ) -> ChatChannelController_Mock {
        ChatChannelTestHelpers.makeChannelController(
            chatClient: chatClient,
            messages: messages
        )
    }
}

private class Throttler_Mock: Throttler {
    override func execute(_ action: @escaping () -> Void) {
        action()
    }
}
