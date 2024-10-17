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
        
    convenience init(poll: Poll, pollController: PollController) {
        let query = PollVoteListQuery(
            pollId: poll.id,
            filter: .equal(.isAnswer, to: true)
        )
        self.init(
            pollController: pollController,
            commentsController: InjectedValues[\.chatClient].pollVoteListController(query: query)
        )
    }
    
    init(
        pollController: PollController,
        commentsController: PollVoteListController
    ) {
        self.commentsController = commentsController
        self.pollController = pollController
        commentsController.delegate = self
        refresh()
        
        // No animation for initial load
        $comments
            .dropFirst()
            .map { _ in true }
            .assignWeakly(to: \.animateChanges, on: self)
            .store(in: &cancellables)
    }
    
    func refresh() {
        loadingComments = true
        commentsController.synchronize { [weak self] error in
            guard let self else { return }
            self.loadingComments = false
            self.comments = Array(self.commentsController.votes)
            if error != nil {
                self.errorShown = true
            }
        }
    }
    
    var showsAddCommentButton: Bool {
        pollController.poll?.isClosed == false
    }
    
    var currentUserAddedComment: Bool {
        !comments.filter { $0.user?.id == chatClient.currentUserId }.isEmpty
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
        commentsController.loadMoreVotes { [weak self] error in
            self?.loadingComments = false
            if error != nil {
                self?.errorShown = true
            }
        }
    }
}
