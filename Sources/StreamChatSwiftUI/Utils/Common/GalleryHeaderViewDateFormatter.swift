//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation

/// A formatter used to display the message timestamp in the gallery header view.
public final class GalleryHeaderViewDateFormatter: DateFormatter, @unchecked Sendable {
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
            return dayFormatter.string(from: date)
        }

        if calendar.isDateInYesterday(date) {
            return dayFormatter.string(from: date)
        }

        return super.string(from: date)
    }
    
    let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
}
