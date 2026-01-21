//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public struct TrailingComposerView: View {
    @Injected(\.utils) private var utils
        
    @ObservedObject var viewModel: MessageComposerViewModel
    var onTap: () -> Void
    
    public init(
        viewModel: MessageComposerViewModel,
        onTap: @escaping () -> Void
    ) {
        self.onTap = onTap
        self.viewModel = viewModel
    }
    
    public var body: some View {
        Group {
            if viewModel.cooldownDuration == 0 && viewModel.isSendMessageEnabled {
                HStack(spacing: 16) {
                    SendMessageButton(
                        enabled: viewModel.sendButtonEnabled,
                        onTap: onTap
                    )
                    if utils.composerConfig.isVoiceRecordingEnabled {
                        VoiceRecordingButton(
                            recordingState: $viewModel.recordingState,
                            startRecording: viewModel.startRecording,
                            stopRecording: viewModel.stopRecording
                        )
                    }
                }
                .padding(.bottom, 8)
            } else if viewModel.cooldownDuration > 0 {
                SlowModeView(
                    cooldownDuration: viewModel.cooldownDuration
                )
            }
        }
    }
}

/// The button responsible to start voice recording.
public struct VoiceRecordingButton: View {
    @Injected(\.colors) var colors
    @Injected(\.utils) var utils
        
    @State private var longPressed = false
    @State private var longPressStarted: Date?
    
    @Binding var recordingState: RecordingState
    var startRecording: () -> Void
    var stopRecording: () -> Void

    public var body: some View {
        Image(systemName: "mic")
            .frame(width: 32, height: 32)
            .foregroundColor(Color(colors.textLowEmphasis))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if !longPressed {
                            longPressStarted = Date()
                            longPressed = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                if longPressed {
                                    recordingState = .recording(value.location)
                                    startRecording()
                                }
                            }
                        } else if case .recording = recordingState {
                            recordingState = .recording(value.location)
                        }
                    }
                    .onEnded { _ in
                        longPressed = false
                        if let longPressStarted, Date().timeIntervalSince(longPressStarted) <= 1 {
                            if recordingState != .showingTip {
                                recordingState = .showingTip
                            }
                            self.longPressStarted = nil
                            return
                        }
                        if recordingState != .locked {
                            stopRecording()
                        }
                    }
            )
            .accessibilityRemoveTraits(.isImage)
            .accessibilityAddTraits(.isButton)
            .accessibilityLabel(Text(L10n.Composer.AudioRecording.start))
            .accessibilityAction {
                recordingState = .recording(.zero)
                startRecording()
            }
    }
}
