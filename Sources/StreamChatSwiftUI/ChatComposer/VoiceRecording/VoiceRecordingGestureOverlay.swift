//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Transparent overlay that handles voice recording gestures. Placed on MessageComposerView
/// so the drag can extend beyond the mic button bounds (e.g. drag up to lock).
struct VoiceRecordingGestureOverlay: View {
    @Binding var recordingState: RecordingState
    var startRecording: () -> Void
    var stopRecording: () -> Void
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
            .frame(maxWidth: .infinity, alignment: .trailing)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let translation = CGPoint(x: value.translation.width, y: value.translation.height)
                        triggerHapticFeedback(style: .medium)
                        if !longPressed {
                            longPressStarted = Date()
                            longPressed = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                if longPressed {
                                    recordingState = .recording(translation)
                                    startRecording()
                                }
                            }
                        } else if case .recording = recordingState {
                            recordingState = .recording(translation)
                        }
                    }
                    .onEnded { _ in
                        longPressed = false
                        if let longPressStarted, Date().timeIntervalSince(longPressStarted) <= 1 {
                            showRecordingTip()
                            self.longPressStarted = nil
                            return
                        }
                        if case .recording = recordingState {
                            withAnimation(.interactiveSpring(response: 0.35, dampingFraction: 0.88)) {
                                recordingState = .locked
                            }
                        } else if recordingState != .locked {
                            stopRecording()
                        }
                    }
            )
    }
}
