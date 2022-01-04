//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class MoreChannelActionsView_Tests: XCTestCase {

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
    
    func test_moreChannelActionsView_snapshot() {
        // Given
        let channel: ChatChannel = .mockDMChannel(name: "test")
        let actions = ChannelAction.defaultActions(
            for: channel,
            chatClient: chatClient,
            onDismiss: {},
            onError: { _ in }
        )
        
        // When
        let view = MoreChannelActionsView(channel: channel, channelActions: actions, onDismiss: {})
            .frame(width: defaultScreenSize.width, height: defaultScreenSize.height)
        
        // Then
        assertSnapshot(matching: view, as: .image)
    }
}
