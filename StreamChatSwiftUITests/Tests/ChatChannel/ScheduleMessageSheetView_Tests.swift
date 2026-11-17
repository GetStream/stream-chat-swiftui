//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
import StreamChatCommonUI
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import XCTest

@MainActor final class ScheduleMessageSheetView_Tests: StreamChatTestCase {
    func test_scheduleMessageSheetView_snapshot() {
        // Given
        let size = CGSize(width: defaultScreenSize.width, height: 200)
        streamChat?.utils.scheduledMessageDateFormatter = DefaultScheduledMessageDateFormatter(locale: Locale(identifier: "en_US"))
        // The Monday action depends on the weekday, so only the actions for tomorrow are shown.
        let actions = ScheduleMessageAction.defaultActions(for: .init(channel: .mock(cid: .unique), onSchedule: { _ in })).prefix(2)

        // When
        let view = ScheduleMessageSheetView(actions: Array(actions), reachedLimit: nil, onDismiss: {})
            .frame(width: size.width, height: size.height)

        // Then
        AssertSnapshot(view, size: size)
    }
}
