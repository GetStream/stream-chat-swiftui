//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
import StreamChatCommonUI
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

@MainActor final class ScheduleMessageCustomTimeSheetView_Tests: StreamChatTestCase {
    private let size = CGSize(width: defaultScreenSize.width, height: 880)
    private let usage = ScheduledMessagesUsage(channelCount: 2, channelLimit: 10, userCount: 2, userLimit: 100)
    private let textPreview = ScheduleMessagePreview(
        title: "Message to Maya Ross",
        subtitle: "Heads up: the launch moved to Monday."
    )

    override func setUp() {
        super.setUp()
        streamChat?.utils.scheduledMessagesConfig.dateFormatter = DefaultScheduledMessageDateFormatter(locale: Locale(identifier: "en_US"))
    }

    func test_scheduleMessageCustomTimeSheetView_snapshot() {
        let view = makeView(usage: usage, preview: textPreview)

        AssertSnapshot(view, size: size)
    }

    func test_scheduleMessageCustomTimeSheetView_whenThereIsNoChannelLimit_snapshot() {
        let view = makeView(usage: nil, preview: textPreview)

        AssertSnapshot(view, size: size)
    }

    func test_scheduleMessageCustomTimeSheetView_whenTheMessageHasACommand_snapshot() {
        let preview = ScheduleMessagePreview(title: "Message to SDK Design", subtitle: "/giphy launch day")

        let view = makeView(usage: usage, preview: preview, error: ClientError.ScheduledMessageHasACommand())

        AssertSnapshot(view, size: size)
    }

    func test_scheduleMessageCustomTimeSheetView_whenSchedulingFails_snapshot() {
        let view = makeView(usage: usage, preview: textPreview, error: ClientError.Unknown())

        AssertSnapshot(view, size: size)
    }

    func test_scheduleMessageCustomTimeSheetView_whenTheMessageHasAnAttachment_snapshot() {
        let preview = ScheduleMessagePreview(
            title: "Message to Maya Ross",
            subtitle: "Venue options for the offsite",
            icon: .photo,
            thumbnail: .image(url: .localYodaImage)
        )

        let view = makeView(usage: usage, preview: preview)

        AssertSnapshot(view, size: size)
    }

    func test_scheduleMessageCustomTimeSheetView_whenTheMessageHasAQuote_snapshot() {
        let preview = ScheduleMessagePreview(title: "Reply to Alex Ross", subtitle: "@Maya Ross, can you check the final plan?")

        let view = makeView(usage: usage, preview: preview)

        AssertSnapshot(view, size: size)
    }

    // The shown month would have today in it, so this state has no snapshot.
    func test_viewModel_whenThePickedTimeIsNow_showsTheTooSoonErrorAndDisablesConfirm() {
        let viewModel = ScheduleMessageCustomTimeViewModel(channel: .mock(cid: .unique), usage: usage) { _, _ in }

        viewModel.date = Date()

        XCTAssertEqual(viewModel.errorText, "Pick a time at least 1 minute from now")
        XCTAssertFalse(viewModel.canConfirm)
    }

    // MARK: - private

    private func makeView(
        usage: ScheduledMessagesUsage?,
        preview: ScheduleMessagePreview,
        error: Error? = nil
    ) -> some View {
        // The mocked config has no max lead time. A date in a far month keeps today out of the calendar.
        let channel = ChatChannel.mock(cid: .unique)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 2 * 3600)!
        let options = ScheduleMessageCustomTimeSheetOptions(
            channel: channel,
            usage: usage,
            preview: preview,
            onSchedule: { _, completion in completion(error) },
            onDismiss: {}
        )
        let viewModel = ScheduleMessageCustomTimeViewModel(channel: channel, usage: usage, onSchedule: options.onSchedule)
        viewModel.date = calendar.date(from: DateComponents(year: 2030, month: 1, day: 15, hour: 9))!
        if error != nil {
            viewModel.confirm()
        }
        return ScheduleMessageCustomTimeSheetView(factory: DefaultViewFactory.shared, options: options, viewModel: viewModel)
            .environment(\.calendar, calendar)
            .environment(\.locale, Locale(identifier: "en_US"))
            .environment(\.timeZone, calendar.timeZone)
            .frame(width: size.width, height: size.height)
    }
}
