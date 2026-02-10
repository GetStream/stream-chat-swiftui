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

struct TrailingInputComposerView<Factory: ViewFactory>: View {
    let factory: Factory

    @Binding var text: String
    @Binding var recordingState: RecordingState
    var sendMessageButtonState: SendMessageButtonState
    var startRecording: @MainActor @Sendable () -> Void
    var stopRecording: @MainActor @Sendable () -> Void
    var sendMessage: @MainActor @Sendable () -> Void
    
    var body: some View {
        switch sendMessageButtonState {
        case .regular(let isEnabled):
            factory.makeSendMessageButton(
                options: SendMessageButtonOptions(
                    enabled: isEnabled,
                    onTap: sendMessage
                )
            )
        case .edit(let isEnabled):
            factory.makeConfirmEditButton(
                options: ConfirmEditButtonOptions(
                    enabled: isEnabled,
                    onTap: sendMessage
                )
            )
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
