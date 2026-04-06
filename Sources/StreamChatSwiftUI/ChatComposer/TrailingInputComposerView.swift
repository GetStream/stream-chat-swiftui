//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

struct TrailingInputComposerView<Factory: ViewFactory>: View {
    let factory: Factory
    
    @Binding var text: String
    @Binding var recordingState: VoiceRecordingState
    @Binding var composerCommand: ComposerCommand?
    var composerInputState: MessageComposerInputState
    var startRecording: @MainActor () -> Void
    var stopRecording: @MainActor () -> Void
    var showRecordingTip: @MainActor () -> Void
    var sendMessage: @MainActor () -> Void

    var body: some View {
        switch composerInputState {
        case .creating(let hasContent, let hasCommand):
            if hasCommand {
                factory.makeConfirmEditButton(
                    options: ConfirmEditButtonOptions(
                        enabled: hasContent,
                        onTap: sendMessage
                    )
                )
            } else {
                factory.makeSendMessageButton(
                    options: SendMessageButtonOptions(
                        enabled: hasContent,
                        onTap: sendMessage
                    )
                )
            }
        case .editing(let hasContent):
            factory.makeConfirmEditButton(
                options: ConfirmEditButtonOptions(
                    enabled: hasContent,
                    onTap: sendMessage
                )
            )
        case .allowAudioRecording:
            VoiceRecordingButton(
                recordingState: $recordingState,
                startRecording: startRecording,
                stopRecording: stopRecording,
                showRecordingTip: showRecordingTip
            )
        case .slowMode(let cooldownDuration):
            SlowModeView(cooldownDuration: cooldownDuration)
        }
    }
}
