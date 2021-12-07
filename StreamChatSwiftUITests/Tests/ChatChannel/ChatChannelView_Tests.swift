//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class ChatChannelView_Tests: XCTestCase {

    private var chatClient: ChatClient = {
        let client = ChatClient.mock()
        client.currentUserId = .unique
        return client
    }()
    
    private let testMessage = ChatMessage.mock(
        id: "test",
        cid: .unique,
        text: "This is a test message",
        author: .mock(id: "test", name: "martin")
    )
    
    private var streamChat: StreamChat?
    
    override func setUp() {
        super.setUp()
        streamChat = StreamChat(chatClient: chatClient)
    }
    
    func test_chatChannelScreen_snapshot() {
        // Given
        let messages = [testMessage]
        let controller = ChatChannelTestHelpers.makeChannelController(
            chatClient: chatClient,
            messages: messages
        )
        
        // When
        let view = ChatChannelScreen(chatChannelController: controller)
            .frame(width: defaultScreenSize.width, height: defaultScreenSize.height)
        
        // Then
        assertSnapshot(matching: view, as: .image)
    }
    
    func test_chatChannelView_snapshot() {
        // Given
        let messages = [testMessage]
        let controller = ChatChannelTestHelpers.makeChannelController(
            chatClient: chatClient,
            messages: messages
        )
        
        // When
        let view = ChatChannelView(
            viewFactory: DefaultViewFactory.shared,
            channelController: controller
        )
        .frame(width: defaultScreenSize.width, height: defaultScreenSize.height)

        // Then
        assertSnapshot(matching: view, as: .image)
    }
}
