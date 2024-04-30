//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

class PollAttachmentViewModel: ObservableObject, PollControllerDelegate, PollVoteListControllerDelegate {
    
    @Published var votesForOption = [String: [PollVote]]()
    func controller(
        _ controller: PollVoteListController,
        didChangeVotes changes: [ListChange<PollVote>]
    ) {
        let optionId = controller.query.optionId
        votesForOption[optionId] = Array(controller.votes)
    }
    
        
    @Injected(\.chatClient) var chatClient
    
    let message: ChatMessage
    let pollController: PollController
    
    @Published var poll: Poll
    
    @Published var suggestOptionShown = false
    
    @Published var suggestOptionText = ""
    
    @Published var pollResultsShown = false
    
    private let createdByCurrentUser: Bool
    
    private let dateFormatter = DateFormatter.makeDefault()
    
    var showEndVoteButton: Bool {
        //TODO: check why createdBy is set to nil.
        !poll.isClosed && createdByCurrentUser
    }
    
    var showSuggestOptionButton: Bool {
        !poll.isClosed && poll.allowUserSuggestedOptions == true
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
    
    func dateString(from date: Date) -> String {
        dateFormatter.string(from: date)
    }
    
    var controller: PollVoteListController?
    
    func loadMoreVotes(for option: PollOption) {
        if controller == nil {
            controller = chatClient.pollVoteListController(
                query: .init(pollId: poll.id, optionId: option.id, filter: .equal(.optionId, to: option.id))
            )
            controller?.delegate = self
        }
        controller?.loadMoreVotes()
    }
    
    //MARK: - PollControllerDelegate
    
    func pollController(_ pollController: PollController, didUpdatePoll poll: EntityChange<Poll>) {
        self.poll = poll.item
    }
    
    func pollController(
        _ pollController: PollController,
        didUpdateOptions options: EntityChange<[PollOption]>
    ) {
        print("======= options changed \(options.item.count)")
        self.poll.options = options.item
    }
    
    // MARK: - private
    
    private func currentUserVote(for option: PollOption) -> PollVote? {
        //TODO: query all votes.
        for current in poll.latestVotesByOption {
            if option.id == current.id {
                for vote in current.latestVotes {
                    if vote.user?.id == chatClient.currentUserId {
                        return vote
                    }
                }
            }
        }
        return nil
    }
}
