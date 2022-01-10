//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class ChatChannelViewModel_Tests: XCTestCase {

    private var chatClient: ChatClient = {
        let client = ChatClient.mock()
        client.currentUserId = .unique
        return client
    }()
    
    private var streamChat: StreamChat?
        
    override func setUp() {
        super.setUp()
        streamChat = StreamChat(chatClient: chatClient)
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
        XCTAssert(messagesGroupingInfo.count == 8)
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
    
    func test_chatChannelVM_currentDateString() {
        // Given
        let expectedDate = "Jan 01"
        let channelController = makeChannelController()
        let viewModel = ChatChannelViewModel(channelController: channelController)
        
        // When
        viewModel.showScrollToLatestButton = true
        viewModel.handleMessageAppear(index: 0)
        
        // Then
        let dateString = viewModel.currentDateString
        XCTAssert(dateString == expectedDate)
    }
    
    func test_chatChannelVM_showReactionsOverlay() {
        // Given
        let channelController = makeChannelController()
        let viewModel = ChatChannelViewModel(channelController: channelController)
        
        // When
        viewModel.showReactionOverlay()
        
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
    
    func test_chatChannelVM_messageThread() {
        // Given
        let channelController = makeChannelController()
        let messageController = ChatMessageController_Mock(
            client: chatClient,
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
    }
    
    func test_chatChannelVM_typingIndicatorMessageHeader() {
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
        let headerType = viewModel.channelHeaderType
        
        // Then
        XCTAssert(headerType == .typingIndicator)
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
