//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public class PollAttachmentViewModel: ObservableObject, PollControllerDelegate {
    
    @Injected(\.chatClient) var chatClient
    
    let message: ChatMessage
    let pollController: PollController
    
    @Published public var poll: Poll
    
    @Published public var suggestOptionShown = false
    
    @Published public var addCommentShown = false
    
    @Published public var suggestOptionText = ""
    
    @Published public var commentText = ""
    
    @Published public var pollResultsShown = false
    
    @Published public var allCommentsShown = false
    
    @Published public var allOptionsShown = false
    
    @Published public var currentUserVotes = [PollVote]()
    
    private let createdByCurrentUser: Bool
        
    public var showEndVoteButton: Bool {
        !poll.isClosed && createdByCurrentUser
    }
    
    public var showSuggestOptionButton: Bool {
        !poll.isClosed && poll.allowUserSuggestedOptions == true
    }
    
    public var showAddCommentButton: Bool {
        !poll.isClosed && poll.allowAnswers == true
    }
    
    public convenience init(message: ChatMessage, poll: Poll) {
        let pollController = InjectedValues[\.chatClient].pollController(
            messageId: message.id,
            pollId: poll.id
        )
        self.init(message: message, poll: poll, pollController: pollController)
    }
    
    init(message: ChatMessage, poll: Poll, pollController: PollController) {
        self.message = message
        self.poll = poll
        self.createdByCurrentUser = poll.createdBy?.id == InjectedValues[\.chatClient].currentUserId
        self.pollController = pollController
        pollController.delegate = self
        pollController.synchronize { [weak self] error in
            guard let self else { return }
            self.currentUserVotes = Array(self.pollController.ownVotes)
        }
    }
    
    public func castPollVote(for option: PollOption) {
        pollController.castPollVote(
            answerText: nil,
            optionId: option.id
        ) { error in
            if let error {
                log.error("Error casting a vote \(error.localizedDescription)")
            }
        }
    }
    
    public func add(comment: String) {
        pollController.castPollVote(answerText: comment, optionId: nil) { [weak self] error in
            DispatchQueue.main.async {
                self?.commentText = ""                
            }
            if let error {
                log.error("Error casting a vote \(error.localizedDescription)")
            }
        }
    }
    
    public func removePollVote(for option: PollOption) {
        guard let vote = currentUserVote(for: option) else { return }
        pollController.removePollVote(
            voteId: vote.id
        ) { error in
            if let error {
                log.error("Error removing a vote \(error.localizedDescription)")
            }
        }
    }
    
    public func endVote() {
        pollController.closePoll { error in
            if let error {
                log.error("Error closing the poll \(error.localizedDescription)")
            }
        }
    }
    
    public func optionVotedByCurrentUser(_ option: PollOption) -> Bool {
        return currentUserVote(for: option) != nil
    }
    
    public func suggest(option: String) {
        pollController.suggestPollOption(text: option) { error in
            if let error {
                log.error("Error closing the poll \(error.localizedDescription)")
            }
        }
    }
    
    //MARK: - PollControllerDelegate
    
    public func pollController(_ pollController: PollController, didUpdatePoll poll: EntityChange<Poll>) {
        self.poll = poll.item
    }
    
    public func pollController(
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
