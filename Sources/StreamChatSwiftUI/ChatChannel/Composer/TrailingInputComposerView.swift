//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

public enum SendMessageButtonState {
    case regular(Bool)
    case edit(Bool)
    case audio
    case slowMode(Int)
}

struct TrailingInputComposerView: View {
    @Binding var text: String
    @Binding var recordingState: RecordingState
    var sendMessageButtonState: SendMessageButtonState
    var startRecording: () -> Void
    var stopRecording: () -> Void
    var sendMessage: () -> Void
    
    var body: some View {
        switch sendMessageButtonState {
        case .regular(let isEnabled):
            SendMessageButton(enabled: isEnabled) {
                sendMessage()
            }
        case .edit(let isEnabled):
            ConfirmEditButton(enabled: isEnabled) {
                sendMessage()
            }
        case .audio:
            VoiceRecordingButton(
                recordingState: $recordingState,
                startRecording: startRecording,
                stopRecording: stopRecording
            )
        case .slowMode(let cooldown):
            SlowModeView(cooldownDuration: cooldown)
        }
    }
}
