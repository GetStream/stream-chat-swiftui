//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// A play/pause toggle button used in voice recording views.
public struct PlayPauseButton: View {
    var isPlaying: Bool
    var onTap: () -> Void

    public init(isPlaying: Bool, onTap: @escaping () -> Void) {
        self.isPlaying = isPlaying
        self.onTap = onTap
    }

    public var body: some View {
        StreamIconButton(role: .secondary, style: .outline, size: .medium, showsPressedState: false, action: onTap) {
            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                .font(.system(size: 20))
                .transaction { $0.animation = nil }
        }
        .accessibilityLabel(Text(isPlaying ? "Pause" : "Play"))
    }
}
