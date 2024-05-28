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
        let pollController = makePollController()
        let viewModel = PollAttachmentViewModel(
            message: .mock(),
            poll: .unique,
            pollController: pollController
        )
        let vote = makePollVote()
        viewModel.currentUserVotes = [vote]
        
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
        let pollController = makePollController()
        let viewModel = PollAttachmentViewModel(
            message: .mock(),
            poll: .unique,
            pollController: pollController
        )
        let vote = makePollVote()
        let option = PollOption(id: vote.optionId!, text: "")
        viewModel.currentUserVotes = [vote]
        
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

    // MARK: - private
    
    private func makePollController() -> PollController_Mock {
        return PollController_Mock(
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
