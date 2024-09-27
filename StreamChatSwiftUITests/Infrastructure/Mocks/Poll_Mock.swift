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
            latestVotesByOption: [option],
            latestVotes: [],
            ownVotes: []
        )
        return poll
    }
    
    static func mock(
        pollId: String = .unique,
        allowAnswers: Bool = true,
        allowUserSuggestedOptions: Bool = true,
        enforceUniqueVote: Bool = false,
        isClosed: Bool = false,
        options: [PollOption] = []
    ) -> Poll {
        let voteCountsByOption = Dictionary(grouping: options, by: { $0.id })
            .mapValues { options in
                options
                    .map(\.latestVotes.count)
                    .reduce(0, +)
            }
        return Poll(
            allowAnswers: allowAnswers,
            allowUserSuggestedOptions: allowUserSuggestedOptions,
            answersCount: allowAnswers ? 1 : 0,
            createdAt: Date(),
            pollDescription: "Test",
            enforceUniqueVote: enforceUniqueVote,
            id: pollId,
            name: "Test poll",
            updatedAt: Date(),
            voteCount: voteCountsByOption.values.reduce(0, +),
            extraData: [:],
            voteCountsByOption: voteCountsByOption,
            isClosed: isClosed,
            maxVotesAllowed: nil,
            votingVisibility: .public,
            createdBy: .mock(id: "test", name: "test"),
            latestAnswers: [],
            options: options,
            latestVotesByOption: options,
            latestVotes: [],
            ownVotes: []
        )
    }
}

extension PollOption {
    static func mock(
        id: String = .unique,
        text: String = .unique,
        latestVotes: [PollVote] = []
    ) -> PollOption {
        PollOption(
            id: id,
            text: text,
            latestVotes: latestVotes,
            extraData: nil
        )
    }
}

extension PollVote {
    static func mock(
        id: String = .unique,
        createdAt: Date = .unique,
        updatedAt: Date = .unique,
        pollId: String,
        optionId: String?,
        isAnswer: Bool = false,
        answerText: String? = nil,
        user: ChatUser? = nil
    ) -> PollVote {
        PollVote(
            id: .unique,
            createdAt: Date(),
            updatedAt: Date(),
            pollId: pollId,
            optionId: optionId,
            isAnswer: isAnswer,
            answerText: answerText,
            user: user
        )
    }
}

extension Poll {
    static func mock(optionCount: Int, voteCountForOption: (Int) -> Int) -> Poll {
        let pollId = String.unique
        let options = (0..<optionCount)
            .map { optionIndex in
                let optionId = String(format: "option_%03d", optionIndex)
                let votes = (0..<voteCountForOption(optionIndex))
                    .map { voteIndex in
                        PollVote.mock(
                            id: String(format: "vote_%03d", voteIndex),
                            createdAt: Date(timeIntervalSinceReferenceDate: TimeInterval(voteIndex)),
                            updatedAt: Date(timeIntervalSinceReferenceDate: TimeInterval(voteIndex) + 0.5),
                            pollId: pollId,
                            optionId: optionId,
                            isAnswer: false,
                            answerText: nil,
                            user: nil
                        )
                    }
                return PollOption.mock(
                    id: optionId,
                    text: String(format: "option_text_%03d", optionIndex),
                    latestVotes: votes
                )
            }
        return Poll.mock(
            pollId: pollId,
            options: options
        )
    }
}
