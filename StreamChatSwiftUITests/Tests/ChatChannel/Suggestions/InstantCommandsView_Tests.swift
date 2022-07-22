//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

@testable import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class InstantCommandsView_Tests: StreamChatTestCase {

    func test_instantCommandsView_snapshot() {
        // Given
        let commandDisplayInfo = CommandDisplayInfo(
            displayName: "Test command",
            icon: UIImage(systemName: "person")!,
            format: "test command",
            isInstant: false
        )
        
        // When
        let view = InstantCommandView(displayInfo: commandDisplayInfo)
            .frame(width: defaultScreenSize.width, height: 100)
        
        // Then
        assertSnapshot(matching: view, as: .image)
    }
}
