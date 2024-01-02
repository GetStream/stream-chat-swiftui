//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Foundation

public enum DateUtils {
    /// timeAgo formats a date into a string like "15 minutes ago"
    public static func timeAgo(relativeTo date: Date) -> String? {
        let now = Date()
        let calendar = Calendar.current

        if now < date {
            return nil
        }

        guard
            let minuteAgo = calendar.date(byAdding: .minute, value: -1, to: now),
            let hourAgo = calendar.date(byAdding: .hour, value: -1, to: now),
            let dayAgo = calendar.date(byAdding: .day, value: -1, to: now),
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now),
            let monthAgo = calendar.date(byAdding: .day, value: -31, to: now)
        else { return nil }

        if minuteAgo < date {
            return secondsAgo(from: date, to: now, calendar: calendar)
        }

        if hourAgo < date {
            return minutesAgo(from: date, to: now, calendar: calendar)
        }

        if dayAgo < date {
            return hoursAgo(from: date, to: now, calendar: calendar)
        }

        if weekAgo < date {
            return daysAgo(from: date, to: now, calendar: calendar)
        }

        if monthAgo < date {
            return weeksAgo(from: date, to: now, calendar: calendar)
        }

        let diff = calendar.dateComponents([.month], from: date, to: now).month ?? 0
        return diff > 1 ? L10n.Dates.timeAgoMonthsPlural(diff) : L10n.Dates.timeAgoMonthsSingular
    }

    // MARK: - private

    private static func secondsAgo(from date: Date, to now: Date, calendar: Calendar) -> String? {
        let diff = calendar.dateComponents([.second], from: date, to: now).second ?? 0
        return diff > 1 ? L10n.Dates.timeAgoSecondsPlural(diff) : L10n.Dates.timeAgoSecondsSingular
    }

    private static func minutesAgo(from date: Date, to now: Date, calendar: Calendar) -> String? {
        let diff = calendar.dateComponents([.minute], from: date, to: now).minute ?? 0
        return diff > 1 ? L10n.Dates.timeAgoMinutesPlural(diff) : L10n.Dates.timeAgoMinutesSingular
    }

    private static func hoursAgo(from date: Date, to now: Date, calendar: Calendar) -> String? {
        let diff = calendar.dateComponents([.hour], from: date, to: now).hour ?? 0
        return diff > 1 ? L10n.Dates.timeAgoHoursPlural(diff) : L10n.Dates.timeAgoHoursSingular
    }

    private static func daysAgo(from date: Date, to now: Date, calendar: Calendar) -> String? {
        let diff = calendar.dateComponents([.day], from: date, to: now).day ?? 0
        return diff > 1 ? L10n.Dates.timeAgoDaysPlural(diff) : L10n.Dates.timeAgoDaysSingular
    }

    private static func weeksAgo(from date: Date, to now: Date, calendar: Calendar) -> String? {
        let diff = calendar.dateComponents([.weekOfYear], from: date, to: now).weekOfYear ?? 0
        return diff > 1 ? L10n.Dates.timeAgoWeeksPlural(diff) : L10n.Dates.timeAgoWeeksSingular
    }
}
