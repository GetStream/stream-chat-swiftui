//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
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
        viewModel.options = ["A"]
        XCTAssertTrue(viewModel.canShowDiscardConfirmation)
    }

    // MARK: - Can Create Poll

    func test_canCreatePoll_whenRequiredInformationAdded() {
        let viewModel = makeViewModel()
        viewModel.question = " A  "
        viewModel.options = ["O     "]
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
        viewModel.options = ["Option"]
        XCTAssertFalse(viewModel.canCreatePoll)
    }

    func test_canCreatePoll_whenOptionsOnlyWhitespace() {
        let viewModel = makeViewModel()
        viewModel.question = "Question"
        viewModel.options = ["   ", "  "]
        XCTAssertFalse(viewModel.canCreatePoll)
    }

    func test_canCreatePoll_whenInsertingInformation() {
        let viewModel = makeViewModel()
        XCTAssertFalse(viewModel.canCreatePoll)
        viewModel.question = "A"
        XCTAssertFalse(viewModel.canCreatePoll)
        viewModel.options = ["A", "a"]
        XCTAssertFalse(viewModel.canCreatePoll)
        viewModel.options = ["A", "aa"]
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

    // MARK: - Duplicate Option Errors

    func test_optionsErrorIndices_ignoreWhitespaceAndCase() {
        let viewModel = makeViewModel()
        viewModel.options = ["   123ab   "]
        viewModel.options.append("123Ab")
        viewModel.options.append("123AB ")
        XCTAssertEqual(Set([1, 2]), viewModel.optionsErrorIndices)
    }

    func test_optionsErrorIndices_emptyDuplicatesIgnored() {
        let viewModel = makeViewModel()
        viewModel.options = ["", "", "A"]
        XCTAssertTrue(viewModel.optionsErrorIndices.isEmpty)
    }

    func test_showsOptionError_returnsCorrectValue() {
        let viewModel = makeViewModel()
        viewModel.options = ["A", "a", "B"]
        XCTAssertFalse(viewModel.showsOptionError(for: 0))
        XCTAssertTrue(viewModel.showsOptionError(for: 1))
        XCTAssertFalse(viewModel.showsOptionError(for: 2))
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
