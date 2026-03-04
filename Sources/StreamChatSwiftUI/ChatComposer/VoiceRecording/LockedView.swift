//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Unified voice recording input shown inside the composer when the user is
/// actively recording or has locked/stopped a recording.
///
/// Handles both states with seamless animations:
/// - **Recording**: mic indicator, duration, slide-to-cancel, mic button
/// - **Locked / Stopped**: mic indicator, duration (or playback), waveform, controls
///
/// The red mic icon and duration label stay in the same position across both
/// states so the transition feels continuous.
struct ComposerVoiceRecordingInputView<Factory: ViewFactory>: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens
    @Injected(\.utils) private var utils

    let factory: Factory
    @ObservedObject var viewModel: MessageComposerViewModel
    var gestureLocation: CGPoint

    @State private var isPlaying = false
    @StateObject private var voiceRecordingHandler = VoiceRecordingHandler()

    private var player: AudioPlaying {
        utils.audioPlayer
    }

    private var isLockedOrStopped: Bool {
        viewModel.recordingState.isLockedOrStopped
    }

    private var isStopped: Bool {
        viewModel.recordingState == .stopped
    }

    var body: some View {
        VStack(spacing: tokens.spacingNone) {
            recordingBar

            recordingControls
                .frame(height: isLockedOrStopped ? recordingControlsHeight : 0, alignment: .top)
                .clipped()
                .animation(
                    .interactiveSpring(response: 0.35, dampingFraction: 0.88)
                        .delay(isLockedOrStopped ? controlsRevealDelay : 0),
                    value: isLockedOrStopped
                )
        }
        .animation(
            .interactiveSpring(response: 0.35, dampingFraction: 0.88),
            value: isLockedOrStopped
        )
        .onAppear { player.subscribe(voiceRecordingHandler) }
        .onReceive(voiceRecordingHandler.$context) { value in
            if value.state == .stopped || value.state == .paused {
                isPlaying = false
            } else if value.state == .playing {
                isPlaying = true
            }
        }
    }

    // MARK: - Recording Bar

    private var recordingBar: some View {
        HStack(spacing: tokens.spacingNone) {
            HStack(spacing: tokens.spacingNone) {
                micIndicator
                durationOrPlayback
            }

            ZStack {
                activeRecordingTrailing
                    .opacity(isLockedOrStopped ? 0 : 1)

                lockedRecordingTrailing
                    .opacity(isLockedOrStopped ? 1 : 0)
            }
        }
        .frame(height: 48)
    }

    private var micIndicator: some View {
        Image(systemName: "mic")
            .font(.system(size: 20))
            .foregroundColor(.red)
            .frame(width: 48, height: 48)
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private var durationOrPlayback: some View {
        if isStopped {
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

    // MARK: - Trailing Content (Recording vs Locked)

    private var activeRecordingTrailing: some View {
        HStack(spacing: tokens.spacingNone) {
            Spacer()

            SlideToCancelLabel(location: gestureLocation)
                .opacity(opacityForSlideToCancel)
                .animation(.easeInOut(duration: 0.2), value: gestureLocation.x)
                .accessibilityHidden(true)

            Spacer()

            Button {
                viewModel.stopRecording()
            } label: {
                Image(systemName: "mic")
                    .font(.system(size: 20))
                    .foregroundColor(Color(colors.textPrimary))
                    .frame(width: 32, height: 32)
                    .background(Color(colors.backgroundCorePressed))
                    .clipShape(Circle())
            }
            .frame(width: 48, height: 48)
            .accessibilityLabel(Text(L10n.Composer.AudioRecording.stop))
        }
    }

    private var lockedRecordingTrailing: some View {
        RecordingWaveform(
            duration: viewModel.audioRecordingInfo.duration,
            currentTime: isStopped
                ? voiceRecordingHandler.context.currentTime
                : viewModel.audioRecordingInfo.duration,
            waveform: viewModel.audioRecordingInfo.waveform
        )
        .frame(height: 20)
        .padding(.horizontal, tokens.spacingMd)
    }

    // MARK: - Recording Controls

    /// Matches the 48pt frame set on each `recordingControlButton`.
    private let recordingControlsHeight: CGFloat = 48
    private let controlsRevealDelay: TimeInterval = 0.12

    private static var recordingControlAnimation: Animation {
        .interactiveSpring(response: 0.35, dampingFraction: 0.88)
    }

    private var recordingControls: some View {
        HStack {
            recordingControlButton(role: .secondary, icon: "trash") {
                viewModel.discardRecording()
            }

            Spacer()

            recordingControlButton(role: .destructive, icon: "stop.fill") {
                viewModel.previewRecording()
            }
            .opacity(viewModel.recordingState == .locked ? 1 : 0)

            Spacer()

            factory.makeConfirmEditButton(
                options: ConfirmEditButtonOptions(
                    enabled: true,
                    onTap: {
                        withAnimation(Self.recordingControlAnimation) {
                            viewModel.confirmRecording()
                        }
                    }
                )
            )
            .frame(width: 48, height: 48)
            .contentShape(Rectangle())
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

    private var opacityForSlideToCancel: CGFloat {
        guard gestureLocation.x < RecordingConstants.cancelMinDistance else { return 1 }
        return 1 - gestureLocation.x / RecordingConstants.cancelMaxDistance
    }

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

// MARK: - Slide to Cancel Label

/// Interactive slide-to-cancel label with shimmering highlight.
struct SlideToCancelLabel: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts

    let location: CGPoint

    var body: some View {
        HStack(spacing: 4) {
            Text(L10n.Composer.Recording.slideToCancel)
                .font(fonts.body)
                .foregroundColor(.clear)
                .overlay(
                    LinearGradient(
                        colors: [
                            Color(colors.textPrimary),
                            Color(colors.textTertiary)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .mask(
                        Text(L10n.Composer.Recording.slideToCancel)
                            .font(fonts.body)
                    )
                )
            Image(systemName: "chevron.left")
                .font(.system(size: 20))
                .foregroundColor(Color(colors.textTertiary))
        }
        .shimmering(
            duration: 2.0,
            delay: 0.3,
            direction: .trailingToLeading,
            intensity: .subtle
        )
        .offset(x: slideOffset)
        .animation(.interactiveSpring(response: 0.35, dampingFraction: 0.8), value: location.x)
    }

    private var slideOffset: CGFloat {
        min(0, location.x)
    }
}
