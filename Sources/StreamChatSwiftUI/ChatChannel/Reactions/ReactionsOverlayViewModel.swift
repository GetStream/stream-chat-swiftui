//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import Combine
import StreamChat
import SwiftUI

open class ReactionsOverlayViewModel: ObservableObject, ChatMessageControllerDelegate {
    @Injected(\.chatClient) private var chatClient

    @Published public var message: ChatMessage
    @Published public var errorShown = false

    private var messageController: ChatMessageController?

    public init(message: ChatMessage) {
        self.message = message
        makeMessageController(for: message)
    }

    public func reactionTapped(_ reaction: MessageReactionType) {
        if userReactionIDs.contains(reaction) {
            // reaction should be removed
            messageController?.deleteReaction(reaction)
        } else {
            // reaction should be added
            messageController?.addReaction(reaction)
        }
    }

    // MARK: - ChatMessageControllerDelegate

    public func messageController(
        _ controller: ChatMessageController,
        didChangeMessage change: EntityChange<ChatMessage>
    ) {
        if let message = controller.message {
            if message.reactionScoresId != self.message.reactionScoresId {
                withAnimation {
                    self.message = message
                }
            }
        }
    }

    // MARK: - private

    private func makeMessageController(for message: ChatMessage) {
        let controllerFactory = InjectedValues[\.utils].channelControllerFactory
        if let channelId = message.cid {
            messageController = controllerFactory.makeMessageController(
                for: message.id,
                channelId: channelId
            )
            messageController?.delegate = self
            if let message = messageController?.message {
                withAnimation {
                    self.message = message
                }
            }
        }
    }

    private var userReactionIDs: Set<MessageReactionType> {
        Set(message.currentUserReactions.map(\.type))
    }
}
