//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Cache for chats.
class ChatCache {

    @Injected(\.chatClient) var chatClient

    private var currentChat: Chat?

    /// Creates a chats with the provided channel id.
    /// - Parameter channelId: the channel's id.
    /// - Returns: `Chat`
    func chat(for channelId: ChannelId) -> Chat {
        if let currentChat, channelId == currentChat.cid {
            return currentChat
        }
        let chat = chatClient.makeChat(for: channelId)
        currentChat = chat
        return chat
    }

    /// Clears the current active chat.
    func clearCurrentChat() {
        currentChat = nil
    }
}
