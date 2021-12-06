//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class MessageActionsViewModel_Tests: XCTestCase {
    
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

    func test_messageActionsViewModel_confirmationAlertShown() {
        // Given
        let actions = MessageAction.defaultActions(
            for: .mock(
                id: .unique,
                cid: .unique,
                text: "test",
                author: .mock(id: .unique)
            ),
            chatClient: chatClient,
            onDismiss: {},
            onError: { _ in }
        )
        let viewModel = MessageActionsViewModel(messageActions: actions)
        let action = actions[0]
        
        // When
        viewModel.alertAction = action
        
        // Then
        XCTAssert(action.confirmationPopup != nil)
        XCTAssert(viewModel.alertShown == true)
    }
}
