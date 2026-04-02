//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public struct ComposerVoiceRecordingContainerView: View {
    @Injected(\.tokens) private var tokens
    @Injected(\.utils) private var utils

    @StateObject var voiceRecordingHandler = VoiceRecordingHandler()

    var addedVoiceRecordings: [AddedVoiceRecording]
    var onDiscardAttachment: (String) -> Void

    public init(addedVoiceRecordings: [AddedVoiceRecording], onDiscardAttachment: @escaping (String) -> Void) {
        self.addedVoiceRecordings = addedVoiceRecordings
        self.onDiscardAttachment = onDiscardAttachment
    }

    private var player: AudioPlaying {
        utils.audioPlayer
    }

    public var body: some View {
        VStack(spacing: tokens.spacingXxs) {
            ForEach(addedVoiceRecordings) { recording in
                ComposerVoiceRecordingAttachmentView(
                    handler: voiceRecordingHandler,
                    recording: recording,
                    onDiscardAttachment: onDiscardAttachment
                )
            }
        }
        .onAppear {
            player.subscribe(voiceRecordingHandler)
        }
    }
}

// MARK: - Single Voice Recording Attachment

struct ComposerVoiceRecordingAttachmentView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens
    @Injected(\.utils) private var utils

    @ObservedObject var handler: VoiceRecordingHandler

    let recording: AddedVoiceRecording
    var onDiscardAttachment: (String) -> Void

    private var isActive: Bool { handler.isActive(for: recording.url) }

    private var displayedPlaybackTime: TimeInterval {
        handler.displayedTime(for: recording.url, duration: recording.duration)
    }

    var body: some View {
        HStack(spacing: tokens.spacingXs) {
            playButton
            contentArea
            playbackSpeedToggle
        }
        .padding(.top, tokens.spacingMd)
        .padding(.leading, tokens.spacingSm)
        .padding(.bottom, tokens.spacingMd)
        .padding(.trailing, tokens.spacingSm)
        .frame(height: 72)
        .background(Color(colors.backgroundCoreElevation1))
        .cornerRadius(tokens.radiusLg)
        .overlay(
            RoundedRectangle(cornerRadius: tokens.radiusLg)
                .strokeBorder(Color(colors.borderCoreOpacitySubtle), lineWidth: 1)
        )
        .dismissButtonOverlayModifier {
            onDiscardAttachment(recording.url.absoluteString)
        }
        .onReceive(handler.$context) { _ in
            handler.updatePlaybackState(for: recording.url)
        }
    }

    // MARK: - Play Button

    private var playButton: some View {
        PlayPauseButton(isPlaying: handler.isPlaying && isActive) {
            handler.togglePlayback(for: recording.url)
        }
    }

    // MARK: - Content Area

    private var contentArea: some View {
        HStack(spacing: tokens.spacingXs) {
            Text(utils.videoDurationFormatter.format(displayedPlaybackTime) ?? "")
                .font(fonts.footnote.monospacedDigit())
                .foregroundColor(Color(colors.textSecondary))

            WaveformViewSwiftUI(
                audioContext: isActive ? handler.context : nil,
                addedVoiceRecording: recording,
                isPlaying: handler.isPlaying && isActive,
                onSliderChanged: { timeInterval in
                    handler.seek(to: timeInterval, loadingFrom: isActive ? nil : recording.url)
                },
                onSliderTapped: {
                    handler.togglePlayback(for: recording.url)
                }
            )
            .frame(height: 20)
        }
    }

    // MARK: - Speed Toggle

    private var playbackSpeedToggle: some View {
        PlaybackSpeedToggle(handler: handler)
    }
}
