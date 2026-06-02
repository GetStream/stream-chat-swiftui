//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import SwiftUI
import XCTest

@MainActor final class PollAllOptionsView_Tests: StreamChatTestCase {
    func test_pollAllOptionsView_defaultPoll() {
        let poll = Poll.mock()
        let viewModel = PollAttachmentViewModel(message: .mock(poll: poll), poll: poll)

        let view = PollAllOptionsView(viewModel: viewModel, factory: DefaultViewFactory.shared)
            .applyDefaultSize()

        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_pollAllOptionsView_multipleOptionsWithVotes() {
        let poll = makePollWithMultipleOptions()
        let viewModel = PollAttachmentViewModel(message: .mock(poll: poll), poll: poll)

        let view = PollAllOptionsView(viewModel: viewModel, factory: DefaultViewFactory.shared)
            .applyDefaultSize()

        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_pollAllOptionsView_closedPoll() {
        let poll = Poll.mock(isClosed: true)
        let viewModel = PollAttachmentViewModel(message: .mock(poll: poll), poll: poll)

        let view = PollAllOptionsView(viewModel: viewModel, factory: DefaultViewFactory.shared)
            .applyDefaultSize()

        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_pollAllOptionsView_manyOptions() {
        let poll = makePollWithManyOptions()
        let viewModel = PollAttachmentViewModel(message: .mock(poll: poll), poll: poll)

        let view = PollAllOptionsView(viewModel: viewModel, factory: DefaultViewFactory.shared)
            .applyDefaultSize()

        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_pollAllOptionsView_optionWithZeroVotes() {
        let poll = makePollWithZeroVoteOption()
        let viewModel = PollAttachmentViewModel(message: .mock(poll: poll), poll: poll)

        let view = PollAllOptionsView(viewModel: viewModel, factory: DefaultViewFactory.shared)
            .applyDefaultSize()

        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_pollAllOptionsView_uniqueVote() {
        let poll = Poll.mock(enforceUniqueVote: true)
        let viewModel = PollAttachmentViewModel(message: .mock(poll: poll), poll: poll)

        let view = PollAllOptionsView(viewModel: viewModel, factory: DefaultViewFactory.shared)
            .applyDefaultSize()

        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    // MARK: - RTL

    func test_pollAllOptionsView_rightToLeft_snapshot() {
        let poll = makePollWithMultipleOptionsRTL()
        let viewModel = PollAttachmentViewModel(message: .mock(poll: poll), poll: poll)

        let view = PollAllOptionsView(viewModel: viewModel, factory: DefaultViewFactory.shared)
            .applyDefaultSize()

        AssertSnapshot(view, variants: [.rightToLeftLayout])
    }

    func test_pollAllOptionsView_closedPoll_rightToLeft_snapshot() {
        let poll = Poll.mock(
            name: "Where do you go?",
            isClosed: true,
            options: [
                .mock(id: "opt1", text: "Barcelona", latestVotes: []),
                .mock(id: "opt2", text: "Lisbon", latestVotes: [])
            ]
        )
        let viewModel = PollAttachmentViewModel(message: .mock(poll: poll), poll: poll)

        let view = PollAllOptionsView(viewModel: viewModel, factory: DefaultViewFactory.shared)
            .applyDefaultSize()

        AssertSnapshot(view, variants: [.rightToLeftLayout])
    }

    // MARK: - Helpers

    private func makePollWithMultipleOptions() -> Poll {
        let pollId = "multi-options"
        let currentUser = ChatUser.mock(id: Self.currentUserId, name: "Current User")
        let user1 = ChatUser.mock(id: "user1", name: "Alice")
        let user2 = ChatUser.mock(id: "user2", name: "Bob")

        let currentUserVote = PollVote.mock(pollId: pollId, optionId: "opt1", user: currentUser)
        let option1Votes = [
            currentUserVote,
            PollVote.mock(pollId: pollId, optionId: "opt1", user: user1),
            PollVote.mock(pollId: pollId, optionId: "opt1", user: user2)
        ]
        let option2Votes = [
            PollVote.mock(pollId: pollId, optionId: "opt2", user: user2)
        ]
        let option3Votes = [
            PollVote.mock(pollId: pollId, optionId: "opt3", user: user1)
        ]

        let options = [
            PollOption.mock(id: "opt1", text: "Amsterdam", latestVotes: option1Votes),
            PollOption.mock(id: "opt2", text: "Berlin", latestVotes: option2Votes),
            PollOption.mock(id: "opt3", text: "Copenhagen", latestVotes: option3Votes)
        ]

        return Poll(
            allowAnswers: true,
            allowUserSuggestedOptions: true,
            answersCount: 0,
            createdAt: Date(),
            pollDescription: "Test",
            enforceUniqueVote: false,
            id: pollId,
            name: "Test poll",
            updatedAt: Date(),
            voteCount: 5,
            extraData: [:],
            voteCountsByOption: ["opt1": 3, "opt2": 1, "opt3": 1],
            isClosed: false,
            maxVotesAllowed: nil,
            votingVisibility: .public,
            createdBy: .mock(id: "creator", name: "Creator"),
            latestAnswers: [],
            options: options,
            latestVotesByOption: options,
            latestVotes: [],
            ownVotes: [currentUserVote]
        )
    }

    private func makePollWithManyOptions() -> Poll {
        let pollId = "many-options"
        let user1 = ChatUser.mock(id: "user1", name: "Alice")
        let user2 = ChatUser.mock(id: "user2", name: "Bob")

        let options = [
            PollOption.mock(
                id: "opt1",
                text: "Amsterdam",
                latestVotes: [PollVote.mock(pollId: pollId, optionId: "opt1", user: user1)]
            ),
            PollOption.mock(
                id: "opt2",
                text: "Berlin",
                latestVotes: [PollVote.mock(pollId: pollId, optionId: "opt2", user: user2)]
            ),
            PollOption.mock(id: "opt3", text: "Copenhagen", latestVotes: []),
            PollOption.mock(id: "opt4", text: "Dublin", latestVotes: []),
            PollOption.mock(
                id: "opt5",
                text: "Edinburgh",
                latestVotes: [
                    PollVote.mock(pollId: pollId, optionId: "opt5", user: user1),
                    PollVote.mock(pollId: pollId, optionId: "opt5", user: user2)
                ]
            ),
            PollOption.mock(id: "opt6", text: "Florence", latestVotes: [])
        ]

        return Poll.mock(pollId: pollId, options: options)
    }

    private func makePollWithZeroVoteOption() -> Poll {
        let pollId = "zero-votes"
        let vote = PollVote.mock(
            pollId: pollId,
            optionId: "opt1",
            user: .mock(id: "user1", name: "Alice")
        )

        let options = [
            PollOption.mock(id: "opt1", text: "Amsterdam", latestVotes: [vote]),
            PollOption.mock(id: "opt2", text: "Copenhagen", latestVotes: [])
        ]

        return Poll.mock(pollId: pollId, options: options)
    }

    private func makePollWithMultipleOptionsRTL() -> Poll {
        let pollId = "multi-options-rtl"
        let currentUser = ChatUser.mock(id: Self.currentUserId, name: "Current User")
        let user1 = ChatUser.mock(id: "user1", name: "Alice")
        let user2 = ChatUser.mock(id: "user2", name: "Bob")

        let currentUserVote = PollVote.mock(pollId: pollId, optionId: "opt1", user: currentUser)
        let option1Votes = [
            currentUserVote,
            PollVote.mock(pollId: pollId, optionId: "opt1", user: user1),
            PollVote.mock(pollId: pollId, optionId: "opt1", user: user2)
        ]
        let option2Votes = [
            PollVote.mock(pollId: pollId, optionId: "opt2", user: user2)
        ]
        let option3Votes = [
            PollVote.mock(pollId: pollId, optionId: "opt3", user: user1)
        ]

        let options = [
            PollOption.mock(id: "opt1", text: "Barcelona", latestVotes: option1Votes),
            PollOption.mock(id: "opt2", text: "Lisbon", latestVotes: option2Votes),
            PollOption.mock(id: "opt3", text: "Amsterdam", latestVotes: option3Votes)
        ]

        return Poll(
            allowAnswers: true,
            allowUserSuggestedOptions: true,
            answersCount: 0,
            createdAt: Date(),
            pollDescription: "Test",
            enforceUniqueVote: false,
            id: pollId,
            name: "Choose your favourite city",
            updatedAt: Date(),
            voteCount: 5,
            extraData: [:],
            voteCountsByOption: ["opt1": 3, "opt2": 1, "opt3": 1],
            isClosed: false,
            maxVotesAllowed: nil,
            votingVisibility: .public,
            createdBy: .mock(id: "creator", name: "Creator"),
            latestAnswers: [],
            options: options,
            latestVotesByOption: options,
            latestVotes: [],
            ownVotes: [currentUserVote]
        )
    }
}
