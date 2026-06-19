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

    @Published var question = "" {
        didSet {
            guard let maxQuestionLength else { return }
            let clamped = clamped(question, to: maxQuestionLength)
            if clamped != question {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [weak self] in
                    self?.question = clamped
                })
            }
        }
    }

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

    /// The maximum number of characters accepted in the question text field, or `nil` for no limit.
    private let maxQuestionLength: Int?
    /// The maximum number of characters accepted in each option text field, or `nil` for no limit.
    private let maxOptionLength: Int?

    // MARK: - Init

    init(chatController: ChatChannelController, messageController: ChatMessageController?) {
        let pollsConfig = InjectedValues[\.utils].pollsConfig
        self.chatController = chatController
        self.messageController = messageController

        maxQuestionLength = pollsConfig.maxQuestionLength
        maxOptionLength = pollsConfig.maxOptionLength

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

    /// The number of reorderable options (excluding the trailing empty
    /// placeholder), used to build the "Option N of M" accessibility value.
    var reorderableOptionCount: Int {
        options.filter { !$0.text.isEmpty }.count
    }

    // MARK: - Option Mutations

    func updateOption(id: UUID, value: String) {
        guard let index = options.firstIndex(where: { $0.id == id }) else { return }
        let value = clamped(value, to: maxOptionLength)
        options[index].text = value
        if maxOptionLength != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.options[index].text = value
            }
        }
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

    /// Accessibility-driven reordering: moves the option one position up
    /// (`.decrement`) or down (`.increment`) in the list. Used as the
    /// adjustable action backing the reorder handle, so VoiceOver users can
    /// reorder via the rotor without a drag gesture. No-op past the bounds
    /// or onto the trailing empty placeholder.
    func moveOption(id: UUID, direction: AccessibilityAdjustmentDirection) -> Bool {
        guard let index = options.firstIndex(where: { $0.id == id }) else { return false }
        switch direction {
        case .decrement:
            guard index > 0 else { return false }
            moveOptions(from: IndexSet(integer: index), to: index - 1)
            return true
        case .increment:
            guard index < options.count - 2 else { return false }
            moveOptions(from: IndexSet(integer: index), to: index + 2)
            return true
        @unknown default:
            return false
        }
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
                ComposerAccessibilityAnnouncer.announce(L10n.Composer.Polls.Accessibility.pollAdded)
                completion()
            case let .failure(error):
                log.error("Error creating a poll: \(error.localizedDescription)")
                self?.errorShown = true
            }
        }
    }

    // MARK: - Private

    private let maxVotesRange = 2...10

    /// Truncates `text` to at most `limit` characters. Returns `text` unchanged
    /// when `limit` is `nil` (no limit configured) or the text is already within it.
    private func clamped(_ text: String, to limit: Int?) -> String {
        guard let limit, text.count > limit else { return text }
        return String(text.prefix(limit))
    }
}

struct PollOptionEntry: Identifiable, Equatable, Sendable {
    let id: UUID
    var text: String

    init(text: String = "") {
        self.id = UUID()
        self.text = text
    }
}
