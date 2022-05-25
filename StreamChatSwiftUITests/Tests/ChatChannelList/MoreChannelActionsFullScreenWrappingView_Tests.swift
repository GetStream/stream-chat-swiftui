//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import SwiftUI
import XCTest

class MoreChannelActionsFullScreenWrappingView_Tests: StreamChatTestCase {
    func test_moreChannelActionsFullScreenWrappingView_snapshot() {
        // Given
        let channel = ChatChannel.mockDMChannel(name: "test")
        
        // When
        let infoView = ChatChannelInfoView(channel: channel)
        
        let wrappingView = MoreChannelActionsFullScreenWrappingView(
            presentedView: AnyView(infoView),
            onDismiss: { /* no-op */ }
        ).applyDefaultSize()
        
        // Then
        assertSnapshot(matching: wrappingView, as: .image)
    }
}
