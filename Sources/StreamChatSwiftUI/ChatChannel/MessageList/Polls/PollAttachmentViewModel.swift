//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public class PollAttachmentViewModel: ObservableObject, PollControllerDelegate {
    
    private var isCastingVote = false
    private var isClosingPoll = false
    
    @Injected(\.chatClient) var chatClient
    
    let message: ChatMessage
    let pollController: PollController
    
    @Published public var poll: Poll
    
    @Published public var suggestOptionShown = false
    
    @Published public var addCommentShown = false
    
    @Published public var suggestOptionText = ""
    
    @Published public var commentText = ""
    
    @Published public var pollResultsShown = false {
        didSet {
            notifySheetPresentation(shown: pollResultsShown)
        }
    }
    
    @Published public var allCommentsShown = false {
        didSet {
            notifySheetPresentation(shown: allCommentsShown)
        }
    }
    
    @Published public var allOptionsShown = false {
        didSet {
            notifySheetPresentation(shown: allOptionsShown)
        }
    }
    
    @Published public var currentUserVotes = [PollVote]()
    
    private let createdByCurrentUser: Bool
        
    @Published public var endVoteConfirmationShown = false
    @Published public var errorShown = false

    /// If true, poll controls are in enabled state, otherwise disabled.
    public var canInteract: Bool {
        guard !isClosingPoll else { return false }
        guard !endVoteConfirmationShown else { return false }
        return true
    }
    
    public var showEndVoteButton: Bool {
        !poll.isClosed && createdByCurrentUser
    }
    
    public var showSuggestOptionButton: Bool {
        !poll.isClosed && poll.allowUserSuggestedOptions == true
    }
    
    public var showAddCommentButton: Bool {
        !poll.isClosed && poll.allowAnswers == true
    }
    
    /// If true, user avatars who have voted should be shown with the option, otherwise hidden.
    ///
    /// The default is to hide avatars when the poll is anonymous.
    public var showVoterAvatars: Bool {
        poll.votingVisibility != VotingVisibility.anonymous
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
        createdByCurrentUser = poll.createdBy?.id == InjectedValues[\.chatClient].currentUserId
        self.pollController = pollController
        pollController.delegate = self
        pollController.synchronize { [weak self] _ in
            guard let self else { return }
            self.currentUserVotes = Array(self.pollController.ownVotes)
        }
    }
    
    public func castPollVote(for option: PollOption) {
        guard !isCastingVote else { return }
        isCastingVote = true
        pollController.castPollVote(
            answerText: nil,
            optionId: option.id
        ) { [weak self] error in
            if let error {
                log.error("Error casting a vote \(error.localizedDescription)")
                if error is ClientError.PollVoteAlreadyExists {
                    log.debug("Vote already added")
                } else {
                    self?.errorShown = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self?.isCastingVote = false
            }
        }
    }
    
    public func add(comment: String) {
        pollController.castPollVote(
            answerText: comment,
            optionId: nil
        ) { [weak self] error in
            if let error {
                log.error("Error casting a vote \(error.localizedDescription)")
                self?.errorShown = true
            }
        }
        commentText = ""
    }
    
    public func removePollVote(for option: PollOption) {
        guard !isCastingVote else { return }
        isCastingVote = true
        guard let vote = currentUserVote(for: option) else { return }
        pollController.removePollVote(
            voteId: vote.id
        ) { [weak self] error in
            self?.isCastingVote = false
            if let error {
                log.error("Error removing a vote \(error.localizedDescription)")
                self?.errorShown = true
            }
        }
    }
    
    public func endVote() {
        guard !isClosingPoll else { return }
        isClosingPoll = true
        pollController.closePoll { [weak self] error in
            self?.isClosingPoll = false
            if let error {
                log.error("Error closing the poll \(error.localizedDescription)")
                self?.errorShown = true
            }
        }
    }
    
    public func optionVotedByCurrentUser(_ option: PollOption) -> Bool {
        currentUserVote(for: option) != nil
    }
    
    public func suggest(option: String) {
        suggestOptionText = ""
        let isDuplicate = poll.options.contains(where: { $0.text.trimmed.caseInsensitiveCompare(option.trimmed) == .orderedSame })
        guard !isDuplicate else { return }
        pollController.suggestPollOption(text: option) { [weak self] error in
            if let error {
                log.error("Error closing the poll \(error.localizedDescription)")
                self?.errorShown = true
            }
        }
    }
    
    /// Returns true if the specified option has more votes than any other option.
    ///
    /// - Note: When multiple options have the highest vote count, this function returns false.
    public func hasMostVotes(for option: PollOption) -> Bool {
        guard let allCounts = poll.voteCountsByOption else { return false }
        guard let optionVoteCount = allCounts[option.id], optionVoteCount > 0 else { return false }
        guard let highestVotePerOption = allCounts.values.max() else { return false }
        guard optionVoteCount == highestVotePerOption else { return false }
        // Check if only one option has highest number for votes
        let optionsByVoteCounts = Dictionary(grouping: allCounts, by: { $0.value })
        return optionsByVoteCounts[optionVoteCount]?.count == 1
    }
    
    // MARK: - PollControllerDelegate
    
    public func pollController(_ pollController: PollController, didUpdatePoll poll: EntityChange<Poll>) {
        self.poll = poll.item
    }
    
    public func pollController(
        _ pollController: PollController,
        didUpdateCurrentUserVotes votes: [ListChange<PollVote>]
    ) {
        currentUserVotes = Array(pollController.ownVotes)
    }
    
    // MARK: - private
    
    private func currentUserVote(for option: PollOption) -> PollVote? {
        currentUserVotes.first(where: { $0.optionId == option.id })
    }
    
    private func notifySheetPresentation(shown: Bool) {
        let notificationName: String = shown ? .sheetShownNotification : .sheetHiddenNotification
        NotificationCenter.default.post(
            name: NSNotification.Name(notificationName),
            object: nil
        )
    }
}

extension String {
    static let sheetShownNotification = "sheetShown"
    static let sheetHiddenNotification = "sheetHidden"
}
