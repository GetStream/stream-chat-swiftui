//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Combine
import StreamChat
import SwiftUI

class PollCommentsViewModel: ObservableObject, PollVoteListControllerDelegate {
    
    @Injected(\.chatClient) var chatClient
    
    @Published var comments = [PollVote]()
    @Published var newCommentText = ""
    @Published var addCommentShown = false
    @Published var errorShown = false
    
    let pollController: PollController
    let commentsController: PollVoteListController
    
    private var cancellables = Set<AnyCancellable>()
    private(set) var animateChanges = false
    private var loadingComments = true
        
    init(poll: Poll, pollController: PollController) {
        self.pollController = pollController
        let query = PollVoteListQuery(
            pollId: poll.id,
            optionId: nil,
            filter: .and(
                [.equal(.pollId, to: poll.id), .equal(.isAnswer, to: true)]
            )
        )
        commentsController = InjectedValues[\.chatClient].pollVoteListController(query: query)
        commentsController.delegate = self
        commentsController.synchronize { [weak self] _ in
            guard let self else { return }
            self.loadingComments = false
            self.comments = Array(self.commentsController.votes)
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
    
    var currentUserAddedComment: Bool {
        comments.filter { $0.user?.id == chatClient.currentUserId }.count > 0
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
    
    func onAppear(comment: PollVote) {
        guard !loadingComments,
              let index = comments.firstIndex(where: { $0 == comment }),
              index > comments.count - 10 else { return }
        
        loadComments()
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
        guard !loadingComments, !commentsController.hasLoadedAllVotes else { return }
        loadingComments = true
        commentsController.loadMoreVotes { [weak self] _ in
            self?.loadingComments = false
        }
    }
}
