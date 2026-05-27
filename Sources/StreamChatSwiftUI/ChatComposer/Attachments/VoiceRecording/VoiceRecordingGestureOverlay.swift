//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Transparent overlay that handles voice recording gestures. Placed on MessageComposerView
/// so the drag can extend beyond the mic button bounds (e.g. drag up to lock).
struct VoiceRecordingGestureOverlay: View {
    @Environment(\.layoutDirection) private var layoutDirection

    @Binding var recordingState: VoiceRecordingState
    @Binding var gestureLocation: CGPoint

    /// The long press was held long enough to begin recording.
    var onRecordingStarted: () -> Void
    /// The gesture ended outside the active recording flow.
    var onGestureCompleted: () -> Void
    /// The finger was lifted during an active recording (hold-and-release).
    var onRecordingReleased: () -> Void
    /// The drag exceeded the cancel threshold while recording.
    var onRecordingCancelled: () -> Void
    /// The tap was too brief to trigger recording.
    var onShortTapDetected: () -> Void

    @State private var longPressed = false
    @State private var longPressStarted: Date?

    var body: some View {
        Color.clear
            .contentShape(Rectangle())
            .frame(
                width: recordingState.isRecording ? nil : 48,
                height: 48
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let translation = normalizedTranslation(for: value.translation)
                        if !longPressed {
                            longPressStarted = Date()
                            longPressed = true
                            triggerHapticFeedback(style: .medium)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                if longPressed {
                                    recordingState = .recording
                                    gestureLocation = translation
                                    onRecordingStarted()
                                }
                            }
                        } else if recordingState.isRecording {
                            gestureLocation = translation
                        }
                    }
                    .onEnded { _ in
                        longPressed = false
                        if let longPressStarted, Date().timeIntervalSince(longPressStarted) <= 1 {
                            onShortTapDetected()
                            self.longPressStarted = nil
                            return
                        }
                        if recordingState.isRecording {
                            if gestureLocation.x < VoiceRecordingConstants.cancelMinDistance {
                                withAnimation(.composerVoiceRecordingSpring) {
                                    onRecordingCancelled()
                                }
                            } else {
                                withAnimation(.composerVoiceRecordingSpring) {
                                    onRecordingReleased()
                                }
                            }
                            gestureLocation = .zero
                        } else if recordingState != .locked {
                            onGestureCompleted()
                        }
                    }
            )
    }

    /// Returns the drag translation normalized so that the X axis always points
    /// away from the mic button toward the cancel direction (negative X).
    ///
    /// In LTR the mic button is on the trailing/right side and the user drags
    /// left to cancel — so we use the raw translation as-is. In RTL the mic
    /// button is on the left side and the user drags right to cancel — we flip
    /// the X so that downstream cancel/slide logic can operate in a single
    /// coordinate system regardless of layout direction.
    private func normalizedTranslation(for translation: CGSize) -> CGPoint {
        let normalizedX = layoutDirection == .rightToLeft ? -translation.width : translation.width
        return CGPoint(x: normalizedX, y: translation.height)
    }
}
