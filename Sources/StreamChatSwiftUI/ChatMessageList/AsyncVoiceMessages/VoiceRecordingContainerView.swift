//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public struct VoiceRecordingContainerView<Factory: ViewFactory>: View {
    @Injected(\.colors) var colors
    @Injected(\.images) var images
    @Injected(\.tokens) var tokens
    @Injected(\.utils) var utils
    
    let factory: Factory
    let message: ChatMessage
    let width: CGFloat
    let isFirst: Bool
    @Binding var scrolledId: String?
    
    @ObservedObject var handler: AudioSessionHandler
    
    public init(
        factory: Factory,
        message: ChatMessage,
        width: CGFloat,
        isFirst: Bool,
        scrolledId: Binding<String?>
    ) {
        self.factory = factory
        self.message = message
        self.width = width
        self.isFirst = isFirst
        _scrolledId = scrolledId
        _handler = ObservedObject(wrappedValue: InjectedValues[\.utils].audioSessionHandler)
    }
    
    public var body: some View {
        VStack(spacing: tokens.spacingXxxs) {
            ForEach(message.voiceRecordingAttachments) { attachment in
                VoiceRecordingView(
                    handler: handler,
                    addedVoiceRecording: AddedVoiceRecording(
                        url: attachment.payload.voiceRecordingURL,
                        duration: attachment.payload.duration ?? 0,
                        waveform: attachment.payload.waveformData ?? []
                    ),
                    isSentByCurrentUser: message.isSentByCurrentUser,
                    accessibilityLabel: voiceMessageAccessibilityLabel(
                        duration: attachment.payload.duration ?? 0
                    )
                )
                .modifier(
                    factory.styles.makeMessageAttachmentItemViewModifier(
                        options: MessageAttachmentItemViewModifierOptions(
                            message: message,
                            isFirst: isFirst,
                            attachmentType: .voiceRecording
                        )
                    )
                )
            }
        }
        .frame(width: width, alignment: message.isRightAligned ? .trailing : .leading)
        .audioPlaybackQueue(
            handler: handler,
            urls: message.voiceRecordingAttachments.map(\.voiceRecordingURL)
        )
    }

    private func voiceMessageAccessibilityLabel(duration: TimeInterval) -> String {
        utils.messageAccessibilityFormatter.voiceRecordingLabel(
            for: message,
            metadata: VoiceRecordingAccessibilityMetadata(
                duration: utils.messageAccessibilityFormatter.duration(from: duration)
            )
        )
    }
}

struct VoiceRecordingView: View {
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    @Injected(\.tokens) var tokens
    @Injected(\.utils) var utils

    @ObservedObject var handler: AudioSessionHandler

    let addedVoiceRecording: AddedVoiceRecording
    var isSentByCurrentUser: Bool = false
    var accessibilityLabel: String = ""

    private var isActive: Bool { handler.isActive(for: addedVoiceRecording.url) }

    private var isLoading: Bool { isActive && handler.context.state == .loading }

    private var displayedPlaybackTime: TimeInterval {
        handler.displayedTime(for: addedVoiceRecording.url, duration: addedVoiceRecording.duration)
    }

    private var controlBorderColor: Color {
        colors.chatControlBorder(isSentByCurrentUser: isSentByCurrentUser)
    }

    var body: some View {
        HStack(spacing: tokens.spacingXs) {
            HStack(spacing: tokens.spacingXs) {
                playButton
                durationAndWaveform
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(accessibilityLabel)
            .accessibilityAddTraits([.isButton, .startsMediaSession])
            .accessibilityAction {
                handler.togglePlayback(for: addedVoiceRecording.url)
            }

            PlaybackSpeedToggle(handler: handler, borderColor: controlBorderColor)
        }
        .audioPlaybackStateUpdates(handler: handler, url: addedVoiceRecording.url)
    }

    private var playButton: some View {
        AudioPlaybackButton(
            isPlaying: handler.isPlaying && isActive,
            isLoading: isLoading,
            isSentByCurrentUser: isSentByCurrentUser
        ) {
            handler.togglePlayback(for: addedVoiceRecording.url)
        }
    }

    private var durationAndWaveform: some View {
        HStack(spacing: tokens.spacingXs) {
            Text(utils.videoDurationFormatter.format(displayedPlaybackTime) ?? "")
                .font(fonts.footnote.monospacedDigit())
                .foregroundColor(Color(handler.isPlaying && isActive ? colors.accentPrimary : colors.textPrimary))

            WaveformViewSwiftUI(
                audioContext: handler.context,
                addedVoiceRecording: addedVoiceRecording,
                isPlaying: handler.isPlaying && isActive,
                onSliderChanged: { timeInterval in
                    handler.seek(to: timeInterval, loadingFrom: isActive ? nil : addedVoiceRecording.url)
                },
                onSliderTapped: {
                    handler.togglePlayback(for: addedVoiceRecording.url)
                }
            )
            .frame(height: 20)
            .background(
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: SwipeToReplyExcludedFrameKey.self,
                        value: [proxy.frame(in: .named("swipeToReply"))]
                    )
                }
            )
        }
    }
}

/// Reusable playback speed toggle (x0.5 / x1 / x2).
struct PlaybackSpeedToggle: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens

    @ObservedObject var handler: AudioSessionHandler
    var borderColor: Color?

    private var resolvedBorderColor: Color {
        borderColor ?? Color(colors.borderCoreDefault)
    }

    var body: some View {
        Button {
            handler.cycleRate()
        } label: {
            Text(handler.rateTitle)
                .font(fonts.footnote)
                .foregroundColor(Color(colors.textPrimary))
                .frame(width: 40, height: 24)
                .overlay(
                    Capsule()
                        .stroke(resolvedBorderColor, lineWidth: 1)
                )
        }
        .frame(width: 40, height: 48)
        .accessibilityLabel(Text(L10n.Message.Accessibility.playbackSpeed))
        .accessibilityValue(Text(handler.rateTitle))
    }
}
