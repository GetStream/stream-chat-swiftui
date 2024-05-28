//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Foundation
@testable import StreamChat

extension Poll {
    static func mock(
        allowAnswers: Bool = true,
        allowUserSuggestedOptions: Bool = true,
        enforceUniqueVote: Bool = false,
        isClosed: Bool = false,
        name: String = "Test poll"
    ) -> Poll {
        let pollId = "123"
        let voteId = "456"
        let voter = ChatUser.mock(id: "voter", name: "voter")
        let vote = PollVote(
            id: voteId,
            createdAt: Date(),
            updatedAt: Date(),
            pollId: pollId,
            optionId: "test",
            isAnswer: false,
            answerText: nil,
            user: voter
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
            name: name,
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
