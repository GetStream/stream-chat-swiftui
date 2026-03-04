//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public struct AddedVoiceRecordingsView: View {
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
            ForEach(0..<addedVoiceRecordings.count, id: \.self) { i in
                let recording = addedVoiceRecordings[i]
                ComposerVoiceRecordingCard(
                    handler: voiceRecordingHandler,
                    recording: recording,
                    index: i,
                    onDiscard: onDiscardAttachment
                )
            }
        }
        .onAppear {
            player.subscribe(voiceRecordingHandler)
        }
    }
}

// MARK: - Composer Voice Recording Card

struct ComposerVoiceRecordingCard: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens
    @Injected(\.utils) private var utils

    @ObservedObject var handler: VoiceRecordingHandler

    let recording: AddedVoiceRecording
    let index: Int
    var onDiscard: (String) -> Void

    private var isActive: Bool { handler.isActive(for: recording.url) }
    private var showContextDuration: Bool { isActive && handler.context.currentTime > 0 }

    var body: some View {
        HStack(spacing: tokens.spacingXs) {
            playButton
            contentArea
            playbackSpeedToggle
        }
        .padding(tokens.spacingSm)
        .frame(height: 72)
        .background(Color(colors.backgroundElevationElevation1))
        .clipShape(RoundedRectangle(cornerRadius: tokens.radiusLg))
        .overlay(
            RoundedRectangle(cornerRadius: tokens.radiusLg)
                .stroke(Color(colors.borderCoreDefault), lineWidth: 1)
        )
        .overlay(
            DiscardAttachmentButton(
                attachmentIdentifier: recording.url.absoluteString,
                onDiscard: onDiscard
            )
        )
        .onReceive(handler.$context) { _ in
            handler.updatePlaybackState(for: recording.url)
        }
    }

    // MARK: - Play Button

    private var playButton: some View {
        StreamIconButton(role: .secondary, style: .outline, size: .medium) {
            handler.togglePlayback(for: recording.url)
        } icon: {
            Image(systemName: handler.isPlaying && isActive ? "pause.fill" : "play.fill")
                .font(.system(size: 20))
        }
    }

    // MARK: - Content Area

    private var contentArea: some View {
        VStack(alignment: .leading, spacing: tokens.spacingXxs) {
            Text(
                utils.audioRecordingNameFormatter.title(
                    forItemAtURL: recording.url,
                    index: index
                )
            )
            .font(fonts.footnote.weight(.semibold))
            .foregroundColor(Color(colors.textPrimary))
            .lineLimit(1)
            .truncationMode(.tail)

            HStack(spacing: tokens.spacingXs) {
                Text(utils.videoDurationFormatter.format(showContextDuration ? handler.context.currentTime : recording.duration) ?? "")
                    .font(fonts.footnote.monospacedDigit())
                    .foregroundColor(Color(colors.textSecondary))

                WaveformViewSwiftUI(
                    audioContext: isActive ? handler.context : nil,
                    addedVoiceRecording: recording,
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
    }

    // MARK: - Speed Toggle

    private var playbackSpeedToggle: some View {
        Button {
            handler.cycleRate()
        } label: {
            Text(handler.rateTitle)
                .font(fonts.footnote)
                .foregroundColor(Color(colors.textPrimary))
                .frame(width: 40, height: 24)
                .overlay(
                    Capsule()
                        .stroke(Color(colors.borderCoreDefault), lineWidth: 1)
                )
        }
        .frame(width: 40, height: 48)
    }
}
