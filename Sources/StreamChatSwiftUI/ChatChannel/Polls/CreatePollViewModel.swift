//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Combine
import Foundation
import StreamChat
import SwiftUI

class CreatePollViewModel: ObservableObject {
    
    @Injected(\.utils) var utils
    
    @Published var question = ""
    
    @Published var options: [String] = [""]
    @Published var optionsErrorIndices = Set<Int>()
        
    @Published var suggestAnOption: Bool
    
    @Published var anonymousPoll: Bool
    
    @Published var multipleAnswers: Bool
    
    @Published var maxVotesEnabled: Bool
    
    @Published var maxVotes: String = ""
    @Published var showsMaxVotesError = false
    
    @Published var allowComments: Bool
    
    @Published var discardConfirmationShown = false
    
    @Published var errorShown = false
    
    let chatController: ChatChannelController
    var messageController: ChatMessageController?
    
    private var cancellables = [AnyCancellable]()
    
    var pollsConfig: PollsConfig {
        utils.pollsConfig
    }
    
    var multipleAnswersShown: Bool {
        utils.pollsConfig.multipleAnswers.configurable
    }
    
    var anonymousPollShown: Bool {
        utils.pollsConfig.anonymousPoll.configurable
    }
    
    var suggestAnOptionShown: Bool {
        utils.pollsConfig.suggestAnOption.configurable
    }
    
    var addCommentsShown: Bool {
        utils.pollsConfig.addComments.configurable
    }
    
    var maxVotesShown: Bool {
        utils.pollsConfig.maxVotesPerPerson.configurable
    }
    
    init(chatController: ChatChannelController, messageController: ChatMessageController?) {
        let pollsConfig = InjectedValues[\.utils].pollsConfig
        self.chatController = chatController
        self.messageController = messageController
        
        suggestAnOption = pollsConfig.suggestAnOption.defaultValue
        anonymousPoll = pollsConfig.anonymousPoll.defaultValue
        multipleAnswers = pollsConfig.multipleAnswers.defaultValue
        allowComments = pollsConfig.addComments.defaultValue
        maxVotesEnabled = pollsConfig.maxVotesPerPerson.defaultValue
        
        $maxVotes
            .map { text in
                guard !text.isEmpty else { return false }
                let intValue = Int(text) ?? 0
                return intValue < 1 || intValue > 10
            }
            .combineLatest($maxVotesEnabled)
            .map { $0 && $1 }
            .removeDuplicates()
            .assignWeakly(to: \.showsMaxVotesError, on: self)
            .store(in: &cancellables)
        $options
            .map { options in
                var errorIndices = Set<Int>()
                var existing = Set<String>(minimumCapacity: options.count)
                for (index, option) in options.enumerated() {
                    let validated = option.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                    if existing.contains(validated), !validated.isEmpty {
                        errorIndices.insert(index)
                    }
                    existing.insert(validated)
                }
                return errorIndices
            }
            .removeDuplicates()
            .assignWeakly(to: \.optionsErrorIndices, on: self)
            .store(in: &cancellables)
    }
        
    func createPoll(completion: @escaping () -> Void) {
        let pollOptions = options
            .map(\.trimmed)
            .filter { !$0.isEmpty }
            .map { PollOption(text: $0) }
        let maxVotesAllowed = multipleAnswers ? Int(maxVotes) : nil
        chatController.createPoll(
            name: question.trimmed,
            allowAnswers: allowComments,
            allowUserSuggestedOptions: suggestAnOption,
            enforceUniqueVote: !multipleAnswers,
            maxVotesAllowed: maxVotesAllowed,
            votingVisibility: anonymousPoll ? .anonymous : .public,
            options: pollOptions
        ) { [weak self] result in
            switch result {
            case let .success(messageId):
                log.debug("Created poll in message with id \(messageId)")
                completion()
            case let .failure(error):
                log.error("Error creating a poll: \(error.localizedDescription)")
                self?.errorShown = true
            }
        }
    }
    
    var canCreatePoll: Bool {
        guard !question.trimmed.isEmpty else { return false }
        guard optionsErrorIndices.isEmpty else { return false }
        guard !showsMaxVotesError else { return false }
        guard options.contains(where: { !$0.trimmed.isEmpty }) else { return false }
        return true
    }
    
    var canShowDiscardConfirmation: Bool {
        guard question.trimmed.isEmpty else { return true }
        return options.contains(where: { !$0.trimmed.isEmpty })
    }
    
    func showsOptionError(for index: Int) -> Bool {
        optionsErrorIndices.contains(index)
    }
}
