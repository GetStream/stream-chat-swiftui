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
    @Published public var date: Date {
        didSet {
            // The date picker keeps showing the time of the tapped day. A date set after it handled the tap redraws it.
            DispatchQueue.main.async { [weak self] in
                self?.didPickDate()
            }
        }
    }

    @Published private(set) var earliestDate: Date
    @Published private(set) var latestDate: Date?

    @Published private var validationError: Error?

    /// The channel the message is scheduled in.
    public let channel: ChatChannel
    /// How many scheduled messages the current user has, next to the limits of the app.
    public let usage: ScheduledMessagesUsage?

    private let isRescheduling: Bool
    private let validate: @MainActor (Date, @escaping @MainActor (Error?) -> Void) -> Void
    private let onSchedule: @MainActor (Date) -> Void

    /// Creates the view model.
    /// - Parameters:
    ///   - channel: The channel the message is scheduled in. Its config has the earliest and the latest time.
    ///   - usage: How many scheduled messages the current user has, next to the limits of the app.
    ///   - scheduledMessage: The scheduled message that is rescheduled, `nil` for a new message. Its date is picked first. A
    ///   date that is too soon is kept, so the sheet shows why it can't be confirmed. Tomorrow at 09:00 is picked first for a
    ///   new message or a date in the past, like the date of a failed message.
    ///   - validate: Checks the message at the given date with the checks the SDK runs on the device before saving it,
    ///   for example with `ChatChannelController.validateForScheduling`, and completes with the error, if there is one.
    ///   - onSchedule: Schedules the message at the given date and closes the sheet, without waiting for the server.
    public init(
        channel: ChatChannel,
        usage: ScheduledMessagesUsage?,
        scheduledMessage: ScheduledMessage? = nil,
        validate: @escaping @MainActor (Date, @escaping @MainActor (Error?) -> Void) -> Void,
        onSchedule: @escaping @MainActor (Date) -> Void
    ) {
        self.channel = channel
        self.usage = usage
        isRescheduling = scheduledMessage != nil
        self.validate = validate
        self.onSchedule = onSchedule
        let dateLimits = Self.dateLimits(for: channel.config)
        earliestDate = dateLimits.earliest
        latestDate = dateLimits.latest
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date()))
        let tomorrowMorning = tomorrow.flatMap { calendar.date(bySettingHour: 9, minute: 0, second: 0, of: $0) }
        if let initialDate = scheduledMessage?.scheduledAt, initialDate > Date() {
            date = min(initialDate, dateLimits.latest ?? .distantFuture)
        } else {
            date = min(max(tomorrowMorning ?? dateLimits.earliest, dateLimits.earliest), dateLimits.latest ?? .distantFuture)
        }
        validatePickedDate()
    }

    /// The dates that can be picked.
    ///
    /// It starts at the picked date when that became too soon. The picker would show the earliest time otherwise,
    /// next to the error about the picked date.
    public var dateRange: ClosedRange<Date> {
        min(earliestDate, date)...max(earliestDate, latestDate ?? .distantFuture)
    }

    /// The error to show, for example that the picked time is too soon or too far ahead. The SDK checks the message at
    /// the picked time on the device, like before saving it.
    public var errorText: String? {
        validationError.map { ScheduleMessageErrorText.text(for: $0, config: channel.config, editing: isRescheduling) }
    }

    /// A Boolean value indicating whether the message can be scheduled at the picked time.
    public var canConfirm: Bool {
        validationError == nil
    }

    private func didPickDate() {
        updateDateLimits()
        guard pickedDate > earliestDate else {
            date = earliestDate.addingTimeInterval(60)
            return
        }
        validatePickedDate()
    }

    // Moves the earliest and the latest time to the current time.
    private func updateDateLimits() {
        let dateLimits = Self.dateLimits(for: channel.config)
        // The limits change once a minute, the view doesn't need an update in between.
        guard dateLimits.earliest != earliestDate || dateLimits.latest != latestDate else { return }
        earliestDate = dateLimits.earliest
        latestDate = dateLimits.latest
    }

    /// Schedules the message at the picked time, unless the SDK refuses it, for example when the time became too soon
    /// while the sheet was open. It doesn't wait for the server.
    open func confirm() {
        updateDateLimits()
        let date = pickedDate
        validatePickedDate { [weak self] error in
            guard let self else { return }
            if error == nil {
                onSchedule(date)
            } else if let errorText {
                ComposerAccessibilityAnnouncer.announce(errorText)
            }
        }
    }

    private func validatePickedDate(completion: (@MainActor (Error?) -> Void)? = nil) {
        let date = pickedDate
        validate(date) { [weak self] error in
            // A check of a time picked before is out of date.
            guard let self, date == pickedDate else { return }
            validationError = error
            completion?(error)
        }
    }

    // The picker keeps the seconds of the date it started with. The server keeps whole minutes only.
    private var pickedDate: Date {
        date.roundedToMinute(.down)
    }

    private static func dateLimits(for config: ChannelConfig) -> (earliest: Date, latest: Date?) {
        let now = Date()
        return (
            now.addingTimeInterval(config.scheduledMessagesMinLeadTime ?? 60).roundedToMinute(.up),
            config.scheduledMessagesMaxLeadTime.map { now.addingTimeInterval($0).roundedToMinute(.down) }
        )
    }
}

extension Date {
    func roundedToMinute(_ rule: FloatingPointRoundingRule) -> Date {
        Date(timeIntervalSinceReferenceDate: (timeIntervalSinceReferenceDate / 60).rounded(rule) * 60)
    }
}
