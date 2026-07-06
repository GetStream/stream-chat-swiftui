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

@MainActor class ChatChannelListView_Tests: StreamChatTestCase {
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

    func test_trailingSwipeActionsView_unmuted_snapshot() {
        // Given - channel is not muted, swipe action shows mute (speaker.slash) icon
        let channel = ChatChannel.mockDMChannel()
        let view = TrailingSwipeActionsView(
            channel: channel,
            offsetX: -160,
            buttonWidth: 80,
            leftButtonTapped: { _ in },
            rightButtonTapped: { _ in }
        )
        .frame(
            width: defaultScreenSize.width,
            height: 64
        )

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_trailingSwipeActionsView_muted_snapshot() {
        // Given - channel is muted, swipe action shows unmute (speaker.wave.2) icon
        let channel = ChatChannel.mockDMChannel(
            muteDetails: .init(createdAt: .unique, updatedAt: .unique, expiresAt: nil)
        )
        let view = TrailingSwipeActionsView(
            channel: channel,
            offsetX: -160,
            buttonWidth: 80,
            leftButtonTapped: { _ in },
            rightButtonTapped: { _ in }
        )
        .frame(
            width: defaultScreenSize.width,
            height: 64
        )

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_trailingSwipeActionsView_rightToLeft_snapshot() {
        // Given - in RTL, the action buttons should be aligned to the leading
        // (left) edge with the destructive/primary action appearing leftmost.
        let channel = ChatChannel.mockDMChannel()
        let view = TrailingSwipeActionsView(
            channel: channel,
            offsetX: -160,
            buttonWidth: 80,
            leftButtonTapped: { _ in },
            rightButtonTapped: { _ in }
        )
        .frame(
            width: defaultScreenSize.width,
            height: 64
        )
        .environment(\.layoutDirection, .rightToLeft)

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

    // MARK: - ChannelListRowContainer equality

    func test_channelListRowContainer_whenNothingChanged_isEqual() {
        // Given
        let channel = ChatChannel.mockDMChannel(name: "test")

        // When
        let container1 = makeRowContainer(channel: channel)
        let container2 = makeRowContainer(channel: channel)

        // Then
        XCTAssertEqual(container1, container2)
    }

    func test_channelListRowContainer_whenChannelContentChanged_isNotEqual() {
        // Given
        let cid = ChannelId.unique
        let channel1 = ChatChannel.mock(cid: cid, name: "test")
        let channel2 = ChatChannel.mock(cid: cid, name: "renamed")

        // When
        let container1 = makeRowContainer(channel: channel1)
        let container2 = makeRowContainer(channel: channel2)

        // Then
        XCTAssertNotEqual(container1, container2)
    }

    func test_channelListRowContainer_whenDisabledChanged_isNotEqual() {
        // Given
        let channel = ChatChannel.mockDMChannel(name: "test")

        // When
        let container1 = makeRowContainer(channel: channel, disabled: false)
        let container2 = makeRowContainer(channel: channel, disabled: true)

        // Then
        XCTAssertNotEqual(container1, container2)
    }

    func test_channelListRowContainer_whenSelectionChanged_isNotEqual() {
        // Given
        let channel = ChatChannel.mockDMChannel(name: "test")

        // When
        let container1 = makeRowContainer(channel: channel, isSelected: false)
        let container2 = makeRowContainer(channel: channel, isSelected: true)

        // Then
        XCTAssertNotEqual(container1, container2)
    }

    private func makeRowContainer(
        channel: ChatChannel,
        disabled: Bool = false,
        isSelected: Bool = false
    ) -> ChannelListRowContainer<DefaultViewFactory> {
        ChannelListRowContainer(
            factory: DefaultViewFactory.shared,
            channel: channel,
            disabled: disabled,
            isSelected: isSelected,
            selectedChannel: .constant(nil),
            swipedChannelId: .constant(nil),
            channelDestination: nil,
            onItemTap: { _ in },
            trailingSwipeRightButtonTapped: { _ in },
            trailingSwipeLeftButtonTapped: { _ in },
            leadingSwipeButtonTapped: { _ in }
        )
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
    var styles = LiquidGlassStyles()
    
    func makeChannelAvatarView(
        options: ChannelAvatarViewOptions
    ) -> some View {
        Circle()
            .fill(.red)
            .frame(width: options.size, height: options.size)
    }
}

class ChannelAvatarViewRegularFactory: ViewFactory {
    @Injected(\.chatClient) var chatClient
    var styles = RegularStyles()

    func makeChannelAvatarView(
        options: ChannelAvatarViewOptions
    ) -> some View {
        Circle()
            .fill(.red)
            .frame(width: options.size, height: options.size)
    }
}
