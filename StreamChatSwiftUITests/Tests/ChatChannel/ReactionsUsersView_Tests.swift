//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

class ReactionsUsersView_Tests: StreamChatTestCase {

    func test_reactionsUsersView_snapshotOneRow() {
        // Given
        let author = ChatUser.mock(id: .unique, name: "Martin")
        let reaction = ChatMessageReaction(
            type: .init(rawValue: "love"),
            score: 1,
            createdAt: Date(),
            updatedAt: Date(),
            author: author,
            extraData: [:]
        )
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "test",
            author: .mock(id: .unique),
            latestReactions: [reaction]
        )

        // When
        let view = ReactionsUsersView(message: message, maxHeight: 140)
            .frame(width: 250)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_reactionsUsersView_snapshotTwoRows() {
        // Given
        var reactions = Set<ChatMessageReaction>()
        for _ in 0..<8 {
            let author = ChatUser.mock(id: .unique, name: "Martin")
            let reaction = ChatMessageReaction(
                type: .init(rawValue: "love"),
                score: 1,
                createdAt: Date(),
                updatedAt: Date(),
                author: author,
                extraData: [:]
            )
            reactions.insert(reaction)
        }

        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "test",
            author: .mock(id: .unique),
            latestReactions: reactions
        )

        // When
        let view = ReactionsUsersView(message: message, maxHeight: 280)
            .frame(width: defaultScreenSize.width, height: 320)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
}
