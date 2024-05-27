//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import SwiftUI
import XCTest

final class CreatePollView_Tests: StreamChatTestCase {

    func test_createPollView_snapshot() {
        // Given
        let view = CreatePollView()
            .applyDefaultSize()
        
        // Then
        assertSnapshot(matching: view, as: .image)
    }
}
