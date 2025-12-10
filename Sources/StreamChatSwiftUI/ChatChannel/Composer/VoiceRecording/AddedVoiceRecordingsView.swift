//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public struct AddedVoiceRecordingsView: View {
    @Injected(\.colors) private var colors
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
        VStack {
            ForEach(0..<addedVoiceRecordings.count, id: \.self) { i in
                let recording = addedVoiceRecordings[i]
                VoiceRecordingView(
                    handler: voiceRecordingHandler,
                    textColor: textColor(currentUser: true),
                    addedVoiceRecording: recording,
                    index: i
                )
                .padding(.all, 8)
                .padding(.trailing, 8)
                .background(Color(colors.background))
                .id(recording.url)
                .roundWithBorder()
                .overlay(
                    DiscardAttachmentButton(
                        attachmentIdentifier: recording.url.absoluteString,
                        onDiscard: onDiscardAttachment
                    )
                )
            }
        }
        .onAppear {
            player.subscribe(voiceRecordingHandler)
        }
    }
}
