//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import SwiftUI

struct TrailingInputComposerView: View {
    @Binding var text: String
    @Binding var recordingState: RecordingState
    var sendButtonEnabled: Bool
    var startRecording: () -> Void
    var stopRecording: () -> Void
    var sendMessage: () -> Void
    
    var body: some View {
        if !sendButtonEnabled {
            VoiceRecordingButton(
                recordingState: $recordingState,
                startRecording: startRecording,
                stopRecording: stopRecording
            )
        } else {
            SendMessageButton(enabled: sendButtonEnabled) {
                sendMessage()
            }
        }
    }
}
