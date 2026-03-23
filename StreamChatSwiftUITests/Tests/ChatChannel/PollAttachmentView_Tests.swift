//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import SwiftUI
import XCTest

@MainActor final class PollAttachmentView_Tests: StreamChatTestCase {
    func test_pollAttachmentView_snapshotSixOptionsShowsFiveVisibleAndSeeMore() {
        let poll = Poll.mock(optionCount: 6, voteCountForOption: { _ in 0 })
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: .mock(id: .unique),
            poll: poll
        )

        let view = PollAttachmentView(
            factory: DefaultViewFactory.shared,
            message: message,
            poll: poll,
            isFirst: true
        )
        .frame(width: defaultScreenSize.width, height: 420)

        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_pollAttachmentView_snapshotCommentsAndSuggestions() {
        // Given
        let poll = Poll.mock()
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
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_pollAttachmentView_snapshotUniqueVotes() {
        // Given
        let poll = Poll.mock(
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
        .frame(width: defaultScreenSize.width, height: 180)

        // Then
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_pollAttachmentView_snapshotCreatedByCurrentUser() {
        // Given
        let currentUser = ChatUser.mock(id: StreamChatTestCase.currentUserId, name: "Me")
        let poll = Poll.mock(
            allowAnswers: false,
            allowUserSuggestedOptions: false,
            createdBy: currentUser
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
        .frame(width: defaultScreenSize.width, height: 220)

        // Then
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_pollAttachmentView_closedPoll() {
        // Given
        let poll = Poll.mock(
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
        .frame(width: defaultScreenSize.width, height: 170)

        // Then
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_pollAttachmentView_resultsSnapshot() {
        // Given
        let poll = Poll.mock()
        let viewModel = PollAttachmentViewModel(message: .mock(poll: poll), poll: poll)

        // When
        let view = PollResultsView(viewModel: viewModel, factory: DefaultViewFactory.shared)
            .applyDefaultSize()

        // Then
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_pollAttachmentView_allOptions() {
        // Given
        let poll = Poll.mock()
        let viewModel = PollAttachmentViewModel(message: .mock(poll: poll), poll: poll)

        // When
        let view = PollAllOptionsView(viewModel: viewModel, factory: DefaultViewFactory.shared)
            .applyDefaultSize()

        // Then
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_pollAttachmentView_allVotes() {
        // Given
        let pollId = "all-votes"
        let users = (1...4).map { ChatUser.mock(id: "user\($0)", name: "User \($0)") }
        let optionId = "opt1"
        let votes = users.map {
            PollVote.mock(pollId: pollId, optionId: optionId, user: $0)
        }
        let option = PollOption.mock(id: optionId, text: "Barcelona", latestVotes: votes)
        let poll = Poll.mock(pollId: pollId, options: [
            option,
            PollOption.mock(id: "opt2", text: "Lisbon", latestVotes: [])
        ])

        let viewModel = PollOptionAllVotesViewModel(poll: poll, option: option)
        viewModel.pollVotes = votes

        // When
        let view = PollOptionAllVotesView(factory: DefaultViewFactory.shared, viewModel: viewModel)
            .applyDefaultSize()

        // Then
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_pollAttachmentView_allComments() {
        // Given
        let poll = Poll.mock()
        let pollController = PollController(client: chatClient, messageId: .unique, pollId: poll.id)
        let viewModel = PollCommentsViewModel(poll: poll, pollController: pollController)
        viewModel.comments = [.mock(pollId: poll.id, optionId: nil, isAnswer: true, answerText: "Test comment")]

        // When
        let view = PollCommentsView(
            factory: DefaultViewFactory.shared,
            poll: poll,
            pollController: pollController,
            viewModel: viewModel
        )
        .applyDefaultSize()

        // Then
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }
}
