//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

@testable import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import SwiftUI
import XCTest

class PinnedMessagesView_Tests: StreamChatTestCase {

    func test_pinnedMessagesView_notEmptySnapshot() {
        // Given
        let channel = ChatChannel.mockDMChannel(
            pinnedMessages: [ChannelInfoMockUtils.pinnedMessage]
        )
        
        // When
        let view = PinnedMessagesView(channel: channel)
            .applyDefaultSize()
        
        // Then
        assertSnapshot(matching: view, as: .image)
    }
    
    func test_pinnedMessagesView_emptySnapshot() {
        // Given
        let channel = ChatChannel.mockDMChannel()
        
        // When
        let view = PinnedMessagesView(channel: channel)
            .applyDefaultSize()
        
        // Then
        assertSnapshot(matching: view, as: .image)
    }
}
