//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import XCTest

@MainActor class PinnedMessagesViewModel_Tests: StreamChatTestCase {
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

    // MARK: - Loading state

    func test_isLoading_falseWithoutChannelController() {
        // Given
        let channel = ChatChannel.mockDMChannel(
            pinnedMessages: [ChannelInfoMockUtils.pinnedMessage]
        )

        // When
        let viewModel = PinnedMessagesViewModel(channel: channel)

        // Then
        XCTAssertFalse(viewModel.isLoading)
    }

    func test_isLoading_trueWhileChannelControllerLoads() {
        // Given
        let channel = ChatChannel.mockDMChannel()
        let controller = ChatChannelController_Mock.mock(chatClientConfig: nil)

        // When
        let viewModel = PinnedMessagesViewModel(channel: channel, channelController: controller)

        // Then - loading starts true before the async completion fires
        XCTAssertTrue(viewModel.isLoading)
    }
}
