//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Factory for creating channel controllers.
public class ChannelControllerFactory {

    @Injected(\.chatClient) var chatClient

    private var currentChannelController: ChatChannelController?
    private var messageControllers = [String: ChatMessageController]()

    /// Creates a channel controller with the provided channel id.
    /// - Parameter channelId: the channel's id.
    /// - Returns: `ChatChannelController`
    func makeChannelController(for channelId: ChannelId) -> ChatChannelController {
        if let currentChannelController = currentChannelController, channelId == currentChannelController.cid {
            return currentChannelController
        }
        let controller = chatClient.channelController(for: channelId)
        currentChannelController = controller
        return controller
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
        currentChannelController = nil
        messageControllers = [:]
    }
}
