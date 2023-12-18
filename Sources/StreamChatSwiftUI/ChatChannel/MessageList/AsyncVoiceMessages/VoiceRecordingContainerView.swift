//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public struct VoiceRecordingContainerView: View {

    @Injected(\.colors) var colors
    @Injected(\.images) var images
    @Injected(\.utils) var utils
    
    let message: ChatMessage
    let width: CGFloat
    let isFirst: Bool
    @Binding var scrolledId: String?
    
    @StateObject var handler = VoiceRecordingHandler()
    
    private var player: AudioPlaying {
        utils.audioPlayer
    }
    
    public init(
        message: ChatMessage,
        width: CGFloat,
        isFirst: Bool,
        scrolledId: Binding<String?>
    ) {
        self.message = message
        self.width = width
        self.isFirst = isFirst
        _scrolledId = scrolledId
    }
    
    public var body: some View {
        VStack {
            ForEach(message.voiceRecordingAttachments, id: \.self) { attachment in
                VoiceRecordingView(
                    handler: handler,
                    addedVoiceRecording:  AddedVoiceRecording(
                        url: attachment.payload.voiceRecordingURL,
                        duration: attachment.payload.duration ?? 0,
                        waveform: attachment.payload.waveformData ?? []
                    ),
                    index: index(for: attachment)
                )
            }
            if !message.text.isEmpty {
                AttachmentTextView(message: message)
                    .frame(width: width)
            }
        }
        .onAppear {
            player.subscribe(handler)
        }
        .padding(.all, 8)
        .background(Color(colors.background))
        .cornerRadius(16)
        .padding(.all, 4)
        .messageBubble(for: message, isFirst: isFirst)
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
            "x0.5"
        default:
            "x\(Int(rate.rawValue))"
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
                    RecordingDurationView(duration: addedVoiceRecording.duration)
                    WaveformViewSwiftUI(
                        audioContext: handler.context,
                        addedVoiceRecording: addedVoiceRecording,
                        onSliderChanged: { timeInterval in
                            if handler.context.assetLocation == addedVoiceRecording.url {
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
            if value.state == .stopped || value.state == .paused {
                isPlaying = false
            } else if value.state == .playing {
                isPlaying = true
            }
        })
    }
    
    private func handlePlayTap() {
        if isPlaying {
            player.pause()
        } else {
            player.loadAsset(from: addedVoiceRecording.url)
        }
        isPlaying.toggle()
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
