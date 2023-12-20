//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public struct TrailingComposerView: View {
    
    @Injected(\.utils) private var utils
        
    @EnvironmentObject var viewModel: MessageComposerViewModel
    var onTap: () -> Void
    
    public init(onTap: @escaping () -> Void) {
        self.onTap = onTap
    }
    
    public var body: some View {
        Group {
            if viewModel.cooldownDuration == 0 {
                HStack(spacing: 16) {
                    SendMessageButton(
                        enabled: viewModel.sendButtonEnabled,
                        onTap: onTap
                    )
                    if utils.composerConfig.isVoiceRecordingEnabled {
                        VoiceRecordingButton(viewModel: viewModel)
                    }
                }
                .padding(.bottom, 8)
            } else {
                SlowModeView(
                    cooldownDuration: viewModel.cooldownDuration
                )
            }
        }
    }
}

struct VoiceRecordingButton: View {
    @Injected(\.colors) var colors
    @Injected(\.utils) var utils
    
    @ObservedObject var viewModel: MessageComposerViewModel
    
    @State private var longPressed = false
    @State private var longPressStarted: Date?

    var body: some View {
        Image(systemName: "mic")
            .foregroundColor(Color(colors.textLowEmphasis))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if !longPressed {
                            longPressStarted = Date()
                            longPressed = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                if longPressed {
                                    viewModel.recordingState = .recording(value.location)
                                    viewModel.startRecording()
                                }
                            }
                        } else if case .recording = viewModel.recordingState {
                            viewModel.recordingState = .recording(value.location)
                        }
                    }
                    .onEnded { _ in
                        longPressed = false
                        if let longPressStarted, Date().timeIntervalSince(longPressStarted) <= 1 {
                            if viewModel.recordingState != .showingTip {
                                viewModel.recordingState = .showingTip
                            }
                            self.longPressStarted = nil
                            return
                        }
                        if viewModel.recordingState != .locked {
                            viewModel.stopRecording()
                        }
                    }
            )
    }
}
