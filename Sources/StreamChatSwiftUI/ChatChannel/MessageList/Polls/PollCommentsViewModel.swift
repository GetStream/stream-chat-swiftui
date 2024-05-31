//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Combine
import StreamChat
import SwiftUI

class PollCommentsViewModel: ObservableObject, PollVoteListControllerDelegate {
    
    @Published var comments = [PollVote]()
    @Published var newCommentText = ""
    @Published var addCommentShown = false
    @Published var errorShown = false
    
    let pollController: PollController
    let commentsController: PollVoteListController
    
    private var cancellables = Set<AnyCancellable>()
    private(set) var animateChanges = false
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
        // No animation for initial load
        $comments
            .dropFirst()
            .map { _ in true }
            .assignWeakly(to: \.animateChanges, on: self)
            .store(in: &cancellables)
    }
    
    var showsAddCommentButton: Bool {
        pollController.poll?.isClosed == false
    }
    
    func add(comment: String) {
        pollController.castPollVote(answerText: comment, optionId: nil) { [weak self] error in
            if let error {
                log.error("Error casting a vote \(error.localizedDescription)")
                self?.errorShown = true
            }
        }
        newCommentText = ""
    }
    
    func controller(
        _ controller: PollVoteListController,
        didChangeVotes changes: [ListChange<PollVote>]
    ) {
        if animateChanges {
            withAnimation {
                self.comments = Array(self.commentsController.votes)
            }
        } else {
            comments = Array(commentsController.votes)
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
