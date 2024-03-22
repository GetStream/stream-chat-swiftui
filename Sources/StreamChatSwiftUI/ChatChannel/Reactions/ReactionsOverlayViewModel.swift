//
// Copyright © 2024 Stream.io Inc. All rights reserved.
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

    private let chat: Chat
    
    private var messageState: MessageState?
    
    private var cancellables = Set<AnyCancellable>()
    
    public init(chat: Chat, message: ChatMessage) {
        self.message = message
        self.chat = chat
        reactions = Self.reactions(from: message)
        Task {
            self.messageState = try await chat.makeMessageState(for: message.id)
            self.messageState?.$message
                .receive(on: RunLoop.main)
                .sink(receiveValue: { [weak self] message in
                    withAnimation {
                        self?.message = message
                    }
                }
            )
            .store(in: &cancellables)
        }
    }

    public func reactionTapped(_ reaction: MessageReactionType) {
        if userReactionIDs.contains(reaction) {
            // reaction should be removed
            Task {
                try await chat.deleteReaction(from: message.id, with: reaction)
            }
        } else {
            // reaction should be added
            Task {
                try await chat.sendReaction(
                    to: message.id,
                    with: reaction,
                    score: 1,
                    enforceUnique: utils.messageListConfig.uniqueReactionsEnabled,
                    extraData: [:]
                )
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

    private var userReactionIDs: Set<MessageReactionType> {
        Set(message.currentUserReactions.map(\.type))
    }
}
