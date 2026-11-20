//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

/// The view model of the sheet for picking a custom time to send a scheduled message at.
@MainActor open class ScheduleMessageCustomTimeViewModel: ObservableObject {
    /// The picked date and time.
    @Published public var date: Date
    /// The earliest time the message can be scheduled for.
    @Published public private(set) var earliestDate: Date
    /// The latest time the message can be scheduled for. `nil` when the app has no maximum lead time.
    @Published public private(set) var latestDate: Date?

    @Published private var error: Error?
    @Published private var scheduling = false

    /// The channel the message is scheduled in.
    public let channel: ChatChannel
    /// How many scheduled messages the current user has, next to the limits of the app.
    public let usage: ScheduledMessagesUsage?

    private let onSchedule: @MainActor (Date, @escaping @MainActor (Error?) -> Void) -> Void

    /// Creates the view model.
    /// - Parameters:
    ///   - channel: The channel the message is scheduled in. Its config has the earliest and the latest time.
    ///   - usage: How many scheduled messages the current user has, next to the limits of the app.
    ///   - initialDate: The date picked first, for example the current date of a rescheduled message. A date that is too
    ///   soon is kept, so the sheet shows why it can't be confirmed. Tomorrow at 09:00 when `nil` or in the past, like the
    ///   date of a failed message.
    ///   - onSchedule: Schedules the message at the given date and completes with the error, if there is one.
    public init(
        channel: ChatChannel,
        usage: ScheduledMessagesUsage?,
        initialDate: Date? = nil,
        onSchedule: @escaping @MainActor (Date, @escaping @MainActor (Error?) -> Void) -> Void
    ) {
        self.channel = channel
        self.usage = usage
        self.onSchedule = onSchedule
        let dateLimits = Self.dateLimits(for: channel.config)
        earliestDate = dateLimits.earliest
        latestDate = dateLimits.latest
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date()))
        let tomorrowMorning = tomorrow.flatMap { calendar.date(bySettingHour: 9, minute: 0, second: 0, of: $0) }
        if let initialDate, initialDate > Date() {
            date = min(initialDate, dateLimits.latest ?? .distantFuture)
        } else {
            date = min(max(tomorrowMorning ?? dateLimits.earliest, dateLimits.earliest), dateLimits.latest ?? .distantFuture)
        }
    }

    /// The dates that can be picked.
    ///
    /// It starts at the picked date when that became too soon. The picker would show the earliest time otherwise,
    /// next to the error about the picked date.
    public var dateRange: ClosedRange<Date> {
        min(earliestDate, date)...max(earliestDate, latestDate ?? .distantFuture)
    }

    /// The error to show: the picked time is too soon or too far ahead, or the message couldn't be scheduled.
    public var errorText: String? {
        if pickedDate < earliestDate {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.day, .hour, .minute]
            formatter.unitsStyle = .full
            return L10n.Composer.ScheduleMessage.Error.tooSoon(formatter.string(from: minLeadTime) ?? "")
        }
        if let latestDate, pickedDate > latestDate {
            return L10n.Composer.ScheduleMessage.Error.tooFar
        }
        return error.map { ScheduleMessageErrorText.text(for: $0, config: channel.config) }
    }

    /// A Boolean value indicating whether the message can be scheduled at the picked time.
    public var canConfirm: Bool {
        !scheduling
            && pickedDate >= earliestDate
            && pickedDate <= latestDate ?? .distantFuture
            && error.map(ScheduleMessageErrorText.canRetry) != false
    }

    /// Moves the earliest and the latest time to the current time. Call it regularly while the sheet is open.
    open func updateDateLimits() {
        let dateLimits = Self.dateLimits(for: channel.config)
        // The limits change once a minute, the view doesn't need an update in between.
        if dateLimits.earliest != earliestDate {
            earliestDate = dateLimits.earliest
        }
        if dateLimits.latest != latestDate {
            latestDate = dateLimits.latest
        }
    }

    /// Schedules the message at the picked time, unless the time became too soon while the sheet was open.
    open func confirm() {
        updateDateLimits()
        guard canConfirm else { return }
        error = nil
        scheduling = true
        onSchedule(pickedDate) { [weak self] error in
            guard let self else { return }
            scheduling = false
            self.error = error
            if let errorText, error != nil {
                ComposerAccessibilityAnnouncer.announce(errorText)
            }
        }
    }

    // The picker keeps the seconds of the date it started with. The server keeps whole minutes only.
    private var pickedDate: Date {
        date.roundedToMinute(.down)
    }

    private var minLeadTime: TimeInterval {
        Self.minLeadTime(for: channel.config)
    }

    private static func minLeadTime(for config: ChannelConfig) -> TimeInterval {
        config.scheduledMessagesMinLeadTime ?? 60
    }

    private static func dateLimits(for config: ChannelConfig) -> (earliest: Date, latest: Date?) {
        let now = Date()
        return (
            now.addingTimeInterval(minLeadTime(for: config)).roundedToMinute(.up),
            config.scheduledMessagesMaxLeadTime.map { now.addingTimeInterval($0).roundedToMinute(.down) }
        )
    }
}

private extension Date {
    func roundedToMinute(_ rule: FloatingPointRoundingRule) -> Date {
        Date(timeIntervalSinceReferenceDate: (timeIntervalSinceReferenceDate / 60).rounded(rule) * 60)
    }
}
