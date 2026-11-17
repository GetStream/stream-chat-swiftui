//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

@MainActor final class NotificationView_Tests: StreamChatTestCase {
    func test_notificationView_snapshot() {
        // Given
        let size = CGSize(width: defaultScreenSize.width, height: 340)

        // When
        let view = VStack(spacing: 16) {
            NotificationView(style: .info, title: "Sent in your time zone (GMT+2)")
            NotificationView(
                style: .info,
                title: "2 of 10 scheduled in this channel",
                description: "Sent in your time zone (GMT+2)"
            )
            NotificationView(style: .error, title: "Commands can't be scheduled. Remove the / command to continue.")
        }
        .padding(.horizontal, 16)
        .frame(width: size.width, height: size.height)

        // Then
        AssertSnapshot(view, size: size)
    }
}
