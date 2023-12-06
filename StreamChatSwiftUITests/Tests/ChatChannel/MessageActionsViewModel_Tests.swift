//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class MessageActionsViewModel_Tests: StreamChatTestCase {

    func test_messageActionsViewModel_confirmationAlertShown() {
        // Given
        let actions = MessageAction.defaultActions(
            factory: DefaultViewFactory.shared,
            for: .mock(
                id: .unique,
                cid: .unique,
                text: "test",
                author: .mock(id: .unique)
            ),
            channel: .mockDMChannel(),
            chatClient: chatClient,
            onFinish: { _ in },
            onError: { _ in }
        )
        let viewModel = MessageActionsViewModel(messageActions: actions)
        let action = actions[5]

        // When
        viewModel.alertAction = action

        // Then
        XCTAssert(action.confirmationPopup != nil)
        XCTAssert(viewModel.alertShown == true)
    }
}
