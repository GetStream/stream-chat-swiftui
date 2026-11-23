//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Combine
import Foundation
import StreamChat

/// The view model of the sheet for picking a custom time to send a scheduled message at.
@MainActor open class ScheduleMessageCustomTimeViewModel: ObservableObject {
    /// The picked date and time.
    ///
    /// A picked time at or before the earliest time moves to a minute after it. The date picker picks the earliest time
    /// when today is tapped after the time it shows has passed.
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
    private var cancellables = Set<AnyCancellable>()

    /// Creates the view model.
    /// - Parameters:
    ///   - channel: The channel the message is scheduled in. Its config has the earliest and the latest time.
    ///   - usage: How many scheduled messages the current user has, next to the limits of the app.
    ///   - onSchedule: Schedules the message at the given date and completes with the error, if there is one.
    public init(
        channel: ChatChannel,
        usage: ScheduledMessagesUsage?,
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
        date = min(max(tomorrowMorning ?? dateLimits.earliest, dateLimits.earliest), dateLimits.latest ?? .distantFuture)
        $date
            .dropFirst()
            // The date picker keeps showing the time of the tapped day. A date set after it handled the tap redraws it.
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self, pickedDate <= earliestDate else { return }
                date = earliestDate.addingTimeInterval(60)
            }
            .store(in: &cancellables)
    }

    /// The dates that can be picked.
    public var dateRange: ClosedRange<Date> {
        earliestDate...max(earliestDate, latestDate ?? .distantFuture)
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
        !scheduling && dateRange.contains(pickedDate) && error.map(ScheduleMessageErrorText.canRetry) != false
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
