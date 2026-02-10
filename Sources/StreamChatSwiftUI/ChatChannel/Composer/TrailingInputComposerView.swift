//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

struct TrailingInputComposerView: View {
    @Binding var text: String
    @Binding var recordingState: RecordingState
    var sendMessageButtonState: MessageComposerInputState
    var startRecording: () -> Void
    var stopRecording: () -> Void
    var sendMessage: () -> Void
    
    var body: some View {
        switch sendMessageButtonState {
        case .creating(let hasContent):
            SendMessageButton(enabled: hasContent) {
                sendMessage()
            }
        case .editing(let hasContent):
            ConfirmEditButton(enabled: hasContent) {
                sendMessage()
            }
        case .allowAudioRecording:
            VoiceRecordingButton(
                recordingState: $recordingState,
                startRecording: startRecording,
                stopRecording: stopRecording
            )
        case .slowMode(let cooldownDuration):
            SlowModeView(cooldownDuration: cooldownDuration)
        }
    }
}
