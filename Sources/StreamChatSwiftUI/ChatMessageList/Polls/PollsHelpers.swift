//
// Copyright © 2026 Stream.io Inc. All rights reserved.
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
