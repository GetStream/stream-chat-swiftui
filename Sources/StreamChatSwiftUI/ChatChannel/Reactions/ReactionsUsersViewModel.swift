//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

class ReactionsUsersViewModel: ObservableObject, ChatMessageControllerDelegate {
    @Published var reactions: [ChatMessageReaction] = []

    var totalReactionsCount: Int {
        messageController?.message?.totalReactionsCount ?? 0
    }

    var isRightAligned: Bool {
        messageController?.message?.isRightAligned == true
    }

    private var isLoading = false
    private let messageController: ChatMessageController?
    
    init(message: ChatMessage) {
        if let cid = message.cid {
            messageController = InjectedValues[\.chatClient].messageController(
                cid: cid,
                messageId: message.id
            )
        } else {
            messageController = nil
        }
        messageController?.delegate = self
        loadMoreReactions()
    }

    func loadMoreReactions() {
        guard let messageController = self.messageController else {
            return
        }
        guard !isLoading && messageController.hasLoadedAllReactions == false else {
            return
        }

        isLoading = true
        messageController.loadNextReactions { [weak self] _ in
            self?.isLoading = false
        }
    }

    func messageController(_ controller: ChatMessageController, didChangeReactions reactions: [ChatMessageReaction]) {
        self.reactions = reactions
    }
}
