//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatCommonUI
@testable import StreamChatSwiftUI
import SwiftUI
import XCTest

@MainActor final class PollResultsView_Tests: StreamChatTestCase {
    // MARK: - PollResultsView

    func test_pollResultsView_defaultPoll() {
        let poll = Poll.mock()
        let viewModel = PollAttachmentViewModel(message: .mock(poll: poll), poll: poll)

        let view = PollResultsView(viewModel: viewModel, factory: DefaultViewFactory.shared)
            .applyDefaultSize()

        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_pollResultsView_multipleOptionsWithVotes() {
        let poll = makePollWithMultipleOptions()
        let viewModel = PollAttachmentViewModel(message: .mock(poll: poll), poll: poll)

        let view = PollResultsView(viewModel: viewModel, factory: DefaultViewFactory.shared)
            .applyDefaultSize()

        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_pollResultsView_optionWithMostVotesShowsTrophy() {
        let poll = makePollWithClearWinner()
        let viewModel = PollAttachmentViewModel(message: .mock(poll: poll), poll: poll)

        let view = PollResultsView(viewModel: viewModel, factory: DefaultViewFactory.shared)
            .applyDefaultSize()

        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_pollResultsView_optionWithViewAllButton() {
        let poll = makePollWithManyVotes()
        let viewModel = PollAttachmentViewModel(message: .mock(poll: poll), poll: poll)

        let view = PollResultsView(viewModel: viewModel, factory: DefaultViewFactory.shared)
            .applyDefaultSize()

        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_pollResultsView_optionWithZeroVotes() {
        let poll = makePollWithZeroVoteOption()
        let viewModel = PollAttachmentViewModel(message: .mock(poll: poll), poll: poll)

        let view = PollResultsView(viewModel: viewModel, factory: DefaultViewFactory.shared)
            .applyDefaultSize()

        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_pollResultsView_anonymousVoting() {
        let poll = makePollAnonymous()
        let viewModel = PollAttachmentViewModel(message: .mock(poll: poll), poll: poll)

        let view = PollResultsView(viewModel: viewModel, factory: DefaultViewFactory.shared)
            .applyDefaultSize()

        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_pollResultsView_singleVote() {
        let poll = makePollWithSingleVote()
        let viewModel = PollAttachmentViewModel(message: .mock(poll: poll), poll: poll)

        let view = PollResultsView(viewModel: viewModel, factory: DefaultViewFactory.shared)
            .applyDefaultSize()

        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    // MARK: - PollOptionResultsView

    func test_pollOptionResultsView_withOptionIndex() {
        let poll = Poll.mock()
        let option = poll.options[0]

        let view = PollOptionResultsView(
            factory: DefaultViewFactory.shared,
            poll: poll,
            option: option,
            optionIndex: 1,
            votes: Array(option.latestVotes.prefix(5)),
            hasMostVotes: false,
            allButtonShown: false
        )
        .frame(width: defaultScreenSize.width)

        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_pollOptionResultsView_withoutOptionIndex() {
        let poll = Poll.mock()
        let option = poll.options[0]

        let view = PollOptionResultsView(
            factory: DefaultViewFactory.shared,
            poll: poll,
            option: option,
            votes: Array(option.latestVotes.prefix(5)),
            hasMostVotes: false,
            allButtonShown: false
        )
        .frame(width: defaultScreenSize.width)

        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_pollOptionResultsView_withTrophy() {
        let poll = makePollWithClearWinner()
        let winnerOption = poll.options.max(by: {
            (poll.voteCountsByOption?[$0.id] ?? 0) < (poll.voteCountsByOption?[$1.id] ?? 0)
        })!

        let view = PollOptionResultsView(
            factory: DefaultViewFactory.shared,
            poll: poll,
            option: winnerOption,
            optionIndex: 1,
            votes: Array(winnerOption.latestVotes.prefix(5)),
            hasMostVotes: true,
            allButtonShown: false
        )
        .frame(width: defaultScreenSize.width)

        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_pollOptionResultsView_withViewAllButton() {
        let poll = makePollWithManyVotes()
        let option = poll.options[0]

        let view = PollOptionResultsView(
            factory: DefaultViewFactory.shared,
            poll: poll,
            option: option,
            optionIndex: 1,
            votes: Array(option.latestVotes.prefix(5)),
            hasMostVotes: false,
            allButtonShown: true
        )
        .frame(width: defaultScreenSize.width)

        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_pollOptionResultsView_zeroVotes() {
        let option = PollOption.mock(id: "empty", text: "No votes option", latestVotes: [])
        let poll = Poll.mock(options: [option])

        let view = PollOptionResultsView(
            factory: DefaultViewFactory.shared,
            poll: poll,
            option: option,
            optionIndex: 1,
            votes: [],
            hasMostVotes: false,
            allButtonShown: false
        )
        .frame(width: defaultScreenSize.width)

        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    // MARK: - Helpers

    private func makePollWithMultipleOptions() -> Poll {
        let pollId = "multi-options"
        let user1 = ChatUser.mock(id: "user1", name: "Alice")
        let user2 = ChatUser.mock(id: "user2", name: "Bob")
        let user3 = ChatUser.mock(id: "user3", name: "Charlie")

        // All vote timestamps are derived from the same anchor so the relative-date
        // buckets ("today", "yesterday", "Nd ago", "Nw ago") stay consistent across
        // the votes within a single test run.
        let now = Date()

        let option1Votes = [
            PollVote.mock(
                pollId: pollId,
                optionId: "opt1",
                user: user1,
                // 2 minutes ago
                createdAt: now.addingTimeInterval(-120)
            ),
            PollVote.mock(
                pollId: pollId,
                optionId: "opt1",
                user: user2,
                // 3 days ago
                createdAt: now.addingTimeInterval(-86400 * 3)
            ),
            PollVote.mock(
                pollId: pollId,
                optionId: "opt1",
                user: user3,
                // 10 days ago
                createdAt: now.addingTimeInterval(-86400 * 10)
            )
        ]
        let option2Votes = [
            PollVote.mock(
                pollId: pollId,
                optionId: "opt2",
                user: user2,
                // 01/01/70
                createdAt: Date(timeIntervalSince1970: 100)
            ),
            PollVote.mock(
                pollId: pollId,
                optionId: "opt2",
                user: user1,
                // yesterday
                createdAt: now.addingTimeInterval(-86400 * 1)
            )
        ]

        let options = [
            PollOption.mock(id: "opt1", text: "Amsterdam", latestVotes: option1Votes),
            PollOption.mock(id: "opt2", text: "Berlin", latestVotes: option2Votes)
        ]

        return Poll.mock(pollId: pollId, options: options)
    }

    private func makePollWithClearWinner() -> Poll {
        let pollId = "clear-winner"
        let users = (1...5).map { ChatUser.mock(id: "user\($0)", name: "User \($0)") }

        let winnerVotes = users.map {
            PollVote.mock(pollId: pollId, optionId: "winner", user: $0)
        }
        let loserVotes = [
            PollVote.mock(pollId: pollId, optionId: "loser", user: users[0])
        ]

        let options = [
            PollOption.mock(id: "winner", text: "Barcelona", latestVotes: winnerVotes),
            PollOption.mock(id: "loser", text: "Lisbon", latestVotes: loserVotes)
        ]

        return Poll.mock(pollId: pollId, options: options)
    }

    private func makePollWithManyVotes() -> Poll {
        let pollId = "many-votes"
        let votes = (1...8).map { i in
            PollVote.mock(pollId: pollId, optionId: "popular", user: .mock(id: "user\(i)", name: "User \(i)"))
        }

        let options = [
            PollOption.mock(id: "popular", text: "Barcelona", latestVotes: votes),
            PollOption.mock(id: "other", text: "Copenhagen", latestVotes: [])
        ]

        return Poll.mock(pollId: pollId, options: options)
    }

    private func makePollWithZeroVoteOption() -> Poll {
        let pollId = "zero-votes"
        let vote = PollVote.mock(pollId: pollId, optionId: "opt1", user: .mock(id: "user1", name: "Alice"))

        let options = [
            PollOption.mock(id: "opt1", text: "Amsterdam", latestVotes: [vote]),
            PollOption.mock(id: "opt2", text: "Copenhagen", latestVotes: [])
        ]

        return Poll.mock(pollId: pollId, options: options)
    }

    private func makePollAnonymous() -> Poll {
        let pollId = "anonymous"
        let votes = [
            PollVote.mock(pollId: pollId, optionId: "opt1", user: .mock(id: "user1", name: "Alice")),
            PollVote.mock(pollId: pollId, optionId: "opt1", user: .mock(id: "user2", name: "Bob"))
        ]

        let options = [
            PollOption.mock(id: "opt1", text: "Amsterdam", latestVotes: votes)
        ]

        return Poll(
            allowAnswers: false,
            allowUserSuggestedOptions: false,
            answersCount: 0,
            createdAt: Date(),
            pollDescription: "Anonymous poll",
            enforceUniqueVote: true,
            id: pollId,
            name: "Where should we go?",
            updatedAt: Date(),
            voteCount: 2,
            extraData: [:],
            voteCountsByOption: ["opt1": 2],
            isClosed: false,
            maxVotesAllowed: nil,
            votingVisibility: .anonymous,
            createdBy: .mock(id: "creator", name: "Creator"),
            latestAnswers: [],
            options: options,
            latestVotesByOption: options,
            latestVotes: [],
            ownVotes: []
        )
    }

    private func makePollWithSingleVote() -> Poll {
        let pollId = "single-vote"
        let vote = PollVote.mock(pollId: pollId, optionId: "opt1", user: .mock(id: "user1", name: "Alice"))

        let options = [
            PollOption.mock(id: "opt1", text: "Amsterdam", latestVotes: [vote]),
            PollOption.mock(id: "opt2", text: "Berlin", latestVotes: [])
        ]

        return Poll.mock(pollId: pollId, options: options)
    }
}
