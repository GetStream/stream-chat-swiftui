//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import SwiftUI
import XCTest

class MoreChannelActionsFullScreenWrappingView_Tests: StreamChatTestCase {
    func test_moreChannelActionsFullScreenWrappingView_snapshot() {
        // When
        let emptyView = Text("Default Empty More Channel Actions FullScreen View")

        let wrappingView = MoreChannelActionsFullScreenWrappingView(
            presentedView: AnyView(emptyView),
            onDismiss: { /* no-op */ }
        ).applyDefaultSize()

        // Then
        assertSnapshot(matching: wrappingView, as: .image)
    }
}
