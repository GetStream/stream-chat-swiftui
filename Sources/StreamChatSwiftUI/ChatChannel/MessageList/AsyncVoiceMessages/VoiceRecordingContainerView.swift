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
                    attachment: attachment,
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
    @ObservedObject var handler: VoiceRecordingHandler
    
    let attachment: ChatMessageVoiceRecordingAttachment
    let index: Int
    
    private var player: AudioPlaying {
        utils.audioPlayer
    }
    
    var body: some View {
        HStack {
            Button(action: {
                if isPlaying {
                    player.pause()
                } else {
                    player.loadAsset(from: attachment.voiceRecordingURL)
                }
                isPlaying.toggle()
            }, label: {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .padding(.all, 8)
                    .foregroundColor(.primary)
                    .overlay(
                        Circle()
                            .stroke(
                                Color(colors.innerBorder),
                                lineWidth: 0.5
                            )
                    )
            })
            
            VStack(alignment: .leading) {
                Text(
                    utils.audioRecordingNameFormatter.title(
                        forItemAtURL: attachment.voiceRecordingURL,
                        index: index
                    )
                )
                .bold()
                .lineLimit(1)
                
                HStack {
                    if let duration = attachment.duration {
                        Text(utils.videoDurationFormatter.format(duration) ?? "")
                            .font(.caption)
                            .foregroundColor(Color(colors.textLowEmphasis))
                    }
                    WaveformViewSwiftUI(audioContext: handler.context, attachment: attachment.payload)
                        .frame(height: 30)
                    Spacer()
                }
            }
            
            Spacer()
            
            Image(uiImage: images.fileAac)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32)
        }
        .onReceive(handler.$context, perform: { value in
            guard value.assetLocation == attachment.voiceRecordingURL else { return }
            if value.state == .stopped || value.state == .paused {
                isPlaying = false
            } else if value.state == .playing {
                isPlaying = true
            }
        })
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
