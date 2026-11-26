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

    func test_scheduleMessageCustomTimeSheetView_whenTheTimeIsTooSoon_snapshot() {
        let view = makeView(usage: usage, preview: textPreview, error: ClientError.ScheduledMessageIsTooSoon(minLeadTime: 60))

        AssertSnapshot(view, size: size)
    }

    func test_scheduleMessageCustomTimeSheetView_whenTheUserLimitIsReached_snapshot() {
        let view = makeView(
            usage: usage,
            preview: textPreview,
            config: .mock(scheduledMessagesMaxPerUser: 100),
            error: ClientError.ScheduledMessagesUserLimitReached(limit: 100)
        )

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

    // The date picker picks the earliest time when today is tapped after the time it shows has passed.
    func test_viewModel_whenTheEarliestTimeIsPicked_movesTheTimeToAMinuteAfterIt() {
        let viewModel = makeViewModel()
        let dateMoved = expectation(description: "date moved")
        let cancellable = viewModel.$date
            .first { $0 == viewModel.earliestDate.addingTimeInterval(60) }
            .sink { _ in dateMoved.fulfill() }

        viewModel.date = viewModel.earliestDate

        wait(for: [dateMoved], timeout: defaultTimeout)
        XCTAssertNil(viewModel.errorText)
        XCTAssertTrue(viewModel.canConfirm)
        cancellable.cancel()
    }

    func test_viewModel_whenTheDateChanges_checksTheNewTime() {
        var checkedDates: [Date] = []
        let newTimeChecked = expectation(description: "new time checked")
        let viewModel = makeViewModel(validate: { date, completion in
            checkedDates.append(date)
            if checkedDates.count == 2 {
                newTimeChecked.fulfill()
            }
            completion(nil)
        })
        let date = Date().addingTimeInterval(7200).roundedToMinute(.down)

        viewModel.date = date

        wait(for: [newTimeChecked], timeout: defaultTimeout)
        XCTAssertEqual(checkedDates.last, date)
    }

    func test_viewModel_confirm_whenTheSDKAcceptsTheTime_schedulesAtThePickedMinute() {
        var scheduledDate: Date?
        let viewModel = makeViewModel(onSchedule: { scheduledDate = $0 })
        let date = viewModel.date

        viewModel.confirm()

        XCTAssertEqual(scheduledDate, date.roundedToMinute(.down))
    }

    func test_viewModel_confirm_whenTheSDKRefusesTheTime_showsTheErrorWithoutScheduling() {
        var error: Error?
        var scheduledDate: Date?
        let viewModel = makeViewModel(validate: { _, completion in completion(error) }, onSchedule: { scheduledDate = $0 })
        XCTAssertTrue(viewModel.canConfirm)

        error = ClientError.ScheduledMessageIsTooFarAhead(maxLeadTime: 3600)
        viewModel.confirm()

        XCTAssertNil(scheduledDate)
        XCTAssertFalse(viewModel.canConfirm)
        XCTAssertEqual(viewModel.errorText, "That's further ahead than your app allows")
    }

    // MARK: - Reschedule

    func test_scheduleMessageCustomTimeSheetView_whenRescheduling_snapshot() {
        let preview = ScheduleMessagePreview(title: "Scheduled for Tue, Jan 15 at 09:00", subtitle: "Heads up: the launch moved to Monday.")

        let view = makeView(usage: nil, preview: preview, scheduledMessage: .mock(status: .scheduled))

        AssertSnapshot(view, size: size)
    }

    func test_viewModel_whenReschedulingToATimeThatIsTooSoon_keepsItAndShowsTheEditError() {
        let soon = Date().addingTimeInterval(30)

        let viewModel = makeViewModel(scheduledMessage: .mock(scheduledAt: soon), validate: { _, completion in
            completion(ClientError.ScheduledMessageIsTooSoon(minLeadTime: 60))
        })

        XCTAssertEqual(viewModel.date, soon)
        XCTAssertTrue(viewModel.dateRange.contains(soon))
        XCTAssertEqual(viewModel.errorText, "Pick a later time. Editing can't send a message right away.")
        XCTAssertFalse(viewModel.canConfirm)
    }

    func test_viewModel_whenReschedulingAMessageWhoseTimePassed_picksTheDefaultDate() {
        let viewModel = makeViewModel(scheduledMessage: .mock(scheduledAt: Date().addingTimeInterval(-3600)))

        XCTAssertGreaterThan(viewModel.date, Date())
        XCTAssertNil(viewModel.errorText)
    }

    func test_viewModel_whenRescheduling_picksTheDateOfTheMessage() {
        let scheduledAt = Date().addingTimeInterval(3 * 24 * 3600)

        let viewModel = makeViewModel(scheduledMessage: .mock(scheduledAt: scheduledAt))

        XCTAssertEqual(viewModel.date, scheduledAt)
        XCTAssertNil(viewModel.errorText)
        XCTAssertTrue(viewModel.canConfirm)
    }

    // MARK: - private

    private func makeViewModel(
        scheduledMessage: ScheduledMessage? = nil,
        validate: @escaping @MainActor (Date, @escaping @MainActor (Error?) -> Void) -> Void = { _, completion in completion(nil) },
        onSchedule: @escaping @MainActor (Date) -> Void = { _ in }
    ) -> ScheduleMessageCustomTimeViewModel {
        ScheduleMessageCustomTimeViewModel(
            channel: .mock(cid: .unique),
            usage: usage,
            scheduledMessage: scheduledMessage,
            validate: validate,
            onSchedule: onSchedule
        )
    }

    private func makeView(
        usage: ScheduledMessagesUsage?,
        preview: ScheduleMessagePreview,
        scheduledMessage: ScheduledMessage? = nil,
        config: ChannelConfig = .mock(),
        error: Error? = nil
    ) -> some View {
        // The mocked config has no max lead time. A date in a far month keeps today out of the calendar.
        let channel = ChatChannel.mock(cid: .unique, config: config)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 2 * 3600)!
        let options = ScheduleMessageCustomTimeSheetOptions(
            channel: channel,
            usage: usage,
            preview: preview,
            scheduledMessage: scheduledMessage,
            validate: { _, completion in completion(error) },
            onSchedule: { _ in },
            onDismiss: {}
        )
        let viewModel = ScheduleMessageCustomTimeViewModel(
            channel: channel,
            usage: usage,
            validate: options.validate,
            onSchedule: options.onSchedule
        )
        viewModel.date = calendar.date(from: DateComponents(year: 2030, month: 1, day: 15, hour: 9))!
        return ScheduleMessageCustomTimeSheetView(factory: DefaultViewFactory.shared, options: options, viewModel: viewModel)
            .environment(\.calendar, calendar)
            .environment(\.locale, Locale(identifier: "en_US"))
            .environment(\.timeZone, calendar.timeZone)
            .frame(width: size.width, height: size.height)
    }
}
