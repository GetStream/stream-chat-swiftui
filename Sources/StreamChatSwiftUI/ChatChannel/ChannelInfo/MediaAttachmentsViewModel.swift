//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat
import SwiftUI

/// View model for the `MediaAttachmentsView`.
class MediaAttachmentsViewModel: ObservableObject, ChatMessageSearchControllerDelegate {
    @Published var mediaItems = [MediaItem]()
    @Published var loading = false
    @Published var galleryShown = false

    @Injected(\.chatClient) var chatClient

    private let channel: ChatChannel
    private var messageSearchController: ChatMessageSearchController!

    private var loadingNextMessages = false

    var allMediaAttachments: [MediaAttachment] {
        mediaItems.compactMap(\.mediaAttachment)
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
                guard let self = self else { return }
                self.updateAttachments()
                self.loadingNextMessages = false
            }
        }
    }
    
    // MARK: - ChatMessageSearchControllerDelegate
    
    func controller(_ controller: ChatMessageSearchController, didChangeMessages changes: [ListChange<ChatMessage>]) {
        updateAttachments()
    }

    private func loadMessages() {
        let query = MessageSearchQuery(
            channelFilter: .equal(.cid, to: channel.cid),
            messageFilter: .withAttachments([.image, .video])
        )

        loading = true
        messageSearchController.search(query: query, completion: { [weak self] _ in
            guard let self = self else { return }
            self.updateAttachments()
            self.loading = false
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

public struct MediaItem: Identifiable {
    public let id: String
    public let isVideo: Bool
    public let message: ChatMessage

    public var videoAttachment: ChatMessageVideoAttachment?
    public var imageAttachment: ChatMessageImageAttachment?
    
    public init(
        id: String,
        isVideo: Bool,
        message: ChatMessage,
        videoAttachment: ChatMessageVideoAttachment?,
        imageAttachment: ChatMessageImageAttachment?
    ) {
        self.id = id
        self.isVideo = isVideo
        self.message = message
        self.videoAttachment = videoAttachment
        self.imageAttachment = imageAttachment
    }
    
    public var mediaAttachment: MediaAttachment? {
        if let videoAttachment {
            return MediaAttachment(url: videoAttachment.videoURL, type: .video)
        } else if let imageAttachment {
            return MediaAttachment(url: imageAttachment.imageURL, type: .image)
        }
        return nil
    }
}
