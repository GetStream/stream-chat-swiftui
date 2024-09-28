//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import XCTest

final class PollAttachmentViewModel_Tests: StreamChatTestCase {
    
    func test_pollAttachmentViewModel_synchronizeCalled() {
        // Given
        let pollController = makePollController()
        
        // When
        _ = PollAttachmentViewModel(
            message: .mock(),
            poll: .unique,
            pollController: pollController
        )
        
        // Then
        XCTAssertTrue(pollController.synchronize_called)
    }
    
    func test_pollAttachmentViewModel_castPollVoteCalled() {
        // Given
        let pollController = makePollController()
        let viewModel = PollAttachmentViewModel(
            message: .mock(),
            poll: .unique,
            pollController: pollController
        )
        
        // When
        viewModel.castPollVote(for: .init(text: "test"))
        
        // Then
        XCTAssertTrue(pollController.castPollVote_called)
    }
    
    func test_pollAttachmentViewModel_addCommentCalled() {
        // Given
        let pollController = makePollController()
        let viewModel = PollAttachmentViewModel(
            message: .mock(),
            poll: .unique,
            pollController: pollController
        )
        
        // When
        viewModel.add(comment: "test")
        
        // Then
        XCTAssertTrue(pollController.castPollVote_called)
    }
    
    func test_pollAttachmentViewModel_removeVoteCalled() {
        // Given
        let vote = makePollVote()
        let pollController = makePollController()
        let viewModel = PollAttachmentViewModel(
            message: .mock(),
            poll: .mock(ownVotes: [vote]),
            pollController: pollController
        )
        
        // When
        viewModel.removePollVote(for: .init(id: vote.optionId!, text: ""))
        
        // Then
        XCTAssertTrue(pollController.removePollVote_called)
    }
    
    func test_pollAttachmentViewModel_endVoteCalled() {
        // Given
        let pollController = makePollController()
        let viewModel = PollAttachmentViewModel(
            message: .mock(),
            poll: .unique,
            pollController: pollController
        )
        
        // When
        viewModel.endVote()
        
        // Then
        XCTAssertTrue(pollController.closePoll_called)
    }
    
    func test_pollAttachmentViewModel_optionVotedByCurrentUser() {
        // Given
        let vote = makePollVote()
        let pollController = makePollController()
        let viewModel = PollAttachmentViewModel(
            message: .mock(),
            poll: .mock(ownVotes: [vote]),
            pollController: pollController
        )
        let option = PollOption(id: vote.optionId!, text: "")
        
        // When
        let optionVoted = viewModel.optionVotedByCurrentUser(option)
        
        // Then
        XCTAssertTrue(optionVoted)
    }
    
    func test_pollAttachmentViewModel_suggestPollOptionCalled() {
        // Given
        let pollController = makePollController()
        let viewModel = PollAttachmentViewModel(
            message: .mock(),
            poll: .unique,
            pollController: pollController
        )
        
        // When
        viewModel.suggest(option: "test option")
        
        // Then
        XCTAssertTrue(pollController.suggestPollOption_called)
    }
    
    func test_pollAttachmentViewModel_pollUpdated() {
        // Given
        let pollController = makePollController()
        let viewModel = PollAttachmentViewModel(
            message: .mock(),
            poll: .unique,
            pollController: pollController
        )
        
        // Then
        XCTAssertEqual(viewModel.poll.name, "Poll")
        
        // When
        let updated = Poll.mock(name: "Updated")
        pollController.delegate?.pollController(pollController, didUpdatePoll: .update(updated))
        
        // Then
        XCTAssertEqual(viewModel.poll.name, "Updated")
    }
    
    func test_pollAttachmentViewModel_votesUpdated() {
        // Given
        let pollController = makePollController()
        let viewModel = PollAttachmentViewModel(
            message: .mock(),
            poll: .unique,
            pollController: pollController
        )
        
        // Then
        XCTAssertEqual(viewModel.currentUserVotes, [])
        
        // When
        let vote = makePollVote()
        pollController.ownVotes_simulated = [vote]
        pollController.delegate?.pollController(
            pollController, didUpdateCurrentUserVotes: [.insert(vote, index: .init())]
        )
        
        // Then
        XCTAssertEqual(viewModel.currentUserVotes, [vote])
    }
    
    func test_pollAttachmentViewModel_winningVoteHasMostVotes() {
        // Given
        let poll = Poll.mock(optionCount: 3, voteCountForOption: { optionIndex in
            switch optionIndex {
            case 0: return 2
            case 1: return 3
            case 2: return 1
            default: return 0
            }
        })
        
        // When
        let viewModel = PollAttachmentViewModel(
            message: .mock(),
            poll: poll,
            pollController: makePollController()
        )
        
        // Then
        XCTAssertEqual(viewModel.hasMostVotes(for: poll.options[0]), false)
        XCTAssertEqual(viewModel.hasMostVotes(for: poll.options[1]), true)
        XCTAssertEqual(viewModel.hasMostVotes(for: poll.options[2]), false)
    }
    
    func test_pollAttachmentViewModel_noWinningVoteWhenEqualHighestVotes() {
        // Given
        let poll = Poll.mock(optionCount: 3, voteCountForOption: { optionIndex in
            switch optionIndex {
            case 0: return 2
            case 1: return 3
            case 2: return 3
            default: return 0
            }
        })
        
        // When
        let viewModel = PollAttachmentViewModel(
            message: .mock(),
            poll: poll,
            pollController: makePollController()
        )
        
        // Then
        XCTAssertEqual(false, viewModel.hasMostVotes(for: poll.options[0]))
        XCTAssertEqual(false, viewModel.hasMostVotes(for: poll.options[1]))
        XCTAssertEqual(false, viewModel.hasMostVotes(for: poll.options[2]))
    }
    
    func test_pollAttachmentViewModel_suggestOptionWithDuplicate() throws {
        // Given
        let poll = Poll.mock(optionCount: 3, voteCountForOption: { _ in 0 })
        let firstOptionText = try XCTUnwrap(poll.options.first?.text)
        
        // When
        let viewModel = PollAttachmentViewModel(
            message: .mock(),
            poll: poll,
            pollController: makePollController()
        )
        viewModel.suggest(option: firstOptionText)
        viewModel.suggest(option: firstOptionText + "   ")
        viewModel.suggest(option: "   " + firstOptionText + "   ")
        
        // Then
        XCTAssertEqual(3, viewModel.poll.options.count)
    }

    // MARK: - private
    
    private func makePollController() -> PollController_Mock {
        PollController_Mock(
            client: chatClient,
            messageId: .unique,
            pollId: .unique
        )
    }
    
    private func makePollVote() -> PollVote {
        PollVote(
            id: .unique,
            createdAt: .now,
            updatedAt: .now,
            pollId: .unique,
            optionId: .unique,
            isAnswer: false,
            answerText: nil,
            user: .unique
        )
    }
}
