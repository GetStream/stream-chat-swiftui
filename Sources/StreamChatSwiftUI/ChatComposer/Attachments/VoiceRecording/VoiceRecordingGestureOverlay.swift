//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Transparent overlay that handles voice recording gestures. Placed on MessageComposerView
/// so the drag can extend beyond the mic button bounds (e.g. drag up to lock).
struct VoiceRecordingGestureOverlay: View {
    @Binding var recordingState: VoiceRecordingState
    @Binding var gestureLocation: CGPoint
    var startRecording: () -> Void
    var stopRecording: () -> Void
    /// Stops an in-progress hold-to-record when the finger lifts without locking (send flow).
    var releaseRecording: () -> Void
    var discardRecording: () -> Void
    var showRecordingTip: () -> Void

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
                        let translation = CGPoint(x: value.translation.width, y: value.translation.height)
                        if !longPressed {
                            longPressStarted = Date()
                            longPressed = true
                            triggerHapticFeedback(style: .medium)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                if longPressed {
                                    recordingState = .recording
                                    gestureLocation = translation
                                    startRecording()
                                }
                            }
                        } else if recordingState.isRecording {
                            gestureLocation = translation
                        }
                    }
                    .onEnded { _ in
                        longPressed = false
                        if let longPressStarted, Date().timeIntervalSince(longPressStarted) <= 1 {
                            showRecordingTip()
                            self.longPressStarted = nil
                            return
                        }
                        if recordingState.isRecording {
                            if gestureLocation.x < VoiceRecordingConstants.cancelMinDistance {
                                discardRecording()
                            } else {
                                releaseRecording()
                            }
                            gestureLocation = .zero
                        } else if recordingState != .locked {
                            stopRecording()
                        }
                    }
            )
    }
}
