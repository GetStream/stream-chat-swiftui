//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatCommonUI
import SwiftUI

private struct PollsBackgroundModifier: ViewModifier {
    @Injected(\.colors) var colors
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(colors.background1))
            .cornerRadius(16)
    }
}

extension View {
    func withPollsBackground() -> some View {
        modifier(PollsBackgroundModifier())
    }
}

struct PollDateIndicatorView: View {
    @Injected(\.fonts) var fonts
    @Injected(\.utils) var utils
    @Injected(\.colors) var colors
    
    let date: Date
    
    var body: some View {
        Text(text)
            .font(fonts.subheadline)
            .foregroundColor(Color(colors.textLowEmphasis))
    }
    
    var text: String {
        let formatter = utils.pollsDateFormatter
        let voteDay = formatter.formatDay(date)
        let voteTime = formatter.formatTime(date)
        return [voteDay, voteTime].joined(separator: " ")
    }
}

// MARK: - TODO Move to common module

/// Timestamp formatter for poll results that uses relative date formatting.
///
/// Rules:
/// - Same day: "Today"
/// - 1 day ago: "Yesterday"
/// - 2–6 days ago: "Nd ago"
/// - 1–3 weeks ago: "Nw ago"
/// - 4+ weeks: DD/MM/YY
class PollResultsTimestampFormatter: DefaultPollTimestampFormatter {
    override func formatDay(_ date: Date) -> String {
        let cal = Calendar.current

        if cal.isDateInToday(date) || cal.isDateInYesterday(date) {
            return relativeDateFormatter.string(from: date)
        }

        let days = cal.dateComponents(
            [.day],
            from: cal.startOfDay(for: date),
            to: cal.startOfDay(for: Date())
        ).day ?? 0

        if days >= 2 && days <= 6 {
            return L10n.Message.Polls.Date.daysAgo(days)
        }

        if days >= 7 {
            let weeks = days / 7
            if weeks <= 3 {
                return L10n.Message.Polls.Date.weeksAgo(weeks)
            }
        }

        return dayFormatter.string(from: date)
    }
}
