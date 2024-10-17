//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View model for the `PollAttachmentView`.
public class PollAttachmentViewModel: ObservableObject, PollControllerDelegate {
    
    static let numberOfVisibleOptionsShown = 10
    private var isCastingVote = false
    @Published private var isClosingPoll = false
    
    @Injected(\.chatClient) var chatClient
    
    let message: ChatMessage
    let pollController: PollController
    
    /// The object representing the state of the poll.
    @Published public var poll: Poll
    
    /// If true, an alert with a text field is shown allowing to suggest new options.
    @Published public var suggestOptionShown = false
    
    /// If true, an alert with a text field is shown allowing to send a comment.
    @Published public var addCommentShown = false
    
    /// Suggested option title written by an user using an alert.
    @Published public var suggestOptionText = ""
    
    /// Comment text written by an user using an alert.
    @Published public var commentText = ""
    
    /// If true, a sheet is shown revealing poll results.
    @Published public var pollResultsShown = false {
        didSet {
            notifySheetPresentation(shown: pollResultsShown)
        }
    }
    
    /// It true, a sheet is shown with all the poll comments.
    @Published public var allCommentsShown = false {
        didSet {
            notifySheetPresentation(shown: allCommentsShown)
        }
    }
    
    /// If true, a sheet is shown with all the poll options.
    ///
    /// Used for polls with more than 10 options.
    @Published public var allOptionsShown = false {
        didSet {
            notifySheetPresentation(shown: allOptionsShown)
        }
    }
    
    /// A list of votes given by the current user.
    @Published public var currentUserVotes = [PollVote]()
    
    private let createdByCurrentUser: Bool
        
    /// If true, an action sheet is shown for closing the poll, otherwise hidden.
    @Published public var endVoteConfirmationShown = false
    
    @available(*, deprecated, message: "Replaced with inline alert banners displayed by the showChannelAlertBannerNotification")
    @Published public var errorShown = false

    /// If true, poll controls are in enabled state, otherwise disabled.
    public var canInteract: Bool {
        guard !isClosingPoll else { return false }
        guard !endVoteConfirmationShown else { return false }
        return true
    }
    
    /// If true, end vote button is visible under votes, otherwise hidden.
    public var showEndVoteButton: Bool {
        !poll.isClosed && createdByCurrentUser
    }
    
    /// If true, suggest new option button is visible under votes allowing users to add more poll options, otherwise hidden.
    public var showSuggestOptionButton: Bool {
        !poll.isClosed && poll.allowUserSuggestedOptions == true
    }
    
    /// If true, add comment button is visible under votes, otherwise hidden.
    public var showAddCommentButton: Bool {
        let addCommentAvailable = !poll.isClosed && poll.allowAnswers
        if poll.votingVisibility == .anonymous {
            return addCommentAvailable
        }
        return addCommentAvailable
            && (
                poll.latestAnswers.filter {
                    $0.user?.id == chatClient.currentUserId && $0.isAnswer
                }
            )
            .isEmpty
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
    
    /// Casts a vote for a poll.
    ///
    /// - Parameter option: The option user tapped on.
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
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self?.isCastingVote = false
            }
        }
    }
    
    /// Adds a comment to the poll.
    ///
    /// Each poll participant can add a single comment. If a comment exists from the current user, the comment is editted.
    ///
    /// - Parameter comment: A comment added to the poll.
    public func add(comment: String) {
        pollController.castPollVote(
            answerText: comment,
            optionId: nil
        ) { error in
            if let error {
                log.error("Error casting a vote \(error.localizedDescription)")
                NotificationCenter.default.post(name: .showChannelAlertBannerNotification, object: nil)
            }
        }
        commentText = ""
    }
    
    /// Removes the given vote from the specified option.
    /// - Parameter option: The option user tapped on.
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
            }
        }
    }
    
    /// Closes the poll.
    ///
    /// Closed poll can't be updated in any way.
    public func endVote() {
        guard !isClosingPoll else { return }
        isClosingPoll = true
        pollController.closePoll { [weak self] error in
            self?.isClosingPoll = false
            if let error {
                log.error("Error closing the poll \(error.localizedDescription)")
                NotificationCenter.default.post(name: .showChannelAlertBannerNotification, object: nil)
            }
        }
    }
    
    /// True, if the current user has voted for the specified option, otherwise false.
    public func optionVotedByCurrentUser(_ option: PollOption) -> Bool {
        poll.hasCurrentUserVoted(for: option)
    }
    
    /// Adds a new option to the poll.
    /// - Parameter option: The suggested option.
    public func suggest(option: String) {
        suggestOptionText = ""
        let isDuplicate = poll.options.contains(where: { $0.text.trimmed.caseInsensitiveCompare(option.trimmed) == .orderedSame })
        guard !isDuplicate else { return }
        pollController.suggestPollOption(text: option) { error in
            if let error {
                log.error("Error closing the poll \(error.localizedDescription)")
                NotificationCenter.default.post(name: .showChannelAlertBannerNotification, object: nil)
            }
        }
    }
    
    /// Returns true if the specified option has more votes than any other option.
    ///
    /// - Note: When multiple options have the highest vote count, this function returns false.
    public func hasMostVotes(for option: PollOption) -> Bool {
        poll.isOptionWithMostVotes(option)
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
        poll.currentUserVote(for: option)
    }
    
    private func notifySheetPresentation(shown: Bool) {
        let name: Notification.Name = shown ? .messageSheetShownNotification : .messageSheetHiddenNotification
        NotificationCenter.default.post(
            name: name,
            object: nil
        )
    }
}
