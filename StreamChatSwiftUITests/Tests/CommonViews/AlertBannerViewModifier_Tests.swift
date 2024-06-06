//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import SwiftUI
import XCTest

final class AlertBannerViewModifier_Tests: StreamChatTestCase {
    func test_alertBanner_snapshot() {
        // When
        let view = EmptyView()
            .alertBanner(isPresented: .constant(true), duration: .infinity)
            .frame(width: defaultScreenSize.width)
        
        // Then
        assertSnapshot(matching: view, as: .image)
    }
}
