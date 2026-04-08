//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// The button responsible to start voice recording.
public struct VoiceRecordingButton: View {
    @Injected(\.colors) var colors
    @Injected(\.tokens) var tokens
    @Injected(\.images) var images

    @Binding var recordingState: VoiceRecordingState
    var startRecording: () -> Void
    var stopRecording: () -> Void
    var showRecordingTip: () -> Void

    public var body: some View {
        Image(uiImage: images.composerMic)
            .renderingMode(.template)
            .padding(tokens.buttonPaddingYSm)
            .foregroundColor(Color(colors.buttonSecondaryText))
            .accessibilityRemoveTraits(.isImage)
            .accessibilityAddTraits(.isButton)
            .accessibilityLabel(Text(L10n.Composer.AudioRecording.start))
            .accessibilityAction {
                recordingState = .recording
                startRecording()
            }
    }
}
