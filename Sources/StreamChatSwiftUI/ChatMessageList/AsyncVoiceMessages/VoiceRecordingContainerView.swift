//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Combine
import StreamChat
import SwiftUI

public struct VoiceRecordingContainerView<Factory: ViewFactory>: View {
    @Injected(\.colors) var colors
    @Injected(\.images) var images
    @Injected(\.utils) var utils
    
    let factory: Factory
    let message: ChatMessage
    let width: CGFloat
    let isFirst: Bool
    @Binding var scrolledId: String?
    
    @StateObject var handler = VoiceRecordingHandler()
    @State var playingIndex: Int?
    
    private var player: AudioPlaying {
        utils.audioPlayer
    }
    
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
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            VStack {
                if let quotedMessage = message.quotedMessage {
                    factory.makeChatQuotedMessageView(
                        options: ChatQuotedMessageViewOptions(
                            quotedMessage: quotedMessage,
                            parentMessage: message,
                            scrolledId: $scrolledId
                        )
                    )
                }
                VStack(spacing: 2) {
                    ForEach(message.voiceRecordingAttachments, id: \.self) { attachment in
                        VoiceRecordingView(
                            handler: handler,
                            addedVoiceRecording: AddedVoiceRecording(
                                url: attachment.payload.voiceRecordingURL,
                                duration: attachment.payload.duration ?? 0,
                                waveform: attachment.payload.waveformData ?? []
                            )
                        )
                        .padding(.all, 8)
                    }
                }
            }
            if !message.text.isEmpty {
                AttachmentTextView(factory: factory, message: message)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.all, 2)
        .onReceive(handler.$context, perform: { value in
            guard message.voiceRecordingAttachments.count > 1 else { return }
            if value.state == .playing {
                let index = message.voiceRecordingAttachments.firstIndex { payload in
                    payload.voiceRecordingURL == value.assetLocation
                }
                if index != playingIndex {
                    playingIndex = index
                }
            } else if value.state == .stopped, let playingIndex {
                if playingIndex < (message.voiceRecordingAttachments.count - 1) {
                    let next = playingIndex + 1
                    let nextURL = message.voiceRecordingAttachments[next].voiceRecordingURL
                    player.loadAsset(from: nextURL)
                }
                self.playingIndex = nil
            }
        })
        .onAppear {
            player.subscribe(handler)
        }
        .modifier(
            factory.styles.makeMessageViewModifier(
                for: MessageModifierInfo(
                    message: message,
                    isFirst: isFirst,
                    cornerRadius: 16
                )
            )
        )
    }
    
    private func index(for attachment: ChatMessageVoiceRecordingAttachment) -> Int {
        message.voiceRecordingAttachments.firstIndex(of: attachment) ?? 0
    }
}

struct VoiceRecordingView: View {
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    @Injected(\.tokens) var tokens
    @Injected(\.utils) var utils

    @State var loading: Bool = false
    @ObservedObject var handler: VoiceRecordingHandler

    let addedVoiceRecording: AddedVoiceRecording

    private var isActive: Bool { handler.isActive(for: addedVoiceRecording.url) }
    private var showContextDuration: Bool { isActive && handler.context.currentTime > 0 }

    var body: some View {
        HStack(spacing: tokens.spacingXs) {
            playButton
            durationAndWaveform
            PlaybackSpeedToggle(handler: handler)
        }
        .onReceive(handler.$context) { value in
            guard value.assetLocation == addedVoiceRecording.url else { return }
            if value.state == .loading {
                loading = true
                return
            } else if loading {
                loading = false
            }
            handler.updatePlaybackState(for: addedVoiceRecording.url)
        }
    }

    private var playButton: some View {
        StreamIconButton(role: .secondary, style: .outline, size: .medium) {
            handler.togglePlayback(for: addedVoiceRecording.url)
        } icon: {
            Image(systemName: handler.isPlaying && isActive ? "pause.fill" : "play.fill")
                .font(.system(size: 20))
        }
        .opacity(loading ? 0 : 1)
        .overlay(loading ? ProgressView() : nil)
    }

    private var durationAndWaveform: some View {
        HStack(spacing: tokens.spacingXs) {
            Text(utils.videoDurationFormatter.format(showContextDuration ? handler.context.currentTime : addedVoiceRecording.duration) ?? "")
                .font(fonts.footnote.monospacedDigit())
                .foregroundColor(Color(handler.isPlaying && isActive ? colors.accentPrimary : colors.textPrimary))

            WaveformViewSwiftUI(
                audioContext: handler.context,
                addedVoiceRecording: addedVoiceRecording,
                onSliderChanged: { timeInterval in
                    handler.seek(to: timeInterval, loadingFrom: isActive ? nil : addedVoiceRecording.url)
                },
                onSliderTapped: {
                    handler.togglePlayback(for: addedVoiceRecording.url)
                }
            )
            .frame(height: 20)
        }
    }
}

/// Reusable playback speed toggle (x0.5 / x1 / x2).
struct PlaybackSpeedToggle: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens

    @ObservedObject var handler: VoiceRecordingHandler

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
                        .stroke(Color(colors.borderCoreDefault), lineWidth: 1)
                )
        }
        .frame(width: 40, height: 48)
    }
}

class VoiceRecordingHandler: ObservableObject, AudioPlayingDelegate {
    @Injected(\.utils) private var utils

    @Published var context: AudioPlaybackContext = .notLoaded
    @Published var isPlaying: Bool = false
    @Published var rate: AudioPlaybackRate = .normal

    private var player: AudioPlaying { utils.audioPlayer }

    func audioPlayer(
        _ audioPlayer: AudioPlaying,
        didUpdateContext context: AudioPlaybackContext
    ) {
        self.context = context
    }

    // MARK: - Shared Playback Helpers

    var rateTitle: String {
        switch rate {
        case .half: "x0.5"
        default: "x\(Int(rate.rawValue))"
        }
    }

    func updatePlaybackState(for url: URL) {
        guard context.assetLocation == url else { return }
        switch context.state {
        case .playing:
            isPlaying = true
        case .stopped, .paused:
            isPlaying = false
        default:
            break
        }
    }

    func togglePlayback(for url: URL) {
        if isPlaying {
            player.pause()
        } else {
            player.loadAsset(from: url)
        }
    }

    func cycleRate() {
        switch rate {
        case .normal: rate = .double
        case .double: rate = .half
        default: rate = .normal
        }
        player.updateRate(rate)
    }

    func isActive(for url: URL) -> Bool {
        context.assetLocation == url
    }

    func seek(to time: TimeInterval, loadingFrom url: URL? = nil) {
        if let url, !isActive(for: url) {
            player.loadAsset(from: url)
        }
        player.seek(to: time)
    }
}
