//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import SwiftUI
import XCTest

final class PollAttachmentView_Tests: StreamChatTestCase {

    func test_pollAttachmentView_snapshotCommentsAndSuggestions() {
        // Given
        let poll = createMockPoll()
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: .mock(id: .unique),
            poll: poll
        )
        
        // When
        let view = PollAttachmentView(
            factory: DefaultViewFactory.shared,
            message: message,
            poll: poll,
            isFirst: true
        )
        .frame(width: defaultScreenSize.width, height: 240)
        
        // Then
        assertSnapshot(matching: view, as: .image)
    }
    
    func test_pollAttachmentView_snapshotUniqueVotes() {
        // Given
        let poll = createMockPoll(
            allowAnswers: false,
            allowUserSuggestedOptions: false,
            enforceUniqueVote: true
        )
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: .mock(id: .unique),
            poll: poll
        )
        
        // When
        let view = PollAttachmentView(
            factory: DefaultViewFactory.shared,
            message: message,
            poll: poll,
            isFirst: true
        )
        .frame(width: defaultScreenSize.width, height: 150)
        
        // Then
        assertSnapshot(matching: view, as: .image)
    }
    
    func test_pollAttachmentView_closedPoll() {
        // Given
        let poll = createMockPoll(
            allowAnswers: false,
            allowUserSuggestedOptions: false,
            enforceUniqueVote: true,
            isClosed: true
        )
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: .mock(id: .unique),
            poll: poll
        )
        
        // When
        let view = PollAttachmentView(
            factory: DefaultViewFactory.shared,
            message: message,
            poll: poll,
            isFirst: true
        )
        .frame(width: defaultScreenSize.width, height: 150)
        
        // Then
        assertSnapshot(matching: view, as: .image)
    }
    
    // MARK: - private
    
    private func createMockPoll(
        allowAnswers: Bool = true,
        allowUserSuggestedOptions: Bool = true,
        enforceUniqueVote: Bool = false,
        isClosed: Bool = false
    ) -> Poll {
        let pollId = "123"
        let vote = PollVote(
            id: .unique,
            createdAt: Date(),
            updatedAt: Date(),
            pollId: pollId,
            optionId: "test",
            isAnswer: false,
            answerText: nil,
            user: .unique
        )
        let option = PollOption(
            id: "test",
            text: "Test option",
            latestVotes: [vote],
            extraData: [:]
        )
        let poll = Poll(
            allowAnswers: allowAnswers,
            allowUserSuggestedOptions: allowUserSuggestedOptions,
            answersCount: allowAnswers ? 1 : 0,
            createdAt: Date(),
            pollDescription: "Test",
            enforceUniqueVote: enforceUniqueVote,
            id: pollId,
            name: "Test poll",
            updatedAt: Date(),
            voteCount: 1,
            extraData: [:],
            voteCountsByOption: ["test": 1],
            isClosed: isClosed,
            maxVotesAllowed: nil,
            votingVisibility: .public,
            createdBy: .mock(id: "test", name: "test"),
            latestAnswers: [],
            options: [option],
            latestVotesByOption: [option]
        )
        return poll
    }
    
}
