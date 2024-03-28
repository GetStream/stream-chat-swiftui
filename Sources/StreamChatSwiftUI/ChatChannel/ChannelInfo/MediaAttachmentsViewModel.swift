//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat
import SwiftUI

/// View model for the `MediaAttachmentsView`.
class MediaAttachmentsViewModel: ObservableObject {

    @Published var mediaItems = [MediaItem]()
    @Published var loading = false
    @Published var galleryShown = false

    @Injected(\.chatClient) var chatClient

    private let channel: ChatChannel
    private let messageSearch: MessageSearch

    private var loadingNextMessages = false

    var allImageAttachments: [ChatMessageImageAttachment] {
        mediaItems.compactMap(\.imageAttachment)
    }

    init(channel: ChatChannel) {
        self.channel = channel
        messageSearch = InjectedValues[\.chatClient].makeMessageSearch()
        loadMessages()
    }

    init(
        channel: ChatChannel,
        messageSearch: MessageSearch
    ) {
        self.channel = channel
        self.messageSearch = messageSearch
        loadMessages()
    }

    func onMediaAttachmentAppear(with index: Int) {
        if index < mediaItems.count - 10 {
            return
        }

        if !loadingNextMessages {
            loadingNextMessages = true
            Task { @MainActor in
                _ = try? await messageSearch.loadNextMessages()
                updateAttachments()
                loadingNextMessages = false
            }
        }
    }

    private func loadMessages() {
        let query = MessageSearchQuery(
            channelFilter: .equal(.cid, to: channel.cid),
            messageFilter: .withAttachments([.image, .video])
        )

        loading = true
        Task { @MainActor in
            _ = try? await messageSearch.search(query: query)
            updateAttachments()
            loading = false
        }
    }

    private func updateAttachments() {
        var result = [MediaItem]()
        for message in messageSearch.state.messages {
            let imageAttachments = message.imageAttachments
            let videoAttachments = message.videoAttachments
            for imageAttachment in imageAttachments {
                let mediaItem = MediaItem(
                    id: imageAttachment.id.rawValue,
                    isVideo: false,
                    author: message.author,
                    videoAttachment: nil,
                    imageAttachment: imageAttachment
                )
                result.append(mediaItem)
            }
            for videoAttachment in videoAttachments {
                let mediaItem = MediaItem(
                    id: videoAttachment.id.rawValue,
                    isVideo: true,
                    author: message.author,
                    videoAttachment: videoAttachment,
                    imageAttachment: nil
                )
                result.append(mediaItem)
            }
        }
        withAnimation {
            self.mediaItems = result
        }
    }
}

struct MediaItem: Identifiable {
    let id: String
    let isVideo: Bool
    let author: ChatUser

    var videoAttachment: ChatMessageVideoAttachment?
    var imageAttachment: ChatMessageImageAttachment?
}
