//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public struct TrailingComposerView: View {
        
    @EnvironmentObject var viewModel: MessageComposerViewModel
    var onTap: () -> ()
    
    public init(onTap: @escaping () -> ()) {
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
                    VoiceRecordingButton(viewModel: viewModel)
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
    
    @ObservedObject var viewModel: MessageComposerViewModel
    
    @State private var longPressed = false

    var body: some View {
        Image(systemName: "mic")
            .foregroundColor(Color(colors.textLowEmphasis))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if !longPressed {
                            longPressed = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                                if longPressed {
                                    viewModel.recordingState = .recording(value.location)
                                    viewModel.startRecording()
                                } else {
                                    //TODO: show a message
                                    viewModel.recordingState = .initial
                                }
                            })
                        } else {
                            viewModel.recordingState = .recording(value.location)
                        }
                    }
                    .onEnded { _ in
                        longPressed = false
                        if viewModel.recordingState != .locked {
                            viewModel.stopRecording()
                        }
                    }
            )
    }
}
