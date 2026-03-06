//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Combine
import Foundation
import StreamChat
import SwiftUI

@MainActor class CreatePollViewModel: ObservableObject {
    @Injected(\.utils) private var utils

    // MARK: - Published State

    @Published var question = ""
    @Published private(set) var options: [String] = [""]
    @Published private(set) var optionsErrorIndices = Set<Int>()

    @Published var multipleAnswers: Bool
    @Published var maxVotesEnabled: Bool
    @Published private(set) var maxVotes: Int = 2

    @Published var anonymousPoll: Bool
    @Published var suggestAnOption: Bool
    @Published var allowComments: Bool

    @Published var discardConfirmationShown = false
    @Published var errorShown = false

    // MARK: - Dependencies

    let chatController: ChatChannelController
    let messageController: ChatMessageController?

    private var cancellables = [AnyCancellable]()

    // MARK: - Init

    init(chatController: ChatChannelController, messageController: ChatMessageController?) {
        let pollsConfig = InjectedValues[\.utils].pollsConfig
        self.chatController = chatController
        self.messageController = messageController

        multipleAnswers = pollsConfig.multipleAnswers.defaultValue
        maxVotesEnabled = pollsConfig.maxVotesPerPerson.defaultValue
        anonymousPoll = pollsConfig.anonymousPoll.defaultValue
        suggestAnOption = pollsConfig.suggestAnOption.defaultValue
        allowComments = pollsConfig.addComments.defaultValue

        $options
            .map { options in
                var errorIndices = Set<Int>()
                var existing = Set<String>(minimumCapacity: options.count)
                for (index, option) in options.enumerated() {
                    let normalized = option.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !normalized.isEmpty else {
                        continue
                    }
                    if existing.contains(normalized) {
                        errorIndices.insert(index)
                    }
                    existing.insert(normalized)
                }
                return errorIndices
            }
            .removeDuplicates()
            .assign(to: \.optionsErrorIndices, onWeak: self)
            .store(in: &cancellables)
    }

    // MARK: - Config Visibility

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

    // MARK: - Option Mutations

    func updateOption(at index: Int, value: String) {
        options[index] = value
        if index == options.count - 1,
           !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            withAnimation {
                options.append("")
            }
        }
    }

    func removeOption(at index: Int) {
        options.remove(at: index)
    }

    func moveOptions(from source: IndexSet, to destination: Int) {
        options.move(fromOffsets: source, toOffset: destination)
    }

    func replaceAllOptions(_ newOptions: [String]) {
        options = newOptions
    }

    // MARK: - Max Votes

    var maxVotesText: String {
        String(maxVotes)
    }

    var canDecrementMaxVotes: Bool {
        maxVotes > maxVotesRange.lowerBound
    }

    var canIncrementMaxVotes: Bool {
        maxVotes < maxVotesRange.upperBound
    }

    func decrementMaxVotes() {
        maxVotes = max(maxVotes - 1, maxVotesRange.lowerBound)
    }

    func incrementMaxVotes() {
        maxVotes = min(maxVotes + 1, maxVotesRange.upperBound)
    }

    // MARK: - Validation

    var canCreatePoll: Bool {
        guard !question.trimmed.isEmpty else { return false }
        guard optionsErrorIndices.isEmpty else { return false }
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

    // MARK: - Actions

    func createPoll(completion: @escaping @MainActor () -> Void) {
        let pollOptions = options
            .map(\.trimmed)
            .filter { !$0.isEmpty }
            .map { PollOption(text: $0) }
        let maxVotesAllowed = (multipleAnswers && maxVotesEnabled) ? maxVotes : nil
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

    // MARK: - Private

    private let maxVotesRange = 2...10
}
