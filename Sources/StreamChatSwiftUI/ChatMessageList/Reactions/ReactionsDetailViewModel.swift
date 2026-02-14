//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Combine
import StreamChat
import SwiftUI

@MainActor
class ReactionsDetailViewModel: ObservableObject, ChatReactionListControllerDelegate, ChatMessageControllerDelegate {
    @Injected(\.chatClient) private var chatClient
    @Injected(\.utils) private var utils

    let reactionListController: ChatReactionListController
    @Published var message: ChatMessage

    @Published var reactions: [ChatMessageReaction] = []
    @Published var selectedReactionType: MessageReactionType?
    @Published var moreReactionsPickerShown = false

    private(set) var loadingReactions = false
    private var messageController: ChatMessageController?
    private let loadMoreReactionsAction: (@escaping @MainActor (Error?) -> Void) -> Void

    var totalReactionsCount: Int {
        message.totalReactionsCount
    }

    var reactionTypes: [MessageReactionType] {
        message.reactionScores.keys
            .filter { (message.reactionScores[$0] ?? 0) > 0 }
            .sorted(by: utils.sortReactions)
    }

    var filteredReactions: [ChatMessageReaction] {
        if let selectedType = selectedReactionType {
            return reactions.filter { $0.type == selectedType }
        }
        return reactions
    }

    func reactionCount(for type: MessageReactionType) -> Int {
        message.reactionScores[type] ?? 0
    }

    func isCurrentUser(_ reaction: ChatMessageReaction) -> Bool {
        chatClient.currentUserId == reaction.author.id
    }

    func authorName(for reaction: ChatMessageReaction) -> String {
        if isCurrentUser(reaction) {
            return L10n.Message.Reactions.currentUser
        }
        return reaction.author.name ?? reaction.author.id
    }

    init(
        message: ChatMessage,
        reactionListController: ChatReactionListController? = nil,
        loadMoreReactionsAction: ((@escaping @MainActor (Error?) -> Void) -> Void)? = nil
    ) {
        self.message = message
        let controller = reactionListController
            ?? InjectedValues[\.chatClient].reactionListController(for: message.id)
        self.reactionListController = controller
        self.loadMoreReactionsAction = loadMoreReactionsAction ?? { completion in
            controller.loadMoreReactions(completion: completion)
        }
        self.reactionListController.delegate = self
        self.reactionListController.synchronize()
        makeMessageController(for: message)
    }

    func remove(reaction: ChatMessageReaction) {
        messageController?.deleteReaction(reaction.type)
    }

    public func reactionTapped(_ reaction: MessageReactionType) {
        if userReactionIDs.contains(reaction) {
            // reaction should be removed
            messageController?.deleteReaction(reaction)
        } else {
            // reaction should be added
            messageController?.addReaction(
                reaction,
                enforceUnique: utils.messageListConfig.uniqueReactionsEnabled
            )
        }
    }

    func onReactionAppear(_ reaction: ChatMessageReaction) {
        let items = filteredReactions
        guard let index = items.firstIndex(where: { $0.id == reaction.id }) else {
            return
        }
        guard index > items.count - 10, reactions.count >= 25 else {
            return
        }
        loadMoreReactions()
    }

    func controller(
        _ controller: ChatReactionListController,
        didChangeReactions changes: [ListChange<ChatMessageReaction>]
    ) {
        reactions = controller.reactions
    }

    func messageController(_ controller: ChatMessageController, didChangeMessage change: EntityChange<ChatMessage>) {
        if let message = controller.message {
            self.message = message
        }
    }

    func messageController(
        _ controller: ChatMessageController,
        didChangeReactions reactions: [ChatMessageReaction]
    ) {
        self.reactions = reactions
    }

    // MARK: - private

    private func loadMoreReactions() {
        if loadingReactions {
            return
        }
        loadingReactions = true
        loadMoreReactionsAction { [weak self] _ in
            guard let self else { return }
            self.loadingReactions = false
        }
    }

    private func makeMessageController(for message: ChatMessage) {
        if let channelId = message.cid {
            messageController = chatClient.messageController(
                cid: channelId,
                messageId: message.id
            )
            messageController?.synchronize()
            messageController?.delegate = self
        }
    }

    private var userReactionIDs: Set<MessageReactionType> {
        Set(message.currentUserReactions.map(\.type))
    }
}
