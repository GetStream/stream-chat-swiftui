//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
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

    func test_chatChannelListView_showChannelListDividerOnLastItem_snapshot() {
        // Given
        let controller = ChatChannelListController_Mock.mock(client: chatClient)
        controller.simulateInitial(
            channels: [
                .mock(cid: .unique, name: "Test 1"),
                .mock(cid: .unique, name: "Test 2"),
                .mock(cid: .unique, name: "Test 3")
            ],
            state: .initialized
        )

        // When enabled
        let utils = Utils(channelListConfig: .init(showChannelListDividerOnLastItem: true))
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
        let view = ChatChannelListView(
            viewFactory: DefaultViewFactory.shared,
            channelListController: controller
        )
        .applyDefaultSize()
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision), named: "enabled")

        // When disabled
        let utilsWithoutLastItemDivider = Utils(channelListConfig: .init(showChannelListDividerOnLastItem: false))
        streamChat = StreamChat(chatClient: chatClient, utils: utilsWithoutLastItemDivider)
        let viewWithoutLastItemDivider = ChatChannelListView(
            viewFactory: DefaultViewFactory.shared,
            channelListController: controller
        )
        .applyDefaultSize()
        // Then
        assertSnapshot(matching: viewWithoutLastItemDivider, as: .image(perceptualPrecision: precision), named: "disabled")
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
    
    func test_channelListView_channelAvatarUpdated() {
        // Given
        let controller = makeChannelListController()

        // When
        let view = ChatChannelListView(
            viewFactory: ChannelAvatarViewFactory(),
            channelListController: controller
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_channelListView_themedNavigationBar() {
        // Given
        setThemedNavigationBarAppearance()
        let controller = makeChannelListController()

        // When
        let view = ChatChannelListView(
            channelListController: controller
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

class ChannelAvatarViewFactory: ViewFactory {
    @Injected(\.chatClient) var chatClient
    
    func makeChannelAvatarView(
        for channel: ChatChannel,
        with options: ChannelAvatarViewOptions
    ) -> some View {
        Circle()
            .fill(.red)
            .frame(width: options.size.width, height: options.size.height)
    }
}
