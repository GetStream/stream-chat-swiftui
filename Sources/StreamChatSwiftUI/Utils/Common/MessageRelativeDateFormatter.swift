//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation

/// A formatter that converts message timestamps to a format which depends on the time passed.
public final class MessageRelativeDateFormatter: DateFormatter, @unchecked Sendable {
    override public init() {
        super.init()
        locale = .autoupdatingCurrent
        dateStyle = .short
        timeStyle = .none
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func string(from date: Date) -> String {
        if calendar.isDateInToday(date) {
            return todayFormatter.string(from: date)
        }
        if calendar.isDateInYesterday(date) {
            return yesterdayFormatter.string(from: date)
        }
        if calendar.isDateInLastWeek(date) {
            return weekdayFormatter.string(from: date)
        }

        return super.string(from: date)
    }

    var todayFormatter: DateFormatter {
        InjectedValues[\.utils].dateFormatter
    }
    
    let yesterdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()

    let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.setLocalizedDateFormatFromTemplate("EEEE")
        return formatter
    }()
}

extension Calendar {
    func isDateInLastWeek(_ date: Date) -> Bool {
        guard let dateBefore7days = self.date(byAdding: .day, value: -7, to: Date()) else {
            return false
        }
        return date > dateBefore7days
    }
}
