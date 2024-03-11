//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Factory for creating channel controllers.
class ChannelControllerFactory {

    @Injected(\.chatClient) var chatClient

    private var currentChat: Chat?
    private var messageControllers = [String: ChatMessageController]()

    /// Creates a channel controller with the provided channel id.
    /// - Parameter channelId: the channel's id.
    /// - Returns: `ChatChannelController`
    func makeChat(for channelId: ChannelId) -> Chat {
        if let currentChat, channelId == currentChat.cid {
            return currentChat
        }
        let chat = chatClient.makeChat(for: channelId)
        currentChat = chat
        return chat
    }
    
    /// Creates a message controller with the provided channel and message id.
    /// - Parameters:
    ///  - messageId: the message's id.
    ///  - channelId: the channel's id.
    /// - Returns: `ChatMessageController`
    func makeMessageController(
        for messageId: MessageId,
        channelId: ChannelId
    ) -> ChatMessageController {
        if let messageController = messageControllers[messageId] {
            return messageController
        }
        let messageController = chatClient.messageController(
            cid: channelId,
            messageId: messageId
        )
        messageController.synchronize()
        messageControllers[messageId] = messageController
        return messageController
    }

    /// Clears the current active channel controller.
    func clearCurrentController() {
        currentChat = nil
        messageControllers = [:]
    }
}
