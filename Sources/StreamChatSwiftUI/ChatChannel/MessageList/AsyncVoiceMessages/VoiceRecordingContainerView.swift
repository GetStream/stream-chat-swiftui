//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

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
        VStack {
            if let quotedMessage = utils.messageCachingUtils.quotedMessage(for: message) {
                factory.makeQuotedMessageView(
                    quotedMessage: quotedMessage,
                    fillAvailableSpace: !message.attachmentCounts.isEmpty,
                    isInComposer: false,
                    scrolledId: $scrolledId
                )
            }
            
            ForEach(message.voiceRecordingAttachments, id: \.self) { attachment in
                VoiceRecordingView(
                    handler: handler,
                    addedVoiceRecording: AddedVoiceRecording(
                        url: attachment.payload.voiceRecordingURL,
                        duration: attachment.payload.duration ?? 0,
                        waveform: attachment.payload.waveformData ?? []
                    ),
                    index: index(for: attachment)
                )
            }
            if !message.text.isEmpty {
                AttachmentTextView(message: message)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(16)
            }
        }
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
        .padding(.all, 8)
        .background(Color(colors.background))
        .cornerRadius(16)
        .padding(.all, 4)
        .modifier(
            factory.makeMessageViewModifier(
                for: MessageModifierInfo(message: message, isFirst: isFirst)
            )
        )
    }
    
    private func index(for attachment: ChatMessageVoiceRecordingAttachment) -> Int {
        message.voiceRecordingAttachments.firstIndex(of: attachment) ?? 0
    }
}

struct VoiceRecordingView: View {
    @Injected(\.utils) var utils
    @Injected(\.colors) var colors
    @Injected(\.images) var images
    
    @State var isPlaying: Bool = false
    @State var loading: Bool = false
    @State var rate: AudioPlaybackRate = .normal
    @ObservedObject var handler: VoiceRecordingHandler
    
    let addedVoiceRecording: AddedVoiceRecording
    let index: Int
    
    private var player: AudioPlaying {
        utils.audioPlayer
    }
    
    private var rateTitle: String {
        switch rate {
        case .half:
            return "x0.5"
        default:
            return "x\(Int(rate.rawValue))"
        }
    }
    
    var body: some View {
        HStack {
            Button(action: {
                handlePlayTap()
            }, label: {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .padding(.all, 8)
                    .foregroundColor(.primary)
                    .modifier(ShadowViewModifier(firstRadius: 2, firstY: 4))
            })
                .opacity(loading ? 0 : 1)
                .overlay(loading ? ProgressView() : nil)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(
                    utils.audioRecordingNameFormatter.title(
                        forItemAtURL: addedVoiceRecording.url,
                        index: index
                    )
                )
                .bold()
                .lineLimit(1)
                
                HStack {
                    RecordingDurationView(
                        duration: showContextDuration ? handler.context.currentTime : addedVoiceRecording.duration
                    )
                    WaveformViewSwiftUI(
                        audioContext: handler.context,
                        addedVoiceRecording: addedVoiceRecording,
                        onSliderChanged: { timeInterval in
                            if isCurrentRecordingActive {
                                player.seek(to: timeInterval)
                            } else {
                                player.loadAsset(from: addedVoiceRecording.url)
                                player.seek(to: timeInterval)
                            }
                        },
                        onSliderTapped: {
                            handlePlayTap()
                        }
                    )
                    .frame(height: 30)
                    Spacer()
                }
            }
                        
            if isPlaying {
                Button(action: {
                    if rate == .normal {
                        rate = .double
                    } else if rate == .double {
                        rate = .half
                    } else {
                        rate = .normal
                    }
                    player.updateRate(rate)
                }, label: {
                    Text(rateTitle)
                        .font(.caption)
                        .padding(.all, 8)
                        .padding(.horizontal, 2)
                        .foregroundColor(.primary)
                        .modifier(ShadowViewModifier(firstRadius: 2, firstY: 4))
                })
            } else {
                Image(uiImage: images.fileAac)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 36)
            }
        }
        .onReceive(handler.$context, perform: { value in
            guard value.assetLocation == addedVoiceRecording.url else { return }
            if value.state == .loading {
                loading = true
                return
            } else if loading {
                loading = false
            }
            if value.state == .stopped || value.state == .paused {
                isPlaying = false
            } else if value.state == .playing {
                isPlaying = true
            }
        })
    }
    
    private var showContextDuration: Bool {
        isCurrentRecordingActive && handler.context.currentTime > 0
    }
    
    private var isCurrentRecordingActive: Bool {
        handler.context.assetLocation == addedVoiceRecording.url
    }
    
    private func handlePlayTap() {
        if isPlaying {
            player.pause()
        } else {
            player.loadAsset(from: addedVoiceRecording.url)
        }
    }
}

class VoiceRecordingHandler: ObservableObject, AudioPlayingDelegate {
    
    @Published var context: AudioPlaybackContext = .notLoaded
    
    func audioPlayer(
        _ audioPlayer: AudioPlaying,
        didUpdateContext context: AudioPlaybackContext
    ) {
        self.context = context
    }
}
