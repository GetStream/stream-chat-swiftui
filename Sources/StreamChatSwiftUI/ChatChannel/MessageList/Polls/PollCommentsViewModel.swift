//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

class PollCommentsViewModel: ObservableObject, PollVoteListControllerDelegate {
    
    @Published var comments = [PollVote]()
    @Published var newCommentText = ""
    @Published var addCommentShown = false
    
    let pollController: PollController
    let commentsController: PollVoteListController
    
    private var loadingComments = false
        
    init(poll: Poll, pollController: PollController) {
        self.pollController = pollController
        let query = PollVoteListQuery(
            pollId: poll.id,
            optionId: nil,
            filter: .equal(.pollId, to: poll.id)
        )
        commentsController = InjectedValues[\.chatClient].pollVoteListController(query: query)
        commentsController.delegate = self
        commentsController.synchronize { [weak self] _ in
            guard let self else { return }
            self.comments = Array(self.commentsController.votes)
            if self.comments.isEmpty {
                self.loadComments()
            }
        }
    }
    
    func add(comment: String) {
        pollController.castPollVote(answerText: comment, optionId: nil) { [weak self] error in
            DispatchQueue.main.async {
                self?.newCommentText = ""
            }
        }
    }
    
    func controller(
        _ controller: PollVoteListController,
        didChangeVotes changes: [ListChange<PollVote>]
    ) {
        withAnimation {
            self.comments = Array(self.commentsController.votes)
        }
    }
    
    private func loadComments() {
        loadingComments = true

        commentsController.loadMoreVotes { [weak self] _ in
            guard let self else { return }
            self.loadingComments = false
        }
    }
}
