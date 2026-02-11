//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

@MainActor final class ReactionsDetailView_Tests: StreamChatTestCase {
    private let currentUserId = StreamChatTestCase.currentUserId

    func test_reactionsDetailView_singleReactionType_snapshot() {
        // Given
        let like = MessageReactionType(rawValue: "like")
        let message = ChatMessage.mock(
            id: "msg1",
            cid: .unique,
            text: "Hello",
            author: .mock(id: "author"),
            reactionScores: [like: 2],
            reactionCounts: [like: 2]
        )
        let controller = makeController(messageId: message.id)
        let reactions = [
            ChatMessageReaction.mock(
                id: "r1",
                type: like,
                author: .mock(id: "user1", name: "Alice")
            ),
            ChatMessageReaction.mock(
                id: "r2",
                type: like,
                author: .mock(id: "user2", name: "Bob")
            )
        ]
        controller.reactions_simulated = reactions
        let viewModel = ReactionsDetailViewModel(
            message: message,
            reactionListController: controller
        )
        viewModel.controller(controller, didChangeReactions: [])

        // When
        let view = ReactionsDetailView(viewModel: viewModel)
            .frame(width: defaultScreenSize.width, height: defaultScreenSize.height)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_reactionsDetailView_multipleReactionTypes_snapshot() {
        // Given
        let like = MessageReactionType(rawValue: "like")
        let love = MessageReactionType(rawValue: "love")
        let haha = MessageReactionType(rawValue: "haha")
        let message = ChatMessage.mock(
            id: "msg2",
            cid: .unique,
            text: "Hello",
            author: .mock(id: "author"),
            reactionScores: [like: 2, love: 1, haha: 1],
            reactionCounts: [like: 2, love: 1, haha: 1]
        )
        let controller = makeController(messageId: message.id)
        let reactions = [
            ChatMessageReaction.mock(id: "r1", type: like, author: .mock(id: "user1", name: "Alice")),
            ChatMessageReaction.mock(id: "r2", type: like, author: .mock(id: "user2", name: "Bob")),
            ChatMessageReaction.mock(id: "r3", type: love, author: .mock(id: "user3", name: "Charlie")),
            ChatMessageReaction.mock(id: "r4", type: haha, author: .mock(id: "user4", name: "Diana"))
        ]
        controller.reactions_simulated = reactions
        let viewModel = ReactionsDetailViewModel(
            message: message,
            reactionListController: controller
        )
        viewModel.controller(controller, didChangeReactions: [])

        // When
        let view = ReactionsDetailView(viewModel: viewModel)
            .frame(width: defaultScreenSize.width, height: defaultScreenSize.height)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_reactionsDetailView_withCurrentUser_snapshot() {
        // Given
        let like = MessageReactionType(rawValue: "like")
        let message = ChatMessage.mock(
            id: "msg3",
            cid: .unique,
            text: "Hello",
            author: .mock(id: "author"),
            reactionScores: [like: 3],
            reactionCounts: [like: 3]
        )
        let controller = makeController(messageId: message.id)
        let reactions = [
            ChatMessageReaction.mock(
                id: "r1",
                type: like,
                author: .mock(id: currentUserId, name: "You")
            ),
            ChatMessageReaction.mock(
                id: "r2",
                type: like,
                author: .mock(id: "user2", name: "Alice")
            ),
            ChatMessageReaction.mock(
                id: "r3",
                type: like,
                author: .mock(id: "user3", name: "Bob")
            )
        ]
        controller.reactions_simulated = reactions
        let viewModel = ReactionsDetailViewModel(
            message: message,
            reactionListController: controller
        )
        viewModel.controller(controller, didChangeReactions: [])

        // When
        let view = ReactionsDetailView(viewModel: viewModel)
            .frame(width: defaultScreenSize.width, height: defaultScreenSize.height)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_reactionsDetailView_filteredByType_snapshot() {
        // Given
        let like = MessageReactionType(rawValue: "like")
        let love = MessageReactionType(rawValue: "love")
        let message = ChatMessage.mock(
            id: "msg4",
            cid: .unique,
            text: "Hello",
            author: .mock(id: "author"),
            reactionScores: [like: 2, love: 1],
            reactionCounts: [like: 2, love: 1]
        )
        let controller = makeController(messageId: message.id)
        let reactions = [
            ChatMessageReaction.mock(id: "r1", type: like, author: .mock(id: "user1", name: "Alice")),
            ChatMessageReaction.mock(id: "r2", type: like, author: .mock(id: "user2", name: "Bob")),
            ChatMessageReaction.mock(id: "r3", type: love, author: .mock(id: "user3", name: "Charlie"))
        ]
        controller.reactions_simulated = reactions
        let viewModel = ReactionsDetailViewModel(
            message: message,
            reactionListController: controller
        )
        viewModel.controller(controller, didChangeReactions: [])
        viewModel.selectedReactionType = love

        // When
        let view = ReactionsDetailView(viewModel: viewModel)
            .frame(width: defaultScreenSize.width, height: defaultScreenSize.height)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_reactionsDetailView_empty_snapshot() {
        // Given
        let message = ChatMessage.mock(
            id: "msg5",
            cid: .unique,
            text: "Hello",
            author: .mock(id: "author")
        )
        let controller = makeController(messageId: message.id)
        let viewModel = ReactionsDetailViewModel(
            message: message,
            reactionListController: controller
        )

        // When
        let view = ReactionsDetailView(viewModel: viewModel)
            .frame(width: defaultScreenSize.width, height: defaultScreenSize.height)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_reactionsDetailView_manyReactions_snapshot() {
        // Given
        let like = MessageReactionType(rawValue: "like")
        let love = MessageReactionType(rawValue: "love")
        let haha = MessageReactionType(rawValue: "haha")
        let sad = MessageReactionType(rawValue: "sad")
        let wow = MessageReactionType(rawValue: "wow")
        let message = ChatMessage.mock(
            id: "msg6",
            cid: .unique,
            text: "Hello",
            author: .mock(id: "author"),
            reactionScores: [like: 3, love: 2, haha: 2, sad: 1, wow: 1],
            reactionCounts: [like: 3, love: 2, haha: 2, sad: 1, wow: 1]
        )
        let controller = makeController(messageId: message.id)
        let reactions = [
            ChatMessageReaction.mock(id: "r1", type: like, author: .mock(id: "u1", name: "Alice")),
            ChatMessageReaction.mock(id: "r2", type: like, author: .mock(id: "u2", name: "Bob")),
            ChatMessageReaction.mock(id: "r3", type: like, author: .mock(id: "u3", name: "Charlie")),
            ChatMessageReaction.mock(id: "r4", type: love, author: .mock(id: "u4", name: "Diana")),
            ChatMessageReaction.mock(id: "r5", type: love, author: .mock(id: "u5", name: "Eve")),
            ChatMessageReaction.mock(id: "r6", type: haha, author: .mock(id: "u6", name: "Frank")),
            ChatMessageReaction.mock(id: "r7", type: haha, author: .mock(id: "u7", name: "Grace")),
            ChatMessageReaction.mock(id: "r8", type: sad, author: .mock(id: "u8", name: "Henry")),
            ChatMessageReaction.mock(id: "r9", type: wow, author: .mock(id: "u9", name: "Ivy"))
        ]
        controller.reactions_simulated = reactions
        let viewModel = ReactionsDetailViewModel(
            message: message,
            reactionListController: controller
        )
        viewModel.controller(controller, didChangeReactions: [])

        // When
        let view = ReactionsDetailView(viewModel: viewModel)
            .frame(width: defaultScreenSize.width, height: defaultScreenSize.height)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    // MARK: - Helpers

    private func makeController(messageId: MessageId) -> ChatReactionListControllerSUI_Mock {
        let query = ReactionListQuery(messageId: messageId)
        return ChatReactionListControllerSUI_Mock(query: query, client: chatClient)
    }
}
