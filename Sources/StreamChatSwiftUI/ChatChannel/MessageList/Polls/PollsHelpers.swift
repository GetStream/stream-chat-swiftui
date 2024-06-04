//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
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
    
    var dateFormatter: (Date) -> String {
        utils.pollsDateFormatter.dateString(for:)
    }
    
    let date: Date
    
    var body: some View {
        Text(dateFormatter(date))
            .font(fonts.subheadline)
            .foregroundColor(Color(colors.textLowEmphasis))
    }
}

class PollsDateFormatter {
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMM dd HH:mm")
        return formatter
    }()
    
    func dateString(for date: Date) -> String {
        // Check if the date is today
        if Calendar.current.isDateInToday(date) {
            return L10n.Dates.today
        } else {
            // If it's not today, format the date normally
            return dateFormatter.string(from: date)
        }
    }
}
