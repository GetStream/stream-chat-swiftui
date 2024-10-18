//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import AVKit
import StreamChat
import SwiftUI

/// View used for displaying videos.
public struct VideoPlayerView: View {
    @Environment(\.presentationMode) var presentationMode

    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.utils) private var utils

    private var fileCDN: FileCDN {
        utils.fileCDN
    }

    let attachment: ChatMessageVideoAttachment
    let author: ChatUser
    @Binding var isShown: Bool

    @State private var avPlayer: AVPlayer?
    @State private var error: Error?

    public init(
        attachment: ChatMessageVideoAttachment,
        author: ChatUser,
        isShown: Binding<Bool>
    ) {
        self.attachment = attachment
        self.author = author
        _isShown = isShown
    }

    public var body: some View {
        VStack {
            GalleryHeaderView(
                title: author.name ?? "",
                subtitle: author.onlineText,
                isShown: $isShown
            )
            if let avPlayer {
                VideoPlayer(player: avPlayer)
            }
            Spacer()
            HStack {
                ShareButtonView(content: [attachment.payload.videoURL])
                    .standardPadding()

                Spacer()
            }
            .foregroundColor(Color(colors.text))
        }
        .onAppear {
            fileCDN.adjustedURL(for: attachment.payload.videoURL) { result in
                switch result {
                case let .success(url):
                    self.avPlayer = AVPlayer(url: url)
                    try? AVAudioSession.sharedInstance().setCategory(.playback, options: [])
                    self.avPlayer?.play()
                case let .failure(error):
                    self.error = error
                }
            }
        }
        .onDisappear {
            avPlayer?.replaceCurrentItem(with: nil)
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
