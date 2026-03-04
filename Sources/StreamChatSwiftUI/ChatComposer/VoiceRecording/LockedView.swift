//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Locked recording view shown after the user drags up to lock the recording.
///
/// Layout matches the Figma "Voice Message – Recording (Locked)" spec:
/// - Recording Container (rounded card, radius 3xl, border)
///   - Recording Bar: red mic indicator | duration | live waveform
///   - Recording Controls: delete | stop | confirm
///
/// The floating lock indicator is managed externally (by the composer overlay)
/// so it can transition seamlessly from the `LockView` capsule.
struct LockedView: View {
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    @Injected(\.tokens) var tokens
    @Injected(\.utils) var utils

    @ObservedObject var viewModel: MessageComposerViewModel
    @State private var isPlaying = false
    @StateObject var voiceRecordingHandler = VoiceRecordingHandler()

    private var player: AudioPlaying {
        utils.audioPlayer
    }

    var body: some View {
        recordingContainer
            .onAppear {
                player.subscribe(voiceRecordingHandler)
            }
            .onReceive(voiceRecordingHandler.$context) { value in
                if value.state == .stopped || value.state == .paused {
                    isPlaying = false
                } else if value.state == .playing {
                    isPlaying = true
                }
            }
    }

    // MARK: - Recording Container

    private var recordingContainer: some View {
        VStack(spacing: tokens.spacingNone) {
            recordingBar
            recordingControls
        }
        .background(Color(colors.backgroundElevationElevation1))
        .clipShape(RoundedRectangle(cornerRadius: tokens.radius3xl))
        .overlay(
            RoundedRectangle(cornerRadius: tokens.radius3xl)
                .stroke(Color(colors.borderCoreDefault), lineWidth: 1)
        )
    }

    // MARK: - Recording Bar

    private var recordingBar: some View {
        HStack(spacing: tokens.spacingMd) {
            HStack(spacing: tokens.spacingNone) {
                micIndicator
                durationOrPlayback
            }

            RecordingWaveform(
                duration: viewModel.audioRecordingInfo.duration,
                currentTime: viewModel.recordingState == .stopped
                    ? voiceRecordingHandler.context.currentTime
                    : viewModel.audioRecordingInfo.duration,
                waveform: viewModel.audioRecordingInfo.waveform
            )
            .frame(height: 20)
        }
        .padding(.trailing, tokens.spacingMd)
        .frame(height: 48)
    }

    private var micIndicator: some View {
        Image(systemName: "mic.fill")
            .font(.system(size: 20))
            .foregroundColor(.red)
            .frame(width: 48, height: 48)
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private var durationOrPlayback: some View {
        if viewModel.recordingState == .stopped {
            HStack(spacing: tokens.spacingXs) {
                Button {
                    handlePlayTap()
                } label: {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color(colors.textPrimary))
                }
                .accessibilityLabel(Text(isPlaying
                        ? L10n.Composer.AudioRecording.stop
                        : L10n.Composer.AudioRecording.start))

                RecordingDurationView(
                    duration: showContextTime
                        ? voiceRecordingHandler.context.currentTime
                        : viewModel.audioRecordingInfo.duration
                )
            }
        } else {
            RecordingDurationView(duration: viewModel.audioRecordingInfo.duration)
        }
    }

    // MARK: - Recording Controls

    private static var recordingControlAnimation: Animation {
        .interactiveSpring(response: 0.35, dampingFraction: 0.88)
    }

    private var recordingControls: some View {
        HStack {
            recordingControlButton(role: .secondary, icon: "trash") {
                viewModel.discardRecording()
            }

            Spacer()

            if viewModel.recordingState == .locked {
                recordingControlButton(role: .destructive, icon: "stop.fill") {
                    viewModel.previewRecording()
                }
                Spacer()
            }

            recordingControlButton(role: .primary, style: .solid, icon: "checkmark") {
                viewModel.confirmRecording()
            }
        }
    }

    private func recordingControlButton(
        role: StreamButtonRole,
        style: StreamButtonVisualStyle = .outline,
        icon: String,
        action: @escaping () -> Void
    ) -> some View {
        StreamIconButton(role: role, style: style, size: .small) {
            withAnimation(Self.recordingControlAnimation) { action() }
        } icon: {
            Image(systemName: icon)
                .font(.system(size: 20))
        }
        .frame(width: 48, height: 48)
        .contentShape(Rectangle())
    }

    // MARK: - Helpers

    private var showContextTime: Bool {
        voiceRecordingHandler.context.currentTime > 0
    }

    private func handlePlayTap() {
        if isPlaying {
            player.pause()
        } else if let url = viewModel.pendingAudioRecording?.url {
            player.loadAsset(from: url)
        }
        isPlaying.toggle()
    }
}
