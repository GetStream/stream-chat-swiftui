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
        let size = CGSize(width: defaultScreenSize.width, height: 250)
        streamChat?.utils.scheduledMessagesConfig.dateFormatter = DefaultScheduledMessageDateFormatter(locale: Locale(identifier: "en_US"))
        // The Monday action depends on the weekday, so only the actions for tomorrow and the custom time are shown.
        let allActions = ScheduleMessageAction.defaultActions(for: .init(channel: .mock(cid: .unique), onSchedule: { _ in }, onCustomTime: {}))
        let actions = allActions.prefix(2) + allActions.suffix(1)

        // When
        let view = ScheduleMessageSheetView(actions: Array(actions), reachedLimit: nil, onDismiss: {})
            .frame(width: size.width, height: size.height)

        // Then
        AssertSnapshot(view, size: size)
    }

    func test_scheduleMessageSheetView_whenTheLimitIsReached_snapshot() {
        // Given
        let size = CGSize(width: defaultScreenSize.width, height: 250)
        streamChat?.utils.scheduledMessagesConfig.dateFormatter = DefaultScheduledMessageDateFormatter(locale: Locale(identifier: "en_US"))
        let allActions = ScheduleMessageAction.defaultActions(for: .init(channel: .mock(cid: .unique), onSchedule: { _ in }, onCustomTime: {}))
        let actions = allActions.prefix(2) + allActions.suffix(1)

        // When
        let view = ScheduleMessageSheetView(actions: Array(actions), reachedLimit: 10, onDismiss: {})
            .frame(width: size.width, height: size.height)

        // Then
        AssertSnapshot(view, size: size)
    }

    func test_defaultActions_leaveOutTimesBeyondTheMaxLeadTime() {
        let channel = ChatChannel.mock(cid: .unique, config: .mock(scheduledMessagesMaxLeadTime: 3600))
        let actions = ScheduleMessageAction.defaultActions(for: .init(channel: channel, onSchedule: { _ in }, onCustomTime: {}))
        XCTAssertEqual(actions.map(\.title), [L10n.Composer.ScheduleMessage.customTime])
    }
}
