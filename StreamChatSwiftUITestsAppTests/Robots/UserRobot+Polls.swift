//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import XCTest

// MARK: Actions

extension UserRobot {
    @discardableResult
    func createPoll(question: String, options: [String], multipleAnswers: Bool = false) -> Self {
        MessageListPage.Composer.attachmentButton.wait().safeTap()
        if SpringBoard.photoAccessPopUp.exists {
            SpringBoard.photoAccessPopUp.safeTap()
        }
        // Selecting the polls tab presents the poll creation sheet right away.
        PollsPage.attachmentPickerPollsButton.wait().safeTap()
        let questionField = PollsPage.Creation.questionField.wait(timeout: XCUIElement.longWaitTimeout)
        // Toggled before typing, while the keyboard does not cover the setting.
        if multipleAnswers {
            PollsPage.Creation.multipleAnswersSwitch.wait().waitForHitPoint().safeTap()
        }
        questionField.safeTap()
        typeSlowly(question, into: questionField)
        for (index, option) in options.enumerated() {
            let optionField = PollsPage.Creation.optionField(at: index).wait()
            optionField.safeTap()
            typeSlowly(option, into: optionField)
        }
        PollsPage.Creation.createButton.wait().safeTap()
        return self
    }

    /// The poll creation fields apply each keystroke in a deferred task and re-render from the
    /// previous value, so fast typing can drop characters; each one is awaited before the next.
    private func typeSlowly(_ text: String, into field: XCUIElement) {
        var typed = ""
        for character in text {
            typed.append(character)
            field.typeText(String(character))
            _ = field.waitForValue(typed)
        }
    }

    @discardableResult
    func castPollVote(_ option: String) -> Self {
        PollsPage.Message.option(option).wait().safeTap()
        return self
    }

    /// A tap on an option the user already voted for removes the vote.
    @discardableResult
    func removePollVote(_ option: String) -> Self {
        PollsPage.Message.option(option).wait().safeTap()
        return self
    }

    @discardableResult
    func openPollResults() -> Self {
        PollsPage.Message.viewResultsButton.wait().safeTap()
        return self
    }

    @discardableResult
    func endPoll() -> Self {
        PollsPage.Message.endPollButton.wait().safeTap()
        PollsPage.Message.endPollConfirmationButton.wait().safeTap()
        return self
    }
}

// MARK: Asserts

extension UserRobot {
    @discardableResult
    func assertPollMessage(
        question: String,
        optionsCount: Int,
        multipleAnswers: Bool = false,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Self {
        let subtitle = multipleAnswers ? PollsPage.Message.multipleVotesSubtitle : PollsPage.Message.singleVoteSubtitle
        let header = PollsPage.Message.header(question: question, subtitle: subtitle, optionsCount: optionsCount)
        XCTAssertTrue(header.wait().exists, "Poll '\(question)' with subtitle '\(subtitle)' is not shown", file: file, line: line)
        return self
    }

    /// When `isChecked` is given, the option must also have that vote state, so the
    /// assertion waits out the round trip of a vote or its removal.
    @discardableResult
    func assertPollOption(
        _ option: String,
        isChecked: Bool? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Self {
        let element = isChecked.map { PollsPage.Message.option(option, isChecked: $0) } ?? PollsPage.Message.option(option)
        let state = isChecked.map { $0 ? " (checked)" : " (unchecked)" } ?? ""
        XCTAssertTrue(element.wait().exists, "Poll option '\(option)'\(state) is not shown", file: file, line: line)
        return self
    }

    @discardableResult
    func assertPollOptionVoteCount(
        _ option: String,
        count: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Self {
        let element = PollsPage.Message.option(option, voteCount: count)
        XCTAssertTrue(element.wait().exists, "Poll option '\(option)' has no \(count) vote(s)", file: file, line: line)
        return self
    }

    @discardableResult
    func assertPollResults(voterName: String, file: StaticString = #filePath, line: UInt = #line) -> Self {
        XCTAssertTrue(PollsPage.Results.title.wait().exists, "Poll results are not shown", file: file, line: line)
        XCTAssertTrue(PollsPage.Results.voter(voterName).wait().exists, "Voter '\(voterName)' is not shown", file: file, line: line)
        return self
    }

    @discardableResult
    func assertPollClosed(question: String, optionsCount: Int, file: StaticString = #filePath, line: UInt = #line) -> Self {
        let header = PollsPage.Message.header(
            question: question,
            subtitle: PollsPage.Message.closedSubtitle,
            optionsCount: optionsCount
        )
        XCTAssertTrue(header.wait().exists, "Poll is not shown as ended", file: file, line: line)
        XCTAssertFalse(PollsPage.Message.endPollButton.waitForDisappearance().exists, "End poll button is still shown", file: file, line: line)
        return self
    }

    @discardableResult
    func assertPollComments(count: Int, file: StaticString = #filePath, line: UInt = #line) -> Self {
        let button = PollsPage.Message.viewCommentsButton(count: count)
        XCTAssertTrue(button.wait().exists, "Poll comments button for \(count) comment(s) is not shown", file: file, line: line)
        return self
    }
}
