//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class MessageReadIndicatorView_Tests: StreamChatTestCase {

    func test_messageReadIndicatorView_snapshotMessageSent() {
        // Given
        let view = MessageReadIndicatorView(
            readUsers: [],
            showReadCount: false
        )
        .frame(width: 50, height: 16)
     
        // Then
        assertSnapshot(matching: view, as: .image)
    }
    
    func test_messageReadIndicatorView_snapshotMessageReadDirect() {
        // Given
        let view = MessageReadIndicatorView(
            readUsers: [.mock(id: .unique)],
            showReadCount: false
        )
        .frame(width: 50, height: 16)
     
        // Then
        assertSnapshot(matching: view, as: .image)
    }
    
    func test_messageReadIndicatorView_snapshotMessageReadGroup() {
        // Given
        let view = MessageReadIndicatorView(
            readUsers: [.mock(id: .unique)],
            showReadCount: true
        )
        .frame(width: 50, height: 16)
     
        // Then
        assertSnapshot(matching: view, as: .image)
    }
}
