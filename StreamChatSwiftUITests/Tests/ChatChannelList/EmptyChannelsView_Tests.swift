//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class EmptyChannelsView_Tests: StreamChatTestCase {
    func test_emptyChannelsView_snapshot() {
        // Given
        let view = EmptyChannelsView()
            .frame(width: 375, height: 600)

        // Then
        AssertSnapshot(view, size: CGSize(width: 375, height: 600))
    }
}
