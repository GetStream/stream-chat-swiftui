//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import Combine
import StreamChat
import SwiftUI

open class ReactionsOverlayViewModel: ObservableObject, ChatMessageControllerDelegate {
    @Injected(\.chatClient) private var chatClient
    @Injected(\.utils) private var utils

    @Published public var message: ChatMessage {
        didSet {
            reactions = Self.reactions(from: message)
        }
    }
    
    @Published public var errorShown = false
    @Published public var reactions: [MessageReactionType]

    private var messageController: ChatMessageController?

    public init(message: ChatMessage) {
        self.message = message
        reactions = Self.reactions(from: message)
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
            withAnimation {
                self.message = message
            }
        }
    }

    // MARK: - private
    
    private static func reactions(from message: ChatMessage) -> [MessageReactionType] {
        message.reactionScores.keys.filter { reactionType in
            (message.reactionScores[reactionType] ?? 0) > 0
        }
        .sorted(by: InjectedValues[\.utils].sortReactions)
    }

    private func makeMessageController(for message: ChatMessage) {
        let controllerFactory = InjectedValues[\.utils].channelControllerFactory
        if let channelId = message.cid {
            messageController = controllerFactory.makeMessageController(
                for: message.id,
                channelId: channelId
            )
            messageController?.delegate = self
            if let message = messageController?.message {
                self.message = message
            }
        }
    }

    private var userReactionIDs: Set<MessageReactionType> {
        Set(message.currentUserReactions.map(\.type))
    }
}
