//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import SwiftUI
import XCTest

@MainActor final class CreatePollViewModel_Tests: StreamChatTestCase {
    private func makeViewModel(
        pollsConfig: PollsConfig? = nil
    ) -> CreatePollViewModel {
        if let pollsConfig {
            let utils = Utils(pollsConfig: pollsConfig)
            streamChat = StreamChat(chatClient: chatClient, utils: utils)
        }
        return CreatePollViewModel(
            chatController: chatClient.channelController(for: .unique),
            messageController: nil
        )
    }

    // MARK: - Can Show Discard Confirmation

    func test_canShowDiscardConfirmation_whenEmpty() {
        let viewModel = makeViewModel()
        XCTAssertFalse(viewModel.canShowDiscardConfirmation)
    }

    func test_canShowDiscardConfirmation_whenToggleChangesButNoTextEntry() {
        let viewModel = makeViewModel()
        viewModel.allowComments.toggle()
        XCTAssertFalse(viewModel.canShowDiscardConfirmation)
    }

    func test_canShowDiscardConfirmation_whenQuestionFilled() {
        let viewModel = makeViewModel()
        viewModel.question = "A"
        XCTAssertTrue(viewModel.canShowDiscardConfirmation)
    }

    func test_canShowDiscardConfirmation_whenQuestionOnlyWhitespace() {
        let viewModel = makeViewModel()
        viewModel.question = "              "
        XCTAssertFalse(viewModel.canShowDiscardConfirmation)
    }

    func test_canShowDiscardConfirmation_whenOptionAdded() {
        let viewModel = makeViewModel()
        viewModel.replaceAllOptions(["A"])
        XCTAssertTrue(viewModel.canShowDiscardConfirmation)
    }

    // MARK: - Can Create Poll

    func test_canCreatePoll_whenRequiredInformationAdded() {
        let viewModel = makeViewModel()
        viewModel.question = " A  "
        viewModel.replaceAllOptions(["O     "])
        XCTAssertTrue(viewModel.canCreatePoll)
    }

    func test_canCreatePoll_whenEmptyOrChangedToggles() {
        let viewModel = makeViewModel()
        viewModel.allowComments.toggle()
        XCTAssertFalse(viewModel.canCreatePoll)
    }

    func test_canCreatePoll_whenQuestionOnlyWhitespace() {
        let viewModel = makeViewModel()
        viewModel.question = "   "
        viewModel.replaceAllOptions(["Option"])
        XCTAssertFalse(viewModel.canCreatePoll)
    }

    func test_canCreatePoll_whenOptionsOnlyWhitespace() {
        let viewModel = makeViewModel()
        viewModel.question = "Question"
        viewModel.replaceAllOptions(["   ", "  "])
        XCTAssertFalse(viewModel.canCreatePoll)
    }

    func test_canCreatePoll_whenInsertingInformation() {
        let viewModel = makeViewModel()
        XCTAssertFalse(viewModel.canCreatePoll)
        viewModel.question = "A"
        XCTAssertFalse(viewModel.canCreatePoll)
        viewModel.replaceAllOptions(["A", "a"])
        XCTAssertFalse(viewModel.canCreatePoll)
        viewModel.replaceAllOptions(["A", "aa"])
        XCTAssertTrue(viewModel.canCreatePoll)
    }

    // MARK: - Config Visibility

    func test_multipleAnswersShown_defaultConfig() {
        let viewModel = makeViewModel()
        XCTAssertTrue(viewModel.multipleAnswersShown)
        XCTAssertFalse(viewModel.multipleAnswers)
    }

    func test_multipleAnswersShown_hidden() {
        let viewModel = makeViewModel(
            pollsConfig: .init(multipleAnswers: .init(configurable: false, defaultValue: false))
        )
        XCTAssertFalse(viewModel.multipleAnswersShown)
        XCTAssertFalse(viewModel.multipleAnswers)
    }

    func test_multipleAnswersShown_enabledByDefault() {
        let viewModel = makeViewModel(
            pollsConfig: .init(multipleAnswers: .init(configurable: true, defaultValue: true))
        )
        XCTAssertTrue(viewModel.multipleAnswersShown)
        XCTAssertTrue(viewModel.multipleAnswers)
    }

    func test_anonymousPollShown_defaultConfig() {
        let viewModel = makeViewModel()
        XCTAssertTrue(viewModel.anonymousPollShown)
        XCTAssertFalse(viewModel.anonymousPoll)
    }

    func test_anonymousPollShown_hidden() {
        let viewModel = makeViewModel(
            pollsConfig: .init(anonymousPoll: .init(configurable: false, defaultValue: false))
        )
        XCTAssertFalse(viewModel.anonymousPollShown)
        XCTAssertFalse(viewModel.anonymousPoll)
    }

    func test_suggestAnOptionShown_defaultConfig() {
        let viewModel = makeViewModel()
        XCTAssertTrue(viewModel.suggestAnOptionShown)
        XCTAssertFalse(viewModel.suggestAnOption)
    }

    func test_suggestAnOptionShown_hidden() {
        let viewModel = makeViewModel(
            pollsConfig: .init(suggestAnOption: .init(configurable: false, defaultValue: false))
        )
        XCTAssertFalse(viewModel.suggestAnOptionShown)
        XCTAssertFalse(viewModel.suggestAnOption)
    }

    func test_addCommentsShown_defaultConfig() {
        let viewModel = makeViewModel()
        XCTAssertTrue(viewModel.addCommentsShown)
        XCTAssertFalse(viewModel.allowComments)
    }

    func test_addCommentsShown_hidden() {
        let viewModel = makeViewModel(
            pollsConfig: .init(addComments: .init(configurable: false, defaultValue: false))
        )
        XCTAssertFalse(viewModel.addCommentsShown)
        XCTAssertFalse(viewModel.allowComments)
    }

    func test_maxVotesShown_defaultConfig() {
        let viewModel = makeViewModel()
        XCTAssertTrue(viewModel.maxVotesShown)
        XCTAssertFalse(viewModel.maxVotesEnabled)
    }

    func test_maxVotesShown_hidden() {
        let viewModel = makeViewModel(
            pollsConfig: .init(maxVotesPerPerson: .init(configurable: false, defaultValue: false))
        )
        XCTAssertFalse(viewModel.maxVotesShown)
        XCTAssertFalse(viewModel.maxVotesEnabled)
    }

    // MARK: - Text Length Limits

    func test_question_noLimitByDefault_acceptsLongText() {
        let viewModel = makeViewModel()
        let longText = String(repeating: "A", count: 500)
        viewModel.question = longText
        XCTAssertEqual(viewModel.question, longText)
    }

    func test_question_truncatedToMaxQuestionLength() {
        let viewModel = makeViewModel(pollsConfig: .init(maxQuestionLength: 5))
        viewModel.question = "Hello, World"
        XCTAssertEqual(viewModel.question, "Hello")
    }

    func test_question_withinMaxQuestionLength_unchanged() {
        let viewModel = makeViewModel(pollsConfig: .init(maxQuestionLength: 5))
        viewModel.question = "Hi"
        XCTAssertEqual(viewModel.question, "Hi")
    }

    func test_question_truncationCountsCharactersNotBytes() {
        let viewModel = makeViewModel(pollsConfig: .init(maxQuestionLength: 3))
        viewModel.question = "😀😀😀😀😀"
        XCTAssertEqual(viewModel.question, "😀😀😀")
    }

    func test_updateOption_noLimitByDefault_acceptsLongText() {
        let viewModel = makeViewModel()
        let longText = String(repeating: "A", count: 500)
        let id = viewModel.options.last!.id
        viewModel.updateOption(id: id, value: longText)
        XCTAssertEqual(viewModel.options[0].text, longText)
    }

    func test_updateOption_truncatedToMaxOptionLength() {
        let viewModel = makeViewModel(pollsConfig: .init(maxOptionLength: 4))
        let id = viewModel.options.last!.id
        viewModel.updateOption(id: id, value: "Option")
        XCTAssertEqual(viewModel.options[0].text, "Opti")
    }

    func test_updateOption_withinMaxOptionLength_unchanged() {
        let viewModel = makeViewModel(pollsConfig: .init(maxOptionLength: 4))
        let id = viewModel.options.last!.id
        viewModel.updateOption(id: id, value: "Opt")
        XCTAssertEqual(viewModel.options[0].text, "Opt")
    }

    func test_maxQuestionAndOptionLength_defaultToNil() {
        let config = PollsConfig()
        XCTAssertNil(config.maxQuestionLength)
        XCTAssertNil(config.maxOptionLength)
    }

    // MARK: - Initial State

    func test_initialState_hasOneEmptyOption() {
        let viewModel = makeViewModel()
        XCTAssertEqual(viewModel.options.count, 1)
        XCTAssertEqual(viewModel.optionTexts, [""])
    }

    func test_initialState_defaultPropertyValues() {
        let viewModel = makeViewModel()
        XCTAssertEqual(viewModel.question, "")
        XCTAssertTrue(viewModel.optionsErrorIndices.isEmpty)
        XCTAssertFalse(viewModel.discardConfirmationShown)
        XCTAssertFalse(viewModel.errorShown)
    }

    // MARK: - Option Accessors

    func test_optionTexts_returnsTextValues() {
        let viewModel = makeViewModel()
        viewModel.replaceAllOptions(["Red", "Blue", "Green"])
        XCTAssertEqual(viewModel.optionTexts, ["Red", "Blue", "Green"])
    }

    func test_isLastOption_returnsTrueForLastOption() {
        let viewModel = makeViewModel()
        viewModel.replaceAllOptions(["A", "B", ""])
        XCTAssertFalse(viewModel.isLastOption(viewModel.options[0]))
        XCTAssertFalse(viewModel.isLastOption(viewModel.options[1]))
        XCTAssertTrue(viewModel.isLastOption(viewModel.options[2]))
    }

    func test_isLastOption_singleOption() {
        let viewModel = makeViewModel()
        XCTAssertTrue(viewModel.isLastOption(viewModel.options[0]))
    }

    // MARK: - Option Mutations: updateOption

    func test_updateOption_updatesTextAtCorrectId() {
        let viewModel = makeViewModel()
        viewModel.replaceAllOptions(["A", "B", ""])
        let targetId = viewModel.options[1].id
        viewModel.updateOption(id: targetId, value: "Updated")
        XCTAssertEqual(viewModel.optionTexts, ["A", "Updated", ""])
    }

    func test_updateOption_appendsNewEntryWhenEditingLastOption() {
        let viewModel = makeViewModel()
        let lastId = viewModel.options.last!.id
        viewModel.updateOption(id: lastId, value: "New")
        XCTAssertEqual(viewModel.options.count, 2)
        XCTAssertEqual(viewModel.options[0].text, "New")
        XCTAssertEqual(viewModel.options[1].text, "")
    }

    func test_updateOption_doesNotAppendWhenEditingNonLastOption() {
        let viewModel = makeViewModel()
        viewModel.replaceAllOptions(["A", "B", ""])
        let firstId = viewModel.options[0].id
        viewModel.updateOption(id: firstId, value: "Updated")
        XCTAssertEqual(viewModel.options.count, 3)
        XCTAssertEqual(viewModel.optionTexts, ["Updated", "B", ""])
    }

    func test_updateOption_doesNotAppendWhenLastOptionIsWhitespace() {
        let viewModel = makeViewModel()
        let lastId = viewModel.options.last!.id
        viewModel.updateOption(id: lastId, value: "   ")
        XCTAssertEqual(viewModel.options.count, 1)
    }

    func test_updateOption_doesNothingForUnknownId() {
        let viewModel = makeViewModel()
        viewModel.replaceAllOptions(["A", "B"])
        viewModel.updateOption(id: UUID(), value: "Unknown")
        XCTAssertEqual(viewModel.optionTexts, ["A", "B"])
    }

    // MARK: - Option Mutations: removeOption

    func test_removeOption_removesCorrectOption() {
        let viewModel = makeViewModel()
        viewModel.replaceAllOptions(["A", "B", "C"])
        let targetId = viewModel.options[1].id
        viewModel.removeOption(id: targetId)
        XCTAssertEqual(viewModel.optionTexts, ["A", "C"])
    }

    func test_removeOption_doesNothingForUnknownId() {
        let viewModel = makeViewModel()
        viewModel.replaceAllOptions(["A", "B"])
        viewModel.removeOption(id: UUID())
        XCTAssertEqual(viewModel.optionTexts, ["A", "B"])
    }

    // MARK: - Option Mutations: moveOptions

    func test_moveOptions_reordersCorrectly() {
        let viewModel = makeViewModel()
        viewModel.replaceAllOptions(["A", "B", "C", ""])
        viewModel.moveOptions(from: IndexSet(integer: 2), to: 0)
        XCTAssertEqual(viewModel.optionTexts, ["C", "A", "B", ""])
    }

    func test_moveOptions_preservesStableIdentity() {
        let viewModel = makeViewModel()
        viewModel.replaceAllOptions(["A", "B", "C"])
        let originalIds = viewModel.options.map(\.id)
        viewModel.moveOptions(from: IndexSet(integer: 2), to: 0)
        XCTAssertEqual(viewModel.options[0].id, originalIds[2])
        XCTAssertEqual(viewModel.options[1].id, originalIds[0])
        XCTAssertEqual(viewModel.options[2].id, originalIds[1])
    }

    // MARK: - Accessibility-driven reordering

    func test_moveOption_decrement_movesUpOnePosition() {
        let viewModel = makeViewModel()
        viewModel.replaceAllOptions(["A", "B", "C", ""])
        let targetId = viewModel.options[1].id

        XCTAssertTrue(viewModel.moveOption(id: targetId, direction: .decrement))

        XCTAssertEqual(viewModel.optionTexts, ["B", "A", "C", ""])
    }

    func test_moveOption_increment_movesDownOnePosition() {
        let viewModel = makeViewModel()
        viewModel.replaceAllOptions(["A", "B", "C", ""])
        let targetId = viewModel.options[0].id

        XCTAssertTrue(viewModel.moveOption(id: targetId, direction: .increment))

        XCTAssertEqual(viewModel.optionTexts, ["B", "A", "C", ""])
    }

    func test_moveOption_decrement_atFirstPosition_doesNothing() {
        let viewModel = makeViewModel()
        viewModel.replaceAllOptions(["A", "B", ""])
        let firstId = viewModel.options[0].id

        XCTAssertFalse(viewModel.moveOption(id: firstId, direction: .decrement))

        XCTAssertEqual(viewModel.optionTexts, ["A", "B", ""])
    }

    func test_moveOption_increment_atLastReorderablePosition_doesNothing() {
        // The trailing empty placeholder is not movable, so the last reorderable
        // option must not be swapped down into it.
        let viewModel = makeViewModel()
        viewModel.replaceAllOptions(["A", "B", ""])
        let lastReorderableId = viewModel.options[1].id

        XCTAssertFalse(viewModel.moveOption(id: lastReorderableId, direction: .increment))

        XCTAssertEqual(viewModel.optionTexts, ["A", "B", ""])
    }

    func test_moveOption_unknownId_doesNothing() {
        let viewModel = makeViewModel()
        viewModel.replaceAllOptions(["A", "B"])

        XCTAssertFalse(viewModel.moveOption(id: UUID(), direction: .increment))

        XCTAssertEqual(viewModel.optionTexts, ["A", "B"])
    }

    // MARK: - Reorderable Option Count

    func test_reorderableOptionCount_excludesTrailingEmptyPlaceholder() {
        let viewModel = makeViewModel()
        viewModel.replaceAllOptions(["A", "B", "C", ""])
        XCTAssertEqual(viewModel.reorderableOptionCount, 3)
    }

    func test_reorderableOptionCount_initialEmptyOption_isZero() {
        let viewModel = makeViewModel()
        XCTAssertEqual(viewModel.reorderableOptionCount, 0)
    }

    // MARK: - Option Mutations: replaceAllOptions

    func test_replaceAllOptions_replacesWithNewEntries() {
        let viewModel = makeViewModel()
        viewModel.replaceAllOptions(["X", "Y"])
        XCTAssertEqual(viewModel.options.count, 2)
        XCTAssertEqual(viewModel.optionTexts, ["X", "Y"])
    }

    func test_replaceAllOptions_assignsUniqueIds() {
        let viewModel = makeViewModel()
        viewModel.replaceAllOptions(["A", "A", "A"])
        let ids = viewModel.options.map(\.id)
        XCTAssertEqual(Set(ids).count, 3)
    }

    // MARK: - Duplicate Option Errors

    func test_optionsErrorIndices_ignoreWhitespaceAndCase() {
        let viewModel = makeViewModel()
        viewModel.replaceAllOptions(["   123ab   ", "123Ab", "123AB "])
        XCTAssertEqual(Set([1, 2]), viewModel.optionsErrorIndices)
    }

    func test_optionsErrorIndices_emptyDuplicatesIgnored() {
        let viewModel = makeViewModel()
        viewModel.replaceAllOptions(["", "", "A"])
        XCTAssertTrue(viewModel.optionsErrorIndices.isEmpty)
    }

    func test_showsOptionError_returnsCorrectValue() {
        let viewModel = makeViewModel()
        viewModel.replaceAllOptions(["A", "a", "B"])
        XCTAssertFalse(viewModel.showsOptionError(for: viewModel.options[0]))
        XCTAssertTrue(viewModel.showsOptionError(for: viewModel.options[1]))
        XCTAssertFalse(viewModel.showsOptionError(for: viewModel.options[2]))
    }

    func test_showsOptionError_returnsFalseForUnknownOption() {
        let viewModel = makeViewModel()
        viewModel.replaceAllOptions(["A", "a"])
        let unknownOption = PollOptionEntry(text: "a")
        XCTAssertFalse(viewModel.showsOptionError(for: unknownOption))
    }

    // MARK: - Max Votes Stepper

    func test_maxVotesText_returnsStringRepresentation() {
        let viewModel = makeViewModel()
        XCTAssertEqual(viewModel.maxVotesText, "2")
    }

    func test_canDecrementMaxVotes_atMinimum_returnsFalse() {
        let viewModel = makeViewModel()
        XCTAssertFalse(viewModel.canDecrementMaxVotes)
    }

    func test_canDecrementMaxVotes_aboveMinimum_returnsTrue() {
        let viewModel = makeViewModel()
        viewModel.incrementMaxVotes()
        XCTAssertTrue(viewModel.canDecrementMaxVotes)
    }

    func test_canIncrementMaxVotes_atMaximum_returnsFalse() {
        let viewModel = makeViewModel()
        for _ in 0..<20 {
            viewModel.incrementMaxVotes()
        }
        XCTAssertEqual(viewModel.maxVotes, 10)
        XCTAssertFalse(viewModel.canIncrementMaxVotes)
    }

    func test_canIncrementMaxVotes_belowMaximum_returnsTrue() {
        let viewModel = makeViewModel()
        XCTAssertTrue(viewModel.canIncrementMaxVotes)
    }

    func test_incrementMaxVotes_incrementsByOne() {
        let viewModel = makeViewModel()
        XCTAssertEqual(viewModel.maxVotes, 2)
        viewModel.incrementMaxVotes()
        XCTAssertEqual(viewModel.maxVotes, 3)
        XCTAssertEqual(viewModel.maxVotesText, "3")
    }

    func test_incrementMaxVotes_clampsAtMaximum() {
        let viewModel = makeViewModel()
        for _ in 0..<20 {
            viewModel.incrementMaxVotes()
        }
        XCTAssertEqual(viewModel.maxVotes, 10)
    }

    func test_decrementMaxVotes_decrementsByOne() {
        let viewModel = makeViewModel()
        viewModel.incrementMaxVotes()
        viewModel.incrementMaxVotes()
        XCTAssertEqual(viewModel.maxVotes, 4)
        viewModel.decrementMaxVotes()
        XCTAssertEqual(viewModel.maxVotes, 3)
        XCTAssertEqual(viewModel.maxVotesText, "3")
    }

    func test_decrementMaxVotes_clampsAtMinimum() {
        let viewModel = makeViewModel()
        viewModel.decrementMaxVotes()
        XCTAssertEqual(viewModel.maxVotes, 2)
    }

    func test_maxVotesStepper_fullRange() {
        let viewModel = makeViewModel()
        XCTAssertEqual(viewModel.maxVotes, 2)
        XCTAssertFalse(viewModel.canDecrementMaxVotes)
        XCTAssertTrue(viewModel.canIncrementMaxVotes)

        for expected in 3...10 {
            viewModel.incrementMaxVotes()
            XCTAssertEqual(viewModel.maxVotes, expected)
        }

        XCTAssertTrue(viewModel.canDecrementMaxVotes)
        XCTAssertFalse(viewModel.canIncrementMaxVotes)
    }
}
