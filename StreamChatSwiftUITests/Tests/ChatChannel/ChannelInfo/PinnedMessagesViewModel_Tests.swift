//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class PinnedMessagesViewModel_Tests: StreamChatTestCase {

    func test_pinnedMessagesVM_notEmpty() {
        // Given
        let channel = ChatChannel.mockDMChannel(
            pinnedMessages: [ChannelInfoMockUtils.pinnedMessage]
        )

        // When
        let viewModel = PinnedMessagesViewModel(channel: channel)
        let messages = viewModel.pinnedMessages

        // Then
        XCTAssert(messages.count == 1)
    }

    func test_pinnedMessagesVM_empty() {
        // Given
        let channel = ChatChannel.mockDMChannel()

        // When
        let viewModel = PinnedMessagesViewModel(channel: channel)
        let messages = viewModel.pinnedMessages

        // Then
        XCTAssert(messages.isEmpty)
    }
}
