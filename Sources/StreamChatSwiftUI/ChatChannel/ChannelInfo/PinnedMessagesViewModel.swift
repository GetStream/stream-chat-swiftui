//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat
import SwiftUI

/// View model for the `PinnedMessagesView`.
public class PinnedMessagesViewModel: ObservableObject {

    private let channel: ChatChannel

    @Published var pinnedMessages: [ChatMessage]
    
    private var channelController: ChatChannelController?
    
    public init(channel: ChatChannel, channelController: ChatChannelController? = nil) {
        self.channel = channel
        if channelController != nil {
            pinnedMessages = []
        } else {
            pinnedMessages = channel.pinnedMessages
        }
        self.channelController = channelController
        loadPinnedMessages()
    }
    
    private func loadPinnedMessages() {
        channelController?.loadPinnedMessages(completion: { [weak self] result in
            switch result {
            case .success(let messages):
                withAnimation {
                    self?.pinnedMessages = messages
                }
                log.debug("Successfully loaded pinned messages")
            case .failure(let error):
                self?.pinnedMessages = self?.channel.pinnedMessages ?? []
                log.error("Error loading pinned messages \(error.localizedDescription)")
            }
        })
    }
}
