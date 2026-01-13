//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import XCTest

class TypingIndicatorView_Tests: StreamChatTestCase {
    func test_typingIndicatorView_snapshot() {
        // Given
        let view = TypingIndicatorView(isTyping: true)
            .frame(width: 20, height: 16)

        // Then
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles, size: CGSize(width: 20, height: 16))
    }
}
