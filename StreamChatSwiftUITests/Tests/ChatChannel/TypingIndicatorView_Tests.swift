//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChatSwiftUI
import XCTest

class TypingIndicatorView_Tests: XCTestCase {

    func test_typingIndicatorView_snapshot() {
        // Given
        let view = TypingIndicatorView()
            .frame(width: 20, height: 16)

        // Then
        assertSnapshot(matching: view, as: .image)
    }
}
