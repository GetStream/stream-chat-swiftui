//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

class PollAttachmentViewModel: ObservableObject, PollControllerDelegate {
    
    @Injected(\.chatClient) var chatClient
    
    let message: ChatMessage
    let pollController: PollController
    
    @Published var poll: Poll
    
    @Published var suggestOptionShown = false
    
    @Published var addCommentShown = false
    
    @Published var suggestOptionText = ""
    
    @Published var commentText = ""
    
    @Published var pollResultsShown = false
    
    @Published var allCommentsShown = false
    
    @Published var allOptionsShown = false
    
    @Published var currentUserVotes = [PollVote]()
    
    private let createdByCurrentUser: Bool
        
    var showEndVoteButton: Bool {
        //TODO: check why createdBy is set to nil.
        !poll.isClosed && createdByCurrentUser
    }
    
    var showSuggestOptionButton: Bool {
        !poll.isClosed && poll.allowUserSuggestedOptions == true
    }
    
    var showAddCommentButton: Bool {
        !poll.isClosed && poll.allowAnswers == true
    }
    
    init(message: ChatMessage, poll: Poll) {
        self.message = message
        self.poll = poll
        self.createdByCurrentUser = poll.createdBy?.id == InjectedValues[\.chatClient].currentUserId
        self.pollController = InjectedValues[\.chatClient].pollController(
            messageId: message.id,
            pollId: poll.id
        )
        pollController.delegate = self
        pollController.synchronize { [weak self] error in
            guard let self else { return }
            self.currentUserVotes = Array(self.pollController.ownVotes)
        }
    }
    
    func castPollVote(for option: PollOption) {
        pollController.castPollVote(
            answerText: nil,
            optionId: option.id
        ) { error in
            if let error {
                log.error("Error casting a vote \(error.localizedDescription)")
            }
        }
    }
    
    func add(comment: String) {
        pollController.castPollVote(answerText: comment, optionId: nil) { [weak self] error in
            DispatchQueue.main.async {
                self?.commentText = ""                
            }
            if let error {
                log.error("Error casting a vote \(error.localizedDescription)")
            }
        }
    }
    
    func removePollVote(for option: PollOption) {
        guard let vote = currentUserVote(for: option) else { return }
        pollController.removePollVote(
            voteId: vote.id
        ) { error in
            if let error {
                log.error("Error removing a vote \(error.localizedDescription)")
            }
        }
    }
    
    func endVote() {
        pollController.closePoll { error in
            if let error {
                log.error("Error closing the poll \(error.localizedDescription)")
            }
        }
    }
    
    func optionVotedByCurrentUser(_ option: PollOption) -> Bool {
        return currentUserVote(for: option) != nil
    }
    
    func suggest(option: String) {
        pollController.suggestPollOption(text: option) { error in
            if let error {
                log.error("Error closing the poll \(error.localizedDescription)")
            }
        }
    }
    
    //MARK: - PollControllerDelegate
    
    func pollController(_ pollController: PollController, didUpdatePoll poll: EntityChange<Poll>) {
        self.poll = poll.item
    }
    
    func pollController(
        _ pollController: PollController,
        didUpdateCurrentUserVotes votes: [ListChange<PollVote>]
    ) {
        self.currentUserVotes = Array(pollController.ownVotes)
    }
    
    // MARK: - private
    
    private func currentUserVote(for option: PollOption) -> PollVote? {
        for current in currentUserVotes {
            if option.id == current.optionId {
                return current
            }
        }
        return nil
    }
}
