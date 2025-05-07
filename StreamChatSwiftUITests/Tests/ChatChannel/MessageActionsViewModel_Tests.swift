//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

@MainActor class MessageActionsViewModel_Tests: StreamChatTestCase {

    func test_messageActionsViewModel_confirmationAlertShown() {
        // Given
        let utils = Utils(messageListConfig: .init(userBlockingEnabled: true))
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
        let actions = MessageAction.defaultActions(
            factory: DefaultViewFactory.shared,
            for: .mock(
                id: .unique,
                cid: .unique,
                text: "test",
                author: .mock(id: .unique)
            ),
            channel: .mockDMChannel(ownCapabilities: [.sendMessage, .uploadFile, .pinMessage]),
            chatClient: chatClient,
            onFinish: { _ in },
            onError: { _ in }
        )
        let viewModel = MessageActionsViewModel(messageActions: actions)
        let action = actions[6]

        // When
        viewModel.alertAction = action

        // Then
        XCTAssert(action.confirmationPopup != nil)
        XCTAssert(viewModel.alertShown == true)
    }
}
