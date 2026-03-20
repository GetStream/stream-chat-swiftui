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
    @Published private(set) var options: [PollOptionEntry] = [PollOptionEntry()]
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
                    let normalized = option.text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
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

    // MARK: - Option Accessors

    var optionTexts: [String] {
        options.map(\.text)
    }

    func isLastOption(_ option: PollOptionEntry) -> Bool {
        option.id == options.last?.id
    }

    func showsOptionError(for option: PollOptionEntry) -> Bool {
        guard let index = options.firstIndex(where: { $0.id == option.id }) else { return false }
        return optionsErrorIndices.contains(index)
    }

    // MARK: - Option Mutations

    func updateOption(id: UUID, value: String) {
        guard let index = options.firstIndex(where: { $0.id == id }) else { return }
        options[index].text = value
        if index == options.count - 1,
           !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            withAnimation {
                options.append(PollOptionEntry())
            }
        }
    }

    func removeOption(id: UUID) {
        options.removeAll { $0.id == id }
    }

    func moveOptions(from source: IndexSet, to destination: Int) {
        options.move(fromOffsets: source, toOffset: destination)
    }

    func replaceAllOptions(_ newTexts: [String]) {
        options = newTexts.map { PollOptionEntry(text: $0) }
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
        guard options.contains(where: { !$0.text.trimmed.isEmpty }) else { return false }
        return true
    }

    var canShowDiscardConfirmation: Bool {
        guard question.trimmed.isEmpty else { return true }
        return options.contains(where: { !$0.text.trimmed.isEmpty })
    }

    // MARK: - Actions

    func createPoll(completion: @escaping @MainActor () -> Void) {
        let pollOptions = options
            .map(\.text.trimmed)
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

final class PollOptionEntry: Identifiable, Equatable {
    let id: UUID
    var text: String

    init(text: String = "") {
        self.id = UUID()
        self.text = text
    }
    
    static func == (lhs: PollOptionEntry, rhs: PollOptionEntry) -> Bool {
        lhs.id == rhs.id
    }
}
