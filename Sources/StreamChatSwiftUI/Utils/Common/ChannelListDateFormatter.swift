//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import Foundation

/// A formatter that converts last message timestamps in the channel list.
///
/// Shows time, relative date, weekday or short date based on days passed.
public final class ChannelListDateFormatter: DateFormatter, @unchecked Sendable {
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
            return time.string(from: date)
        }
        if calendar.isDateInYesterday(date) {
            return shortRelativeDate.string(from: date)
        }
        if calendar.isDateInLastWeek(date) {
            return weekday.string(from: date)
        }

        return super.string(from: date)
    }
    
    override public var locale: Locale! {
        didSet {
            [time, shortRelativeDate, weekday].forEach { $0.locale = locale }
        }
    }
    
    let time: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    let shortRelativeDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()

    let weekday: DateFormatter = {
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
