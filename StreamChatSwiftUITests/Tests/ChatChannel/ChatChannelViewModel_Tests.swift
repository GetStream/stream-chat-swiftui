//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import SwiftUI
import XCTest

@MainActor class ChatChannelViewModel_Tests: StreamChatTestCase {
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
        streamChat = StreamChat(
            chatClient: chatClient,
            utils: Utils(
                messageListConfig: .init(dateIndicatorPlacement: .overlay)
            )
        )
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
            didUpdateMessages: messages,
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
        XCTAssert(viewModel.shouldShowInlineTypingIndicator == false)
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

    func test_chatChannelVM_typingIndicatorInline() {
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
        XCTAssert(viewModel.shouldShowInlineTypingIndicator == true)
    }

    // MARK: - Automatic typing indicator placement

    func test_chatChannelVM_automaticPlacement_showsInlineTypingIndicator() {
        // Given
        let utils = Utils(
            messageListConfig: MessageListConfig(typingIndicatorPlacement: .automatic)
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

        // Then
        XCTAssertTrue(viewModel.shouldShowInlineTypingIndicator)
    }

    func test_chatChannelVM_automaticPlacement_hidesNavBarTypingIndicatorWhenAtBottom() {
        // Given
        let utils = Utils(
            messageListConfig: MessageListConfig(typingIndicatorPlacement: .automatic)
        )
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
        let channelController = makeChannelController()
        let typingUser: ChatChannelMember = ChatChannelMember.mock(id: .unique)
        let viewModel = ChatChannelViewModel(channelController: channelController)
        viewModel.showScrollToLatestButton = false

        // When
        let channel: ChatChannel = .mockDMChannel(currentlyTypingUsers: Set(arrayLiteral: typingUser))
        channelController.simulate(
            channel: channel,
            change: .update(channel),
            typingUsers: Set(arrayLiteral: typingUser)
        )

        // Then
        XCTAssertFalse(viewModel.shouldShowNavigationBarTypingIndicator)
        XCTAssertEqual(viewModel.channelHeaderType, .regular)
    }

    func test_chatChannelVM_automaticPlacement_showsNavBarTypingIndicatorWhenScrolledUp() {
        // Given
        let utils = Utils(
            messageListConfig: MessageListConfig(typingIndicatorPlacement: .automatic)
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
        viewModel.showScrollToLatestButton = true

        // Then
        XCTAssertTrue(viewModel.shouldShowNavigationBarTypingIndicator)
        XCTAssertEqual(viewModel.channelHeaderType, .typingIndicator)
    }

    func test_chatChannelVM_automaticPlacement_hidesNavBarTypingIndicatorWhenScrolledBackToBottom() {
        // Given
        let utils = Utils(
            messageListConfig: MessageListConfig(typingIndicatorPlacement: .automatic)
        )
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
        let channelController = makeChannelController()
        let typingUser: ChatChannelMember = ChatChannelMember.mock(id: .unique)
        let viewModel = ChatChannelViewModel(channelController: channelController)

        let channel: ChatChannel = .mockDMChannel(currentlyTypingUsers: Set(arrayLiteral: typingUser))
        channelController.simulate(
            channel: channel,
            change: .update(channel),
            typingUsers: Set(arrayLiteral: typingUser)
        )
        viewModel.showScrollToLatestButton = true
        XCTAssertTrue(viewModel.shouldShowNavigationBarTypingIndicator)

        // When
        viewModel.showScrollToLatestButton = false

        // Then
        XCTAssertFalse(viewModel.shouldShowNavigationBarTypingIndicator)
        XCTAssertEqual(viewModel.channelHeaderType, .regular)
    }

    func test_chatChannelVM_navigationBarPlacement_showsNavBarTypingIndicatorRegardlessOfScroll() {
        // Given
        let utils = Utils(
            messageListConfig: MessageListConfig(typingIndicatorPlacement: .navigationBar)
        )
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
        let channelController = makeChannelController()
        let typingUser: ChatChannelMember = ChatChannelMember.mock(id: .unique)
        let viewModel = ChatChannelViewModel(channelController: channelController)
        viewModel.showScrollToLatestButton = false

        // When
        let channel: ChatChannel = .mockDMChannel(currentlyTypingUsers: Set(arrayLiteral: typingUser))
        channelController.simulate(
            channel: channel,
            change: .update(channel),
            typingUsers: Set(arrayLiteral: typingUser)
        )

        // Then
        XCTAssertTrue(viewModel.shouldShowNavigationBarTypingIndicator)
        XCTAssertFalse(viewModel.shouldShowInlineTypingIndicator)
    }

    func test_chatChannelVM_inlinePlacement_neverShowsNavBarTypingIndicator() {
        // Given
        let utils = Utils(
            messageListConfig: MessageListConfig(typingIndicatorPlacement: .inline)
        )
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
        let channelController = makeChannelController()
        let typingUser: ChatChannelMember = ChatChannelMember.mock(id: .unique)
        let viewModel = ChatChannelViewModel(channelController: channelController)
        viewModel.showScrollToLatestButton = true

        // When
        let channel: ChatChannel = .mockDMChannel(currentlyTypingUsers: Set(arrayLiteral: typingUser))
        channelController.simulate(
            channel: channel,
            change: .update(channel),
            typingUsers: Set(arrayLiteral: typingUser)
        )

        // Then
        XCTAssertFalse(viewModel.shouldShowNavigationBarTypingIndicator)
        XCTAssertTrue(viewModel.shouldShowInlineTypingIndicator)
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
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Some text",
            author: .mock(id: .unique)
        )
        let channelController = makeChannelController(messages: [message])
        let viewModel = ChatChannelViewModel(channelController: channelController)

        // When
        NotificationCenter.default.post(
            name: MessageRepliesConstants.threadMessageNavigationNotification,
            object: nil,
            userInfo: [MessageRepliesConstants.threadMessageParentId: message.messageId]
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
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Test message",
            author: .mock(id: .unique)
        )
        let channelController = makeChannelController(messages: [message])
        let viewModel = ChatChannelViewModel(channelController: channelController)

        // When
        NotificationCenter.default.post(
            name: MessageRepliesConstants.threadMessageNavigationNotification,
            object: nil,
            userInfo: [MessageRepliesConstants.threadMessageParentId: message.messageId]
        )

        // Then
        XCTAssertEqual(viewModel.threadMessage, message)
        XCTAssertTrue(viewModel.threadMessageShown)
    }

    func test_chatChannelVM_selectedMessageThread_withThreadReplyMessage_opensThread() {
        // Given
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
        let channelController = makeChannelController(messages: [parentMessage, replyMessage])
        let viewModel = ChatChannelViewModel(channelController: channelController)

        // When
        NotificationCenter.default.post(
            name: MessageRepliesConstants.threadMessageNavigationNotification,
            object: nil,
            userInfo: [
                MessageRepliesConstants.threadMessageParentId: parentMessage.messageId,
                MessageRepliesConstants.threadMessageReplyId: replyMessage.messageId
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
        let newMessages = [message1, message2, message3]
        
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
    
    func test_chatChannelVM_sendReadEventIfNeeded_whenChannelHasNoReads_thenMarkReadIsCalled() {
        // Given
        let message = ChatMessage.mock()
        let channelController = makeChannelController(messages: [message])
        channelController.channel_mock = .mockDMChannel(reads: [])
        channelController.hasLoadedAllNextMessages_mock = true
        let viewModel = ChatChannelViewModel(channelController: channelController)
        viewModel.currentUserMarkedMessageUnread = false
        viewModel.throttler = Throttler_Mock(interval: 0)
        
        // When
        viewModel.handleMessageAppear(index: 0, scrollDirection: .down)
        
        // Then
        XCTAssertEqual(1, channelController.markReadCallCount)
    }
    
    func test_chatChannelVM_sendReadEventIfNeeded_whenChannelReadHasMoreRecentTimestamp_thenMarkReadIsNotCalled() {
        // Given
        let message = ChatMessage.mock()
        let channelController = makeChannelController(messages: [message])
        channelController.channel_mock = .mockDMChannel(
            reads: [.mock(
                lastReadAt: .distantFuture,
                lastReadMessageId: .unique,
                unreadMessagesCount: 0,
                user: .mock(id: chatClient.currentUserId ?? "")
            )]
        )
        channelController.hasLoadedAllNextMessages_mock = true
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

    // MARK: - Pending markRead Tests

    func test_chatChannelVM_sendReadEventIfNeeded_whenLatestMessageIsLocalOnly_thenMarkReadIsNotCalled() {
        // Given - the latest message is still in flight (e.g., the user's first message
        // in an empty channel).
        let pendingMessage = ChatMessage.mock(localState: .pendingSend)
        let channelController = makeChannelController(messages: [pendingMessage])
        channelController.channel_mock = .mockDMChannel(reads: [])
        channelController.hasLoadedAllNextMessages_mock = true
        let viewModel = ChatChannelViewModel(channelController: channelController)
        viewModel.currentUserMarkedMessageUnread = false
        viewModel.throttler = Throttler_Mock(interval: 0)

        // When
        viewModel.handleMessageAppear(index: 0, scrollDirection: .down)

        // Then - markRead must not be called while the message is still local-only.
        XCTAssertEqual(0, channelController.markReadCallCount)
    }

    func test_chatChannelVM_sendReadEventIfNeeded_whenPendingMessageBecomesSent_thenMarkReadIsCalled() {
        // Given - empty channel that received a local pendingSend message.
        let messageId: MessageId = .unique
        let pendingMessage = ChatMessage.mock(id: messageId, localState: .pendingSend)
        let channelController = makeChannelController(messages: [pendingMessage])
        channelController.channel_mock = .mockDMChannel(reads: [])
        channelController.hasLoadedAllNextMessages_mock = true
        let viewModel = ChatChannelViewModel(channelController: channelController)
        viewModel.currentUserMarkedMessageUnread = false
        viewModel.throttler = Throttler_Mock(interval: 0)
        viewModel.handleMessageAppear(index: 0, scrollDirection: .down)
        XCTAssertEqual(0, channelController.markReadCallCount)

        // When - the same message transitions to fully sent (localState becomes nil).
        let sentMessage = ChatMessage.mock(id: messageId, localState: nil)
        channelController.messages_mock = [sentMessage]
        let dataSource = ChatChannelDataSource(controller: channelController)
        viewModel.dataSource(
            channelDataSource: dataSource,
            didUpdateMessages: [sentMessage],
            changes: [.update(sentMessage, index: IndexPath(row: 0, section: 0))]
        )

        // Then - markRead fires exactly once for the now-sent latest message.
        XCTAssertEqual(1, channelController.markReadCallCount)
    }

    func test_chatChannelVM_sendReadEventIfNeeded_whenNonEmptyChannelReceivesPendingMessage_thenMarkReadIsCalledOnlyAfterSent() {
        // Given - non-empty channel already at the bottom.
        let existing = ChatMessage.mock(id: .unique, localState: nil)
        let channelController = makeChannelController(messages: [existing])
        channelController.channel_mock = .mockDMChannel(reads: [])
        channelController.hasLoadedAllNextMessages_mock = true
        let viewModel = ChatChannelViewModel(channelController: channelController)
        viewModel.currentUserMarkedMessageUnread = false
        viewModel.throttler = Throttler_Mock(interval: 0)
        viewModel.handleMessageAppear(index: 0, scrollDirection: .down)
        let baseline = channelController.markReadCallCount

        // When - user sends a new message; it appears in `.pendingSend` first.
        let newId: MessageId = .unique
        let pendingMessage = ChatMessage.mock(id: newId, localState: .pendingSend)
        channelController.messages_mock = [pendingMessage, existing]
        let dataSource = ChatChannelDataSource(controller: channelController)
        viewModel.dataSource(
            channelDataSource: dataSource,
            didUpdateMessages: [pendingMessage, existing],
            changes: [.insert(pendingMessage, index: IndexPath(row: 0, section: 0))]
        )
        viewModel.handleMessageAppear(index: 0, scrollDirection: .down)
        XCTAssertEqual(baseline, channelController.markReadCallCount)

        // When - the new message transitions to sent.
        let sentMessage = ChatMessage.mock(id: newId, localState: nil)
        channelController.messages_mock = [sentMessage, existing]
        viewModel.dataSource(
            channelDataSource: dataSource,
            didUpdateMessages: [sentMessage, existing],
            changes: [.update(sentMessage, index: IndexPath(row: 0, section: 0))]
        )

        // Then - markRead fires exactly once for the now-sent latest message.
        XCTAssertEqual(baseline + 1, channelController.markReadCallCount)
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
