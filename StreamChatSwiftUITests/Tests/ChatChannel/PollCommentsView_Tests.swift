//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import SwiftUI
import XCTest

@MainActor final class PollCommentsView_Tests: StreamChatTestCase {
    func test_pollAddCommentAlertLocalization() {
        XCTAssertEqual(L10n.Alert.TextField.pollAddComment, "Your comment")
        XCTAssertEqual(L10n.Alert.Title.addComment, "Add a Comment")
    }

    // MARK: - PollCommentsView

    func test_pollCommentsView_multipleComments() {
        let (viewModel, poll, pollController) = makeViewModel(
            comments: makeMultipleComments(pollId: "multi")
        )

        let view = PollCommentsView(
            factory: DefaultViewFactory.shared,
            poll: poll,
            pollController: pollController,
            viewModel: viewModel
        )
        .applyDefaultSize()

        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_pollCommentsView_singleComment() {
        let comment = makeComment(
            pollId: "single",
            text: "I think we should meet at the central plaza.",
            user: .mock(id: "user1", name: "Alice")
        )

        let (viewModel, poll, pollController) = makeViewModel(
            pollId: "single",
            comments: [comment]
        )

        let view = PollCommentsView(
            factory: DefaultViewFactory.shared,
            poll: poll,
            pollController: pollController,
            viewModel: viewModel
        )
        .applyDefaultSize()

        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_pollCommentsView_ownCommentWithUpdateButton() {
        let currentUserId = StreamChatTestCase.currentUserId
        let ownComment = makeComment(
            pollId: "own",
            text: "My suggestion is to go with the first option.",
            user: .mock(id: currentUserId, name: "You")
        )
        let otherComment = makeComment(
            pollId: "own",
            text: "I prefer the second option personally.",
            user: .mock(id: "user2", name: "Bob"),
            timeOffset: -3600
        )

        let (viewModel, poll, pollController) = makeViewModel(
            pollId: "own",
            setPollOnController: true,
            comments: [ownComment, otherComment]
        )

        let view = PollCommentsView(
            factory: DefaultViewFactory.shared,
            poll: poll,
            pollController: pollController,
            viewModel: viewModel
        )
        .applyDefaultSize()

        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_pollCommentsView_anonymousVoting() {
        let comments = [
            makeComment(
                pollId: "anon",
                text: "This is my anonymous feedback.",
                user: .mock(id: "user1", name: "Alice")
            ),
            makeComment(
                pollId: "anon",
                text: "Another anonymous comment here.",
                user: .mock(id: "user2", name: "Bob"),
                timeOffset: -7200
            )
        ]

        let (viewModel, poll, pollController) = makeViewModel(
            pollId: "anon",
            isClosed: true,
            votingVisibility: .anonymous,
            setPollOnController: true,
            comments: comments
        )

        let view = PollCommentsView(
            factory: DefaultViewFactory.shared,
            poll: poll,
            pollController: pollController,
            viewModel: viewModel
        )
        .applyDefaultSize()

        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_pollCommentsView_closedPoll() {
        let comments = makeMultipleComments(pollId: "closed")

        let (viewModel, poll, pollController) = makeViewModel(
            pollId: "closed",
            isClosed: true,
            setPollOnController: true,
            comments: comments
        )

        let view = PollCommentsView(
            factory: DefaultViewFactory.shared,
            poll: poll,
            pollController: pollController,
            viewModel: viewModel
        )
        .applyDefaultSize()

        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_pollCommentsView_ownCommentAnonymous() {
        let currentUserId = StreamChatTestCase.currentUserId
        let ownComment = makeComment(
            pollId: "anon-own",
            text: "My anonymous comment on this poll.",
            user: .mock(id: currentUserId, name: "You")
        )

        let (viewModel, poll, pollController) = makeViewModel(
            pollId: "anon-own",
            votingVisibility: .anonymous,
            setPollOnController: true,
            comments: [ownComment]
        )

        let view = PollCommentsView(
            factory: DefaultViewFactory.shared,
            poll: poll,
            pollController: pollController,
            viewModel: viewModel
        )
        .applyDefaultSize()

        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_pollCommentsView_longComment() {
        let comment = makeComment(
            pollId: "long",
            text: "This is a very long comment that spans multiple lines to test how the layout handles text wrapping. It should display properly without any truncation and maintain proper padding on all sides of the card.",
            user: .mock(id: "user1", name: "Alice")
        )

        let (viewModel, poll, pollController) = makeViewModel(
            pollId: "long",
            comments: [comment]
        )

        let view = PollCommentsView(
            factory: DefaultViewFactory.shared,
            poll: poll,
            pollController: pollController,
            viewModel: viewModel
        )
        .applyDefaultSize()

        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_pollCommentsView_addCommentButtonVisible() {
        let comments = [
            makeComment(
                pollId: "add-btn",
                text: "I think option A is the best.",
                user: .mock(id: "user1", name: "Alice")
            ),
            makeComment(
                pollId: "add-btn",
                text: "I prefer option B instead.",
                user: .mock(id: "user2", name: "Bob"),
                timeOffset: -3600
            )
        ]

        let (viewModel, poll, pollController) = makeViewModel(
            pollId: "add-btn",
            setPollOnController: true,
            comments: comments
        )

        let view = PollCommentsView(
            factory: DefaultTestViewFactory.shared,
            poll: poll,
            pollController: pollController,
            viewModel: viewModel
        )
        .applyDefaultSize()

        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    // MARK: - RTL

    func test_pollCommentsView_rightToLeft_snapshot() {
        let (viewModel, poll, pollController) = makeViewModel(
            comments: makeMultipleComments(pollId: "rtl-multi")
        )

        let view = PollCommentsView(
            factory: DefaultViewFactory.shared,
            poll: poll,
            pollController: pollController,
            viewModel: viewModel
        )
        .applyDefaultSize()

        AssertSnapshot(view, variants: [.rightToLeftLayout])
    }

    func test_pollCommentsView_ownCommentWithUpdateButton_rightToLeft_snapshot() {
        let currentUserId = StreamChatTestCase.currentUserId
        let ownComment = makeComment(
            pollId: "rtl-own",
            text: "My suggestion is to go with the first option.",
            user: .mock(id: currentUserId, name: "You")
        )
        let otherComment = makeComment(
            pollId: "rtl-own",
            text: "I prefer the second option personally.",
            user: .mock(id: "user2", name: "Bob"),
            timeOffset: -3600
        )

        let (viewModel, poll, pollController) = makeViewModel(
            pollId: "rtl-own",
            setPollOnController: true,
            comments: [ownComment, otherComment]
        )

        let view = PollCommentsView(
            factory: DefaultViewFactory.shared,
            poll: poll,
            pollController: pollController,
            viewModel: viewModel
        )
        .applyDefaultSize()

        AssertSnapshot(view, variants: [.rightToLeftLayout])
    }

    // MARK: - Helpers

    private let referenceDate = Date(timeIntervalSince1970: 1_700_000_000)

    private func makeComment(
        pollId: String,
        text: String,
        user: ChatUser,
        timeOffset: TimeInterval = 0
    ) -> PollVote {
        PollVote.mock(
            createdAt: referenceDate.addingTimeInterval(timeOffset),
            pollId: pollId,
            optionId: nil,
            isAnswer: true,
            answerText: text,
            user: user
        )
    }

    /// - Parameter setPollOnController: When `true`, the mock poll is assigned to
    ///   `pollController.poll_simulated` so the view model can evaluate
    ///   `showsAddCommentButton`, `votingVisibility`, etc. When `false` (default),
    ///   the controller returns `nil` for `poll`, which avoids the iOS 26 Liquid
    ///   Glass toolbar button that breaks snapshot rendering.
    private func makeViewModel(
        pollId: String = .unique,
        isClosed: Bool = false,
        votingVisibility: VotingVisibility? = nil,
        setPollOnController: Bool = false,
        comments: [PollVote]
    ) -> (PollCommentsViewModel, Poll, PollController_Mock) {
        let poll = Poll(
            allowAnswers: true,
            allowUserSuggestedOptions: false,
            answersCount: comments.count,
            createdAt: referenceDate,
            pollDescription: "Test poll",
            enforceUniqueVote: false,
            id: pollId,
            name: "Test poll",
            updatedAt: referenceDate,
            voteCount: 0,
            extraData: [:],
            voteCountsByOption: nil,
            isClosed: isClosed,
            maxVotesAllowed: nil,
            votingVisibility: votingVisibility,
            createdBy: .mock(id: "creator", name: "Creator"),
            latestAnswers: comments,
            options: [],
            latestVotesByOption: [],
            latestVotes: [],
            ownVotes: []
        )

        let pollController = PollController_Mock(
            client: chatClient,
            messageId: .unique,
            pollId: pollId
        )
        if setPollOnController {
            pollController.poll_simulated = poll
        }

        let query = PollVoteListQuery(
            pollId: pollId,
            filter: .equal(.isAnswer, to: true)
        )
        let commentsController = PollVoteListController_Mock(
            query: query,
            client: chatClient
        )

        let viewModel = PollCommentsViewModel(
            pollController: pollController,
            commentsController: commentsController
        )
        viewModel.comments = comments

        return (viewModel, poll, pollController)
    }

    private func makeMultipleComments(pollId: String) -> [PollVote] {
        [
            makeComment(
                pollId: pollId,
                text: "I think we should go with option A.",
                user: .mock(id: "user1", name: "Alice")
            ),
            makeComment(
                pollId: pollId,
                text: "Option B seems like the better choice for everyone.",
                user: .mock(id: "user2", name: "Bob"),
                timeOffset: -3600
            ),
            makeComment(
                pollId: pollId,
                text: "I agree with Alice.",
                user: .mock(id: "user3", name: "Charlie"),
                timeOffset: -86400
            )
        ]
    }
}
