//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// A linear playback seek bar used by audio file attachments.
///
/// Unlike the voice-recording waveform, this control shows a track and thumb only.
struct PlaybackProgressBar: View {
    @Injected(\.colors) private var colors

    /// Total duration of the audio, in seconds.
    var duration: TimeInterval
    /// Elapsed playback time, in seconds.
    var currentTime: TimeInterval
    /// Whether playback is currently active. Drives the active thumb styling.
    var isPlaying: Bool
    /// Called continuously while the user drags the thumb.
    var onSeek: (TimeInterval) -> Void
    /// Called when the user lifts their finger after seeking.
    var onSeekEnded: () -> Void = {}

    @State private var isDragging = false
    @State private var dragProgress: CGFloat = 0

    private let thumbSize: CGFloat = 12
    private let trackHeight: CGFloat = 4

    private var progress: CGFloat {
        if isDragging { return dragProgress }
        guard duration > 0 else { return 0 }
        return CGFloat(min(max(currentTime / duration, 0), 1))
    }

    var body: some View {
        GeometryReader { proxy in
            let travel = max(proxy.size.width - thumbSize, 0)
            let thumbX = progress * travel

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(colors.borderCoreOpacityStrong))
                    .frame(height: trackHeight)

                Capsule()
                    .fill(Color(colors.accentPrimary))
                    .frame(width: thumbX + thumbSize / 2, height: trackHeight)

                Circle()
                    .fill(Color(thumbFillColor))
                    .overlay(
                        Circle()
                            .stroke(Color(thumbBorderColor), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.14), radius: 3, x: 0, y: 2)
                    .frame(width: thumbSize, height: thumbSize)
                    .offset(x: thumbX)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .contentShape(Rectangle())
            .gesture(dragGesture(travel: travel))
        }
        .frame(height: 20)
        .flipsForRightToLeftLayoutDirection(true)
        .accessibilityHidden(true)
    }

    private var thumbFillColor: UIColor {
        isPlaying || isDragging
            ? colors.controlPlaybackThumbBackgroundActive
            : colors.controlPlaybackThumbBackgroundDefault
    }

    private var thumbBorderColor: UIColor {
        isPlaying || isDragging
            ? colors.controlPlaybackThumbBorderActive
            : colors.controlPlaybackThumbBorderDefault
    }

    private func dragGesture(travel: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard duration > 0 else { return }
                isDragging = true
                let x = min(max(value.location.x - thumbSize / 2, 0), travel)
                dragProgress = travel > 0 ? x / travel : 0
                onSeek(TimeInterval(dragProgress) * duration)
            }
            .onEnded { _ in
                isDragging = false
                onSeekEnded()
            }
    }
}
