//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat
import SwiftUI

/// View model for the `MediaAttachmentsView`.
@MainActor class MediaAttachmentsViewModel: ObservableObject, ChatMessageSearchControllerDelegate {

    @Published var mediaItems = [MediaItem]()
    @Published var loading = false
    @Published var galleryShown = false

    @Injected(\.chatClient) var chatClient

    private let channel: ChatChannel
    private var messageSearchController: ChatMessageSearchController!

    private var loadingNextMessages = false

    var allImageAttachments: [ChatMessageImageAttachment] {
        mediaItems.compactMap(\.imageAttachment)
    }

    init(channel: ChatChannel) {
        self.channel = channel
        messageSearchController = chatClient.messageSearchController()
        messageSearchController.delegate = self
        loadMessages()
    }

    init(
        channel: ChatChannel,
        messageSearchController: ChatMessageSearchController
    ) {
        self.channel = channel
        self.messageSearchController = messageSearchController
        loadMessages()
    }

    func onMediaAttachmentAppear(with index: Int) {
        if index < mediaItems.count - 10 {
            return
        }

        if !loadingNextMessages {
            loadingNextMessages = true
            messageSearchController.loadNextMessages { [weak self] _ in
                StreamConcurrency.onMain { [weak self] in
                    guard let self = self else { return }
                    self.updateAttachments()
                    self.loadingNextMessages = false
                }
            }
        }
    }
    
    // MARK: - ChatMessageSearchControllerDelegate
    
    nonisolated func controller(_ controller: ChatMessageSearchController, didChangeMessages changes: [ListChange<ChatMessage>]) {
        StreamConcurrency.onMain {
            updateAttachments()
        }
    }

    private func loadMessages() {
        let query = MessageSearchQuery(
            channelFilter: .equal(.cid, to: channel.cid),
            messageFilter: .withAttachments([.image, .video])
        )

        loading = true
        messageSearchController.search(query: query, completion: { [weak self] _ in
            StreamConcurrency.onMain { [weak self] in
                guard let self = self else { return }
                self.updateAttachments()
                self.loading = false
            }
        })
    }

    private func updateAttachments() {
        var result = [MediaItem]()
        for message in messageSearchController.messages {
            let imageAttachments = message.imageAttachments
            let videoAttachments = message.videoAttachments
            for imageAttachment in imageAttachments {
                let mediaItem = MediaItem(
                    id: imageAttachment.id.rawValue,
                    isVideo: false,
                    message: message,
                    videoAttachment: nil,
                    imageAttachment: imageAttachment
                )
                result.append(mediaItem)
            }
            for videoAttachment in videoAttachments {
                let mediaItem = MediaItem(
                    id: videoAttachment.id.rawValue,
                    isVideo: true,
                    message: message,
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
    let message: ChatMessage

    var videoAttachment: ChatMessageVideoAttachment?
    var imageAttachment: ChatMessageImageAttachment?
}
