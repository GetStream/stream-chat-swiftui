//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest
import SwiftUI

class MoreChannelActionsFullScreenWrappingView_Tests: StreamChatTestCase {
    func test_moreChannelActionsView_snapshot() {
        // Given
        let channel: ChatChannel = .mockDMChannel(name: "test")
        
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
