//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Voice recording input shown inside the composer when the user is
/// actively recording or has locked/stopped a recording.
struct ComposerVoiceRecordingInputView<Factory: ViewFactory>: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens
    @Injected(\.utils) private var utils

    let factory: Factory
    var recordingState: VoiceRecordingState
    var audioRecordingInfo: AudioRecordingInfo
    var pendingAudioRecordingURL: URL?
    var gestureLocation: CGPoint
    var stopRecording: @MainActor () -> Void
    var confirmRecording: @MainActor () -> Void
    var discardRecording: @MainActor () -> Void
    var previewRecording: @MainActor () -> Void

    @StateObject private var handler = VoiceRecordingHandler()

    private var player: AudioPlaying { utils.audioPlayer }

    private var isLockedOrStopped: Bool {
        recordingState.isLockedOrStopped
    }

    private var isStopped: Bool {
        recordingState == .stopped
    }

    var body: some View {
        VStack(spacing: tokens.spacingNone) {
            recordingBar
                .animation(.composerVoiceRecordingSpring, value: isLockedOrStopped)

            recordingControls
                .frame(height: isLockedOrStopped ? recordingControlsHeight : 0, alignment: .top)
                .clipped()
                .animation(
                    .composerVoiceRecordingSpring.delay(isLockedOrStopped ? controlsRevealDelay : 0),
                    value: isLockedOrStopped
                )
        }
        .onAppear { player.subscribe(handler) }
        .onReceive(handler.$context) { _ in
            if let url = pendingAudioRecordingURL {
                handler.updatePlaybackState(for: url)
            }
        }
    }

    // MARK: - Recording Bar

    private var recordingBar: some View {
        HStack(spacing: tokens.spacingNone) {
            HStack(spacing: tokens.spacingNone) {
                if !isStopped {
                    micIndicator
                }

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
            .foregroundColor(Color(colors.accentError))
            .frame(width: 48, height: 48)
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private var durationOrPlayback: some View {
        if isStopped {
            HStack(spacing: 0) {
                Button {
                    if let url = pendingAudioRecordingURL {
                        handler.togglePlayback(for: url)
                    }
                } label: {
                    Image(systemName: handler.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color(colors.textPrimary))
                        .transaction { $0.animation = nil }
                }
                .buttonStyle(.plain)
                .frame(width: 48, height: 48)
                .accessibilityLabel(Text(handler.isPlaying
                        ? L10n.Composer.AudioRecording.stop
                        : L10n.Composer.AudioRecording.start))

                VoiceRecordingDurationView(
                    duration: previewRecordingDurationLabel,
                    usesAccentColor: handler.isPlaying
                )
            }
        } else {
            VoiceRecordingDurationView(duration: audioRecordingInfo.duration)
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
                stopRecording()
            } label: {
                Image(systemName: "mic")
                    .font(.system(size: 20))
                    .foregroundColor(Color(colors.textPrimary))
                    .frame(width: 32, height: 32)
                    .background(Color(colors.backgroundUtilityPressed))
                    .clipShape(Circle())
            }
            .frame(width: 48, height: 48)
            .accessibilityLabel(Text(L10n.Composer.AudioRecording.stop))
        }
    }

    private var lockedRecordingTrailing: some View {
        RecordingWaveform(
            isRecording: !isStopped,
            isPlaying: handler.isPlaying,
            duration: lockedPreviewWaveformDuration,
            currentTime: lockedPreviewWaveformCurrentTime,
            waveform: audioRecordingInfo.waveform,
            onSliderChanged: { timeInterval in
                guard let url = pendingAudioRecordingURL else { return }
                handler.seek(to: timeInterval, loadingFrom: handler.isActive(for: url) ? nil : url)
            }
        )
        .frame(height: 20)
        .padding(.horizontal, tokens.spacingMd)
    }

    private var lockedPreviewWaveformCurrentTime: TimeInterval {
        if !isStopped {
            return audioRecordingInfo.duration
        }
        guard let url = pendingAudioRecordingURL, handler.isActive(for: url) else {
            return 0
        }
        return min(max(handler.context.currentTime, 0), lockedPreviewWaveformDuration)
    }

    private var lockedPreviewWaveformDuration: TimeInterval {
        let fromMetering = max(audioRecordingInfo.duration, 0.001)
        guard isStopped, let url = pendingAudioRecordingURL, handler.isActive(for: url) else {
            return fromMetering
        }
        let fromPlayer = handler.context.duration
        return max(fromMetering, fromPlayer, 0.001)
    }

    // MARK: - Recording Controls

    private let recordingControlsHeight: CGFloat = 48
    private let controlsRevealDelay: TimeInterval = 0.12

    private var recordingControls: some View {
        HStack {
            trashControlButton

            Spacer()

            stopControlButton
                .opacity(recordingState == .locked ? 1 : 0)

            Spacer()

            factory.makeConfirmEditButton(
                options: ConfirmEditButtonOptions(
                    enabled: true,
                    onTap: {
                        withAnimation(.composerVoiceRecordingSpring) {
                            confirmRecording()
                        }
                    }
                )
            )
            .frame(width: 48, height: 48)
            .contentShape(Rectangle())
        }
    }

    private var trashControlButton: some View {
        StreamIconButton(role: .secondary, style: .outline, size: .small) {
            withAnimation(.composerVoiceRecordingSpring) {
                discardRecording()
            }
        } icon: {
            Image(systemName: "trash")
                .font(.system(size: 16))
        }
        .frame(width: 48, height: 48)
        .contentShape(Rectangle())
        .accessibilityLabel(Text(L10n.Composer.Recording.voiceMessageDeleted))
    }

    private var stopControlButton: some View {
        StreamIconButton(role: .destructive, style: .outline, size: .medium) {
            withAnimation(.composerVoiceRecordingSpring) {
                previewRecording()
            }
        } icon: {
            Image(systemName: "stop.fill")
                .customizable()
                .frame(width: 12, height: 12)
        }
        .frame(width: 48, height: 48)
        .contentShape(Rectangle())
        .accessibilityLabel(Text(L10n.Composer.AudioRecording.stop))
    }

    // MARK: - Helpers

    private var opacityForSlideToCancel: CGFloat {
        guard gestureLocation.x < VoiceRecordingConstants.cancelMinDistance else { return 1 }
        return 1 - gestureLocation.x / VoiceRecordingConstants.cancelMaxDistance
    }

    private var previewRecordingDurationLabel: TimeInterval {
        guard isStopped, let url = pendingAudioRecordingURL else {
            return audioRecordingInfo.duration
        }
        return handler.displayedTime(for: url, duration: audioRecordingInfo.duration)
    }
}

// MARK: - Slide to Cancel Label

/// Interactive slide-to-cancel label with shimmering highlight.
struct SlideToCancelLabel: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts

    @Environment(\.layoutDirection) private var layoutDirection

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
            Image(systemName: "chevron.backward")
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

    /// The visible offset for the label as it follows the drag.
    ///
    /// `location.x` is normalized by `VoiceRecordingGestureOverlay` so that
    /// negative values always represent dragging toward the cancel direction.
    /// To translate that back to actual screen coordinates we flip the sign
    /// in RTL — the user drags rightward there, so the label must move
    /// rightward (positive X) too.
    private var slideOffset: CGFloat {
        let towardCancel = min(0, location.x)
        return layoutDirection == .rightToLeft ? -towardCancel : towardCancel
    }
}
