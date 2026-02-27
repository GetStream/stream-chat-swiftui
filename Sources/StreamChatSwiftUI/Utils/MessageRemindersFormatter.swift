//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation

/// A formatter that converts a reminder date into a human-readable relative time string.
public protocol MessageRemindersFormatter {
    /// Returns a relative time string for the given reminder date (e.g. "in 1 hour"),
    /// or `nil` if the date is in the past.
    func format(_ remindAt: Date) -> String?
}

/// The default message reminders formatter.
public final class DefaultMessageRemindersFormatter: MessageRemindersFormatter {
    public var dateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()

    public init() {}

    public func format(_ remindAt: Date) -> String? {
        let now = Date()
        guard remindAt.timeIntervalSince(now) > 0 else { return nil }
        return dateFormatter.localizedString(for: remindAt, relativeTo: now)
    }
}
