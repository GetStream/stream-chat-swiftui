//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// A play/pause toggle button used in voice recording views.
public struct PlayPauseButton: View {
    @Injected(\.tokens) private var tokens

    var isPlaying: Bool
    var onTap: () -> Void

    public init(isPlaying: Bool, onTap: @escaping () -> Void) {
        self.isPlaying = isPlaying
        self.onTap = onTap
    }

    public var body: some View {
        StreamIconButton(role: .secondary, style: .outline, size: .medium, showsPressedState: false, action: onTap) {
            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                .font(.system(size: tokens.iconSizeMd))
                .frame(width: tokens.iconSizeMd, height: tokens.iconSizeMd)
                .transaction { $0.animation = nil }
        }
        .accessibilityLabel(Text(isPlaying ? "Pause" : "Play"))
    }
}
