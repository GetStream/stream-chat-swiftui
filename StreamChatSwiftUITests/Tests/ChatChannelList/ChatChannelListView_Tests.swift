//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

class ChatChannelListView_Tests: StreamChatTestCase {

    @MainActor func test_chatChannelListView_snapshot() {
        // Given
        let channelList = makeChannelList()

        // When
        let view = ChatChannelListView(
            viewFactory: DefaultViewFactory.shared,
            channelList: channelList
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    @MainActor func test_chatChannelListViewSansNavigation_snapshot() {
        // Given
        let channelList = makeChannelList()

        // When
        let view = NavigationView {
            ChatChannelListView(
                viewFactory: DefaultViewFactory.shared,
                channelList: channelList,
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

    private func makeChannelList() -> ChannelList_Mock {
        let channels = mockChannels()
        let channelList = ChannelList_Mock.mock(channels: channels)
        channelList.state.channels = StreamCollection(channels)
        return channelList
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
