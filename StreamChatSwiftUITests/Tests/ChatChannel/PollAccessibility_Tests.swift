//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

@MainActor final class PollAccessibility_Tests: StreamChatTestCase {
    // MARK: - Header

    func test_headerLabel_combinesNameSubtitleAndOptionCount() {
        let label = PollAccessibility.headerLabel(
            name: "Where to eat?",
            subtitle: "Select one",
            optionsCount: 4
        )

        XCTAssertEqual(
            label,
            L10n.Message.Polls.Accessibility.pollHeader("Where to eat?", "Select one", 4)
        )
    }

    // MARK: - Option

    func test_optionLabel_notSelected_zeroVotes_includesPosition() {
        let label = PollAccessibility.optionLabel(
            text: "Pizza",
            isSelected: false,
            voteCount: 0,
            optionIndex: 2,
            optionsCount: 4
        )

        let expected = L10n.Message.Polls.Accessibility.option(
            "Pizza",
            L10n.Message.Polls.Accessibility.notSelected,
            L10n.Message.Polls.votes(0)
        ) + ". " + L10n.Message.Polls.Accessibility.optionPosition(2, 4)
        XCTAssertEqual(label, expected)
    }

    func test_optionLabel_selected_singleVote_usesSingularWording() {
        let label = PollAccessibility.optionLabel(
            text: "Pizza",
            isSelected: true,
            voteCount: 1,
            optionIndex: 1,
            optionsCount: 4
        )

        let expected = L10n.Message.Polls.Accessibility.option(
            "Pizza",
            L10n.Message.Polls.Accessibility.selected,
            L10n.Message.Polls.voteSingular(1)
        ) + ". " + L10n.Message.Polls.Accessibility.optionPosition(1, 4)
        XCTAssertEqual(label, expected)
    }

    func test_optionLabel_selected_multipleVotes_usesIncludingYoursWording() {
        let label = PollAccessibility.optionLabel(
            text: "Pizza",
            isSelected: true,
            voteCount: 3,
            optionIndex: 1,
            optionsCount: 4
        )

        let expected = L10n.Message.Polls.Accessibility.option(
            "Pizza",
            L10n.Message.Polls.Accessibility.selected,
            L10n.Message.Polls.Accessibility.votesIncludingYours(3)
        ) + ". " + L10n.Message.Polls.Accessibility.optionPosition(1, 4)
        XCTAssertEqual(label, expected)
    }

    func test_optionLabel_notSelected_multipleVotes_usesPluralWording() {
        let label = PollAccessibility.optionLabel(
            text: "Pizza",
            isSelected: false,
            voteCount: 3,
            optionIndex: 1,
            optionsCount: 4
        )

        let expected = L10n.Message.Polls.Accessibility.option(
            "Pizza",
            L10n.Message.Polls.Accessibility.notSelected,
            L10n.Message.Polls.votes(3)
        ) + ". " + L10n.Message.Polls.Accessibility.optionPosition(1, 4)
        XCTAssertEqual(label, expected)
    }

    func test_optionLabel_withoutPosition_omitsPositionSuffix() {
        let label = PollAccessibility.optionLabel(
            text: "Pizza",
            isSelected: false,
            voteCount: 0,
            optionIndex: nil,
            optionsCount: nil
        )

        let expected = L10n.Message.Polls.Accessibility.option(
            "Pizza",
            L10n.Message.Polls.Accessibility.notSelected,
            L10n.Message.Polls.votes(0)
        )
        XCTAssertEqual(label, expected)
        XCTAssertFalse(label.contains(L10n.Message.Polls.Accessibility.optionPosition(1, 1)))
    }

    // MARK: - Question

    func test_questionLabel_combinesQuestionAndName() {
        let label = PollAccessibility.questionLabel(
            question: L10n.Message.Polls.question,
            name: "Where to eat?"
        )

        XCTAssertEqual(label, "\(L10n.Message.Polls.question). Where to eat?")
    }

    // MARK: - Results Option Heading

    func test_resultsOptionHeadingLabel_withIndexLeadingAndMultipleVotes() {
        let label = PollAccessibility.resultsOptionHeadingLabel(
            optionIndex: 1,
            optionText: "Pizza",
            hasMostVotes: true,
            voteCount: 3
        )

        let expected = [
            "\(L10n.Message.Polls.option(1)): Pizza",
            L10n.Message.Polls.Accessibility.leadingOption,
            L10n.Message.Polls.votes(3)
        ].joined(separator: ", ")
        XCTAssertEqual(label, expected)
    }

    func test_resultsOptionHeadingLabel_withIndexNotLeadingSingleVote_usesSingularWording() {
        let label = PollAccessibility.resultsOptionHeadingLabel(
            optionIndex: 2,
            optionText: "Sushi",
            hasMostVotes: false,
            voteCount: 1
        )

        let expected = [
            "\(L10n.Message.Polls.option(2)): Sushi",
            L10n.Message.Polls.voteSingular(1)
        ].joined(separator: ", ")
        XCTAssertEqual(label, expected)
        XCTAssertFalse(label.contains(L10n.Message.Polls.Accessibility.leadingOption))
    }

    func test_resultsOptionHeadingLabel_withoutIndex_omitsOptionPrefix() {
        let label = PollAccessibility.resultsOptionHeadingLabel(
            optionIndex: nil,
            optionText: "Sushi",
            hasMostVotes: false,
            voteCount: 0
        )

        let expected = ["Sushi", L10n.Message.Polls.votes(0)].joined(separator: ", ")
        XCTAssertEqual(label, expected)
    }

    // MARK: - Voter

    func test_voterLabel_combinesNameAndDate() {
        let label = PollAccessibility.voterLabel(name: "Luke Skywalker", date: "09/04/26")

        XCTAssertEqual(label, L10n.Message.Polls.Accessibility.voter("Luke Skywalker", "09/04/26"))
    }
}
