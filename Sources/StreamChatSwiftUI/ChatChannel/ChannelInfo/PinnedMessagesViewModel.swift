//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Combine
import Foundation
import StreamChat
import SwiftUI

/// View model for the `PinnedMessagesView`.
@MainActor public class PinnedMessagesViewModel: ObservableObject {
    let channel: ChatChannel

    @Published var pinnedMessages: [ChatMessage]
    @Published var selectedMessage: ChatMessage?
    @Published var isLoading: Bool

    private var channelController: ChatChannelController?

    public init(channel: ChatChannel, channelController: ChatChannelController? = nil) {
        self.channel = channel
        if channelController != nil {
            pinnedMessages = []
            isLoading = true
        } else {
            pinnedMessages = channel.pinnedMessages
            isLoading = false
        }
        self.channelController = channelController
        loadPinnedMessages()
    }
    
    // MARK: - private
    
    private func loadPinnedMessages() {
        channelController?.loadPinnedMessages(completion: { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(messages):
                withAnimation {
                    self.pinnedMessages = messages
                }
                log.debug("Successfully loaded pinned messages")
            case let .failure(error):
                self.pinnedMessages = self.channel.pinnedMessages
                log.error("Error loading pinned messages \(error.localizedDescription)")
            }
            self.isLoading = false
        })
    }
}
