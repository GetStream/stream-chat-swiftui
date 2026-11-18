//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

/// An action in the schedule message sheet.
public final class ScheduleMessageAction: Identifiable, Sendable {
    public var id: String {
        "\(title)-\(iconName)"
    }

    public let title: String
    public let iconName: String
    public let action: @MainActor () -> Void

    public init(
        title: String,
        iconName: String,
        action: @escaping @MainActor () -> Void
    ) {
        self.title = title
        self.iconName = iconName
        self.action = action
    }
}

extension ScheduleMessageAction {
    /// Returns the default actions of the schedule message sheet: tomorrow morning, tomorrow afternoon and Monday morning.
    ///
    /// The Monday action is left out when Monday is tomorrow.
    @MainActor public static func defaultActions(
        for options: SupportedScheduleMessageActionsOptions
    ) -> [ScheduleMessageAction] {
        let calendar = Calendar.current
        let formatter = InjectedValues[\.utils].scheduledMessagesConfig.dateFormatter
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date())) else { return [] }
        let tomorrowMorning = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: tomorrow)
        let tomorrowAfternoon = calendar.date(bySettingHour: 13, minute: 0, second: 0, of: tomorrow)
        // Searched from the start of tomorrow, so on a Monday it is the Monday of the next week.
        let mondayMorning = calendar.nextDate(
            after: tomorrow,
            matching: DateComponents(hour: 9, minute: 0, weekday: 2),
            matchingPolicy: .nextTime
        )
        let dates = [tomorrowMorning, tomorrowAfternoon, mondayMorning == tomorrowMorning ? nil : mondayMorning]
        return dates.compactMap { $0 }.map { date in
            ScheduleMessageAction(title: formatter.format(date), iconName: "clock") {
                options.onSchedule(date)
            }
        }
    }
}
