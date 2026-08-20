//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// A play/pause button with a bubble-aware border and a loading state, used by audio and voice attachments.
struct AudioPlaybackButton: View {
    @Injected(\.colors) private var colors

    var isPlaying: Bool
    var isLoading: Bool = false
    var isSentByCurrentUser: Bool = false
    var isEnabled: Bool = true
    var onTap: () -> Void

    var body: some View {
        PlayPauseButton(isPlaying: isPlaying, onTap: onTap)
            .overlay(
                Circle()
                    .stroke(borderColor, lineWidth: 1)
            )
            .opacity(isLoading ? 0 : 1)
            .overlay(isLoading ? ProgressView() : nil)
            .disabled(!isEnabled)
    }

    private var borderColor: Color {
        if isEnabled {
            return colors.chatControlBorder(isSentByCurrentUser: isSentByCurrentUser)
        }
        return Color(colors.borderUtilityDisabledOnSurface)
    }
}

extension Appearance.ColorPalette {
    /// The border color for controls rendered on top of a message bubble.
    func chatControlBorder(isSentByCurrentUser: Bool) -> Color {
        Color(isSentByCurrentUser ? chatBorderOnChatOutgoing : chatBorderOnChatIncoming)
    }
}
