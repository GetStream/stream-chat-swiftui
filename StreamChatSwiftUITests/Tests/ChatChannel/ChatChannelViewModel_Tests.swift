//
// Copyright © 2021 Stream.io Inc. All rights reserved.
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
        XCTAssert(viewModel.scrolledId == messageId)
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
