//
// Copyright © 2026 Stream.io Inc. All rights reserved.
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
            id: .unique,
            type: .init(rawValue: "love"),
            score: 1,
            createdAt: Date(),
            updatedAt: Date(),
            author: author,
            extraData: [:]
        )
        let mockViewModel = MockReactionUsersViewModel(
            reactions: [reaction],
            totalReactionsCount: 1
        )

        // When
        let view = ReactionsUsersView(
            factory: DefaultViewFactory.shared,
            viewModel: mockViewModel,
            maxHeight: 140
        )
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
                id: .unique,
                type: .init(rawValue: "love"),
                score: 1,
                createdAt: Date(),
                updatedAt: Date(),
                author: author,
                extraData: [:]
            )
            reactions.insert(reaction)
        }

        let mockViewModel = MockReactionUsersViewModel(
            reactions: Array(reactions),
            totalReactionsCount: 8
        )

        // When
        let view = ReactionsUsersView(
            factory: DefaultViewFactory.shared,
            viewModel: mockViewModel,
            maxHeight: 280
        )
        .frame(width: defaultScreenSize.width, height: 320)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
}

class MockReactionUsersViewModel: ReactionsUsersViewModel {
    init(
        reactions: [ChatMessageReaction] = [],
        totalReactionsCount: Int = 0,
        isRightAligned: Bool = false
    ) {
        super.init(message: .mock())
        self.reactions = reactions
        mockedIsRightAligned = isRightAligned
        mockedTotalReactionsCount = totalReactionsCount
    }

    var mockedTotalReactionsCount: Int = 0
    override var totalReactionsCount: Int {
        mockedTotalReactionsCount
    }

    var mockedIsRightAligned: Bool = false
    override var isRightAligned: Bool {
        mockedIsRightAligned
    }
}
