//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

class ChatChannelListView_Tests: StreamChatTestCase {

    func test_chatChannelScreen_snapshot() {
        // Given
        let controller = makeChannelListController()

        // When
        let view = ChatChannelListScreen(channelListController: controller)
            .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_chatChannelListView_snapshot() {
        // Given
        let controller = makeChannelListController()

        // When
        let view = ChatChannelListView(
            viewFactory: DefaultViewFactory.shared,
            channelListController: controller
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_chatChannelListViewSansNavigation_snapshot() {
        // Given
        let controller = makeChannelListController()

        // When
        let view = NavigationView {
            ChatChannelListView(
                viewFactory: DefaultViewFactory.shared,
                channelListController: controller,
                embedInNavigationView: false
            )
        }
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_trailingSwipeActionsView_snapshot() {
        // Given
        let view = TrailingSwipeActionsView(
            channel: .mockDMChannel(),
            offsetX: 80,
            buttonWidth: 40,
            leftButtonTapped: { _ in },
            rightButtonTapped: { _ in }
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    private func makeChannelListController() -> ChatChannelListController_Mock {
        let channelListController = ChatChannelListController_Mock.mock(client: chatClient)
        channelListController.simulateInitial(channels: mockChannels(), state: .initialized)
        return channelListController
    }

    private func mockChannels() -> [ChatChannel] {
        var channels = [ChatChannel]()
        for i in 0..<15 {
            let channel = ChatChannel.mockDMChannel(name: "test \(i)")
            channels.append(channel)
        }
        return channels
    }
}
