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
    
    private var chat: Chat?
    
    public init(channel: ChatChannel, chat: Chat? = nil) {
        self.channel = channel
        if chat != nil {
            pinnedMessages = []
        } else {
            pinnedMessages = channel.pinnedMessages
        }
        self.chat = chat
        loadPinnedMessages()
    }
    
    // MARK: - private
    
    private func loadPinnedMessages() {
        Task { @MainActor in
            do {
                pinnedMessages = try await chat?.loadPinnedMessages() ?? []
            } catch {
                pinnedMessages = channel.pinnedMessages
            }
        }
    }
}
