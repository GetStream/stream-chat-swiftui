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

@MainActor final class ReactionsView_Tests: StreamChatTestCase {
    func test_reactionsView_clustered_snapshot() {
        // Given
        let size = CGSize(width: 200, height: 80)
        configureReactionsStyle(.clustered)
        let message = messageWithReactions()

        // When
        let view = ReactionsView(
            message: message,
            reactionsStyle: .clustered,
            reactions: reactions(for: message)
        )
        .frame(width: size.width, height: size.height)

        // Then
        AssertSnapshot(view, size: size)
    }

    func test_reactionsView_clustered_multipleScores_snapshot() {
        // Given
        let size = CGSize(width: 200, height: 80)
        configureReactionsStyle(.clustered)
        let message = messageWithReactions(
            scores: [
                .init(rawValue: "love"): 3,
                .init(rawValue: "like"): 2,
                .init(rawValue: "haha"): 1
            ]
        )

        // When
        let view = ReactionsView(
            message: message,
            reactionsStyle: .clustered,
            reactions: reactions(for: message)
        )
        .frame(width: size.width, height: size.height)

        // Then
        AssertSnapshot(view, size: size)
    }

    func test_reactionsView_segmented_snapshot() {
        // Given
        let size = CGSize(width: 200, height: 80)
        configureReactionsStyle(.segmented)
        let message = messageWithReactions()

        // When
        let view = ReactionsView(
            message: message,
            reactionsStyle: .segmented,
            reactions: reactions(for: message)
        )
        .frame(width: size.width, height: size.height)

        // Then
        AssertSnapshot(view, size: size)
    }

    func test_reactionsView_segmented_multipleScores_snapshot() {
        // Given
        let size = CGSize(width: 200, height: 80)
        configureReactionsStyle(.segmented)
        let message = messageWithReactions(
            scores: [
                .init(rawValue: "love"): 3,
                .init(rawValue: "like"): 2,
                .init(rawValue: "haha"): 1
            ]
        )

        // When
        let view = ReactionsView(
            message: message,
            reactionsStyle: .segmented,
            reactions: reactions(for: message)
        )
        .frame(width: size.width, height: size.height)

        // Then
        AssertSnapshot(view, size: size)
    }

    private func configureReactionsStyle(_ style: ReactionsStyle) {
        let messageDisplayOptions = MessageDisplayOptions(reactionsStyle: style)
        let utils = Utils(messageListConfig: MessageListConfig(messageDisplayOptions: messageDisplayOptions))
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
    }

    private func messageWithReactions(
        scores: [MessageReactionType: Int] = [
            .init(rawValue: "love"): 1,
            .init(rawValue: "like"): 1,
            .init(rawValue: "haha"): 1
        ]
    ) -> ChatMessage {
        ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hello reactions",
            author: .mock(id: .unique),
            reactionScores: scores,
            reactionCounts: scores
        )
    }
    
    private func reactions(for message: ChatMessage) -> [MessageReactionType] {
        @Injected(\.utils) var utils
        return message.reactionScores.keys.filter { reactionType in
            (message.reactionScores[reactionType] ?? 0) > 0
        }
        .sorted(by: utils.sortReactions)
    }
}
