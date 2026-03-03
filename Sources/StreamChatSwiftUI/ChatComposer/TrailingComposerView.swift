//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatCommonUI
import SwiftUI

public struct TrailingComposerView<Factory: ViewFactory>: View {
    @Injected(\.utils) private var utils

    var factory: Factory
    @ObservedObject var viewModel: MessageComposerViewModel
    var onTap: @MainActor @Sendable () -> Void
    
    public init(
        factory: Factory,
        viewModel: MessageComposerViewModel,
        onTap: @escaping @MainActor @Sendable () -> Void
    ) {
        self.factory = factory
        self.onTap = onTap
        self.viewModel = viewModel
    }
    
    public var body: some View {
        Group {
            if viewModel.cooldownDuration == 0 && viewModel.canSendMessage {
                HStack(spacing: 16) {
                    factory.makeSendMessageButton(
                        options: SendMessageButtonOptions(
                            enabled: viewModel.hasContent,
                            onTap: onTap
                        )
                    )
                    if utils.composerConfig.isVoiceRecordingEnabled {
                        VoiceRecordingButton(
                            recordingState: $viewModel.recordingState,
                            startRecording: viewModel.startRecording,
                            stopRecording: viewModel.stopRecording,
                            showRecordingTip: viewModel.showRecordingTip
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
    @Injected(\.tokens) var tokens
    @Injected(\.images) var images

    @Binding var recordingState: RecordingState
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
                recordingState = .recording(.zero)
                startRecording()
            }
    }
}
