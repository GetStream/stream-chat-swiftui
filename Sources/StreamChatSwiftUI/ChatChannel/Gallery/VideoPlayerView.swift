//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import AVKit
import StreamChat
import SwiftUI

/// View used for displaying videos.
public struct VideoPlayerView: View {
    @Environment(\.presentationMode) var presentationMode

    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors

    let attachment: ChatMessageVideoAttachment
    let author: ChatUser
    @Binding var isShown: Bool

    private let avPlayer: AVPlayer

    public init(
        attachment: ChatMessageVideoAttachment,
        author: ChatUser,
        isShown: Binding<Bool>
    ) {
        self.attachment = attachment
        self.author = author
        avPlayer = AVPlayer(url: attachment.payload.videoURL)
        _isShown = isShown
    }

    public var body: some View {
        VStack {
            GalleryHeaderView(
                title: author.name ?? "",
                subtitle: author.onlineText,
                isShown: $isShown
            )
            VideoPlayer(player: avPlayer)
            Spacer()
            HStack {
                ShareButtonView(content: [attachment.payload.videoURL])
                    .standardPadding()

                Spacer()
            }
            .foregroundColor(Color(colors.text))
        }
        .onAppear {
            try? AVAudioSession.sharedInstance().setCategory(.playback, options: [])
            avPlayer.play()
        }
        .onDisappear {
            avPlayer.replaceCurrentItem(with: nil)
        }
    }
}

extension ChatUser {

    var onlineText: String {
        if isOnline {
            return L10n.Message.Title.online
        } else {
            return L10n.Message.Title.offline
        }
    }
}
