//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChatSwiftUI
import SwiftUI
import XCTest

@MainActor final class RadioCheckView_Tests: StreamChatTestCase {
    func test_radioCheck_unselected() {
        let size = CGSize(width: 60, height: 40)
        let view = RadioCheckView(isSelected: false)
            .frame(width: size.width, height: size.height)
        AssertSnapshot(view, size: size)
    }

    func test_radioCheck_selected() {
        let size = CGSize(width: 60, height: 40)
        let view = RadioCheckView(isSelected: true)
            .frame(width: size.width, height: size.height)
        AssertSnapshot(view, size: size)
    }
}
