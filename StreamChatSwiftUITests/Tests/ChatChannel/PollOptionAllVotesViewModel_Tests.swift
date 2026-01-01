//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import XCTest

final class PollOptionAllVotesViewModel_Tests: StreamChatTestCase {
    func test_init_thenSynchronizeCalled() {
        // Given
        let poll = Poll.mock()
        let option = poll.options.first!
        let controller = makeVoteListController(poll: poll, option: option)
        
        // When
        _ = PollOptionAllVotesViewModel(
            poll: poll,
            option: option,
            controller: controller
        )
        
        // Then
        XCTAssertTrue(controller.synchronize_called)
    }
    
    func test_refresh_whenSuccess_thenUpdatesPollVotes() {
        // Given
        let poll = Poll.mock()
        let option = poll.options.first!
        let controller = makeVoteListController(poll: poll, option: option)
        controller.votes_simulated = LazyCachedMapCollection(source: [], map: { $0 })
        controller.synchronize_completion_result = .success(())
        let viewModel = PollOptionAllVotesViewModel(
            poll: poll,
            option: option,
            controller: controller
        )
        
        // When
        let votes = [
            PollVote.mock(pollId: poll.id, optionId: option.id),
            PollVote.mock(pollId: poll.id, optionId: option.id)
        ]
        controller.votes_simulated = LazyCachedMapCollection(source: votes, map: { $0 })
        viewModel.refresh()
        
        // Then
        XCTAssertEqual(viewModel.pollVotes.count, 2)
        XCTAssertEqual(viewModel.errorShown, false)
    }
    
    func test_refresh_whenError_thenShowsError() {
        // Given
        let poll = Poll.mock()
        let option = poll.options.first!
        let controller = makeVoteListController(poll: poll, option: option)
        controller.votes_simulated = LazyCachedMapCollection(source: [], map: { $0 })
        controller.synchronize_completion_result = .failure(ClientError("ERROR"))
        let viewModel = PollOptionAllVotesViewModel(
            poll: poll,
            option: option,
            controller: controller
        )
        
        // When
        viewModel.refresh()
        
        // Then
        XCTAssertEqual(viewModel.errorShown, true)
    }
    
    func test_onAppear_whenInsideThresholdAndMoreThan25Votes_thenLoadsMoreVotes() {
        // Given
        let poll = Poll.mock()
        let option = poll.options.first!
        let controller = makeVoteListController(poll: poll, option: option)
        let votes = makeVotes(count: 30, pollId: poll.id, optionId: option.id)
        controller.votes_simulated = LazyCachedMapCollection(source: votes, map: { $0 })
        controller.synchronize_completion_result = .success(())
        let viewModel = PollOptionAllVotesViewModel(
            poll: poll,
            option: option,
            controller: controller
        )

        // When - appear at index 21 (which is > 30 - 10 = 20)
        let voteAtIndex21 = viewModel.pollVotes[21]
        viewModel.onAppear(vote: voteAtIndex21)

        // Then
        XCTAssertTrue(viewModel.loadingVotes)
    }
    
    func test_onAppear_whenNotInThreshold_thenDoesNotLoadMoreVotes() {
        // Given
        let poll = Poll.mock()
        let option = poll.options.first!
        let controller = makeVoteListController(poll: poll, option: option)
        let votes = makeVotes(count: 30, pollId: poll.id, optionId: option.id)
        controller.votes_simulated = LazyCachedMapCollection(source: votes, map: { $0 })
        controller.synchronize_completion_result = .success(())
        let viewModel = PollOptionAllVotesViewModel(
            poll: poll,
            option: option,
            controller: controller
        )
        
        // When - appear at index 0 (which is not > 30 - 10 = 20)
        let voteAtIndex0 = viewModel.pollVotes[0]
        viewModel.onAppear(vote: voteAtIndex0)
        
        // Then
        XCTAssertFalse(viewModel.loadingVotes)
    }
    
    func test_onAppear_whenLessThan25Votes_thenDoesNotLoadMoreVotes() {
        // Given
        let poll = Poll.mock()
        let option = poll.options.first!
        let controller = makeVoteListController(poll: poll, option: option)
        let votes = makeVotes(count: 20, pollId: poll.id, optionId: option.id)
        controller.votes_simulated = LazyCachedMapCollection(source: votes, map: { $0 })
        controller.synchronize_completion_result = .success(())
        let viewModel = PollOptionAllVotesViewModel(
            poll: poll,
            option: option,
            controller: controller
        )
        
        // When - appear at last vote (index 19, which is > 20 - 10 = 10)
        let lastVote = viewModel.pollVotes[19]
        viewModel.onAppear(vote: lastVote)
        
        // Then
        XCTAssertFalse(viewModel.loadingVotes)
    }
    
    func test_onAppear_whenVoteNotFound_thenDoesNotLoadMoreVotes() {
        // Given
        let poll = Poll.mock()
        let option = poll.options.first!
        let controller = makeVoteListController(poll: poll, option: option)
        let votes = makeVotes(count: 30, pollId: poll.id, optionId: option.id)
        controller.votes_simulated = LazyCachedMapCollection(source: votes, map: { $0 })
        controller.synchronize_completion_result = .success(())
        let viewModel = PollOptionAllVotesViewModel(
            poll: poll,
            option: option,
            controller: controller
        )
        
        // When - appear with vote not in list
        let otherVote = PollVote.mock(pollId: poll.id, optionId: "other_option")
        viewModel.onAppear(vote: otherVote)
        
        // Then
        XCTAssertFalse(viewModel.loadingVotes)
    }
    
    func test_loadMoreVotes_whenSuccess_thenUpdatesPollVotes() {
        // Given
        let poll = Poll.mock()
        let option = poll.options.first!
        let controller = makeVoteListController(poll: poll, option: option)
        let initialVotes = makeVotes(count: 30, pollId: poll.id, optionId: option.id)
        controller.votes_simulated = LazyCachedMapCollection(source: initialVotes, map: { $0 })
        controller.synchronize_completion_result = .success(())
        controller.loadMoreVotes_completion_result = .success(())
        let viewModel = PollOptionAllVotesViewModel(
            poll: poll,
            option: option,
            controller: controller
        )
        
        // When
        let voteAtIndex21 = viewModel.pollVotes[21]
        viewModel.onAppear(vote: voteAtIndex21)
        let additionalVotes = makeVotes(count: 10, pollId: poll.id, optionId: option.id)
        let allVotes = initialVotes + additionalVotes
        controller.votes_simulated = LazyCachedMapCollection(source: allVotes, map: { $0 })
        // Trigger the delegate method to update the view model
        viewModel.controller(controller, didChangeVotes: [])
        
        // Then
        XCTAssertEqual(viewModel.pollVotes.count, 40)
        XCTAssertEqual(viewModel.errorShown, false)
    }
    
    func test_loadMoreVotes_whenError_thenShowsError() {
        // Given
        let poll = Poll.mock()
        let option = poll.options.first!
        let controller = makeVoteListController(poll: poll, option: option)
        let votes = makeVotes(count: 30, pollId: poll.id, optionId: option.id)
        controller.votes_simulated = LazyCachedMapCollection(source: votes, map: { $0 })
        controller.synchronize_completion_result = .success(())
        controller.loadMoreVotes_completion_result = .failure(ClientError("ERROR"))
        let viewModel = PollOptionAllVotesViewModel(
            poll: poll,
            option: option,
            controller: controller
        )

        // When
        let voteAtIndex21 = viewModel.pollVotes[21]
        viewModel.onAppear(vote: voteAtIndex21)

        // Then
        XCTAssertEqual(viewModel.errorShown, true)
    }

    func test_controllerDidUpdatePoll_thenUpdatesPoll() {
        // Given
        let poll = Poll.mock(name: "Original")
        let option = poll.options.first!
        let controller = makeVoteListController(poll: poll, option: option)
        let viewModel = PollOptionAllVotesViewModel(
            poll: poll,
            option: option,
            controller: controller
        )
        
        // When
        let updatedPoll = Poll.mock(name: "Updated")
        viewModel.controller(controller, didUpdatePoll: updatedPoll)
        
        // Then
        XCTAssertEqual(viewModel.poll.name, "Updated")
    }
    
    // MARK: - Test Data
    
    private func makeVoteListController(poll: Poll, option: PollOption) -> PollVoteListController_Mock {
        let query = PollVoteListQuery(
            pollId: poll.id,
            optionId: option.id,
            pagination: .init(pageSize: 25)
        )
        return PollVoteListController_Mock(query: query, client: chatClient)
    }
    
    private func makeVotes(count: Int, pollId: String, optionId: String) -> [PollVote] {
        (0..<count).map { index in
            PollVote.mock(
                id: "vote_\(index)",
                pollId: pollId,
                optionId: optionId
            )
        }
    }
}
