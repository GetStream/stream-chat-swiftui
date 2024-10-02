//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import XCTest

final class PollCommentsViewModel_Tests: StreamChatTestCase {
    func test_pollCommentsViewModel_synchronizeCalled() {
        // Given
        let commentsController = makeCommentsController()
        
        // When
        _ = PollCommentsViewModel(
            pollController: makePollController(),
            commentsController: commentsController
        )
        
        // Then
        XCTAssertTrue(commentsController.synchronize_called)
    }
    
    func test_showsAddCommentButton_whenPollOpen_thenVisible() {
        // Given
        let pollController = makePollController()
        pollController.poll_simulated = .mock(isClosed: false)
        
        // When
        let viewModel = PollCommentsViewModel(
            pollController: pollController,
            commentsController: makeCommentsController()
        )
        
        // Then
        XCTAssertTrue(viewModel.showsAddCommentButton)
    }
    
    func test_showsAddCommentButton_whenPollClosed_thenHidden() {
        // Given
        let pollController = makePollController()
        pollController.poll_simulated = .mock(isClosed: true)
        
        // When
        let viewModel = PollCommentsViewModel(
            pollController: pollController,
            commentsController: makeCommentsController()
        )
        
        // Then
        XCTAssertFalse(viewModel.showsAddCommentButton)
    }
    
    func test_addComment_whenSuccess_thenCommentTextReset() {
        // Given
        let pollController = makePollController()
        
        // When
        let viewModel = PollCommentsViewModel(
            pollController: pollController,
            commentsController: makeCommentsController()
        )
        viewModel.newCommentText = "A"
        viewModel.add(comment: viewModel.newCommentText)
        
        // Then
        XCTAssertTrue(pollController.castPollVote_called)
        XCTAssertEqual("", viewModel.newCommentText)
    }
    
    // MARK: - Test Data
    
    private func makePollController() -> PollController_Mock {
        PollController_Mock(
            client: chatClient,
            messageId: .unique,
            pollId: .unique
        )
    }
    
    private func makeCommentsController() -> PollVoteListController_Mock {
        let query = PollVoteListQuery(
            pollId: .unique,
            filter: .equal(.isAnswer, to: true)
        )
        return PollVoteListController_Mock(query: query, client: chatClient)
    }
    
    private func makePollComment() -> PollVote {
        PollVote(
            id: .unique,
            createdAt: .now,
            updatedAt: .now,
            pollId: .unique,
            optionId: nil,
            isAnswer: true,
            answerText: .unique,
            user: .unique
        )
    }
}
