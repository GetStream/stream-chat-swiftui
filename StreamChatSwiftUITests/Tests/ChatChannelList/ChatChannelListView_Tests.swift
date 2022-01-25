//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class ChatChannelListView_Tests: StreamChatTestCase {
        
    func test_chatChannelScreen_snapshot() {
        // Given
        let controller = makeChannelListController()
        
        // When
        let view = ChatChannelListScreen(channelListController: controller)
            .frame(width: defaultScreenSize.width, height: defaultScreenSize.height)
        
        // Then
        assertSnapshot(matching: view, as: .image)
    }

    func test_chatChannelListView_snapshot() {
        // Given
        let controller = makeChannelListController()
        
        // When
        let view = ChatChannelListView(
            viewFactory: DefaultViewFactory.shared,
            channelListController: controller
        )
        .frame(width: defaultScreenSize.width, height: defaultScreenSize.height)

        // Then
        assertSnapshot(matching: view, as: .image)
    }
    
    private func makeChannelListController() -> ChatChannelListController_Mock {
        let channelListController = ChatChannelListController_Mock.mock()
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
