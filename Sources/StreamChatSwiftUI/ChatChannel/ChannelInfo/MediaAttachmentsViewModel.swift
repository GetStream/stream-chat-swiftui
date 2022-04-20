//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat
import SwiftUI

class MediaAttachmentsViewModel: ObservableObject {
    
    @Published var mediaItems = [MediaItem]()
    @Published var loading = false
    
    @Injected(\.chatClient) var chatClient
    
    private let channel: ChatChannel
    private var messageSearchController: ChatMessageSearchController!
    
    init(channel: ChatChannel) {
        self.channel = channel
        messageSearchController = chatClient.messageSearchController()
        loadMessages()
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
                    imageURL: imageAttachment.imageURL,
                    isVideo: false
                )
                result.append(mediaItem)
            }
            for videoAttachment in videoAttachments {
                let mediaItem = MediaItem(
                    id: videoAttachment.id.rawValue,
                    imageURL: videoAttachment.videoURL,
                    isVideo: true
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
    let imageURL: URL
    let isVideo: Bool
}
