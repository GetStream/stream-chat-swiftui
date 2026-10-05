//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import XCTest

final class Polls_Tests: StreamTestCase {
    private let question = "Best color?"
    private let firstOption = "Red"
    private let secondOption = "Blue"
    private var options: [String] { [firstOption, secondOption] }

    func test_pollMessageIsShown_whenUserCreatesPoll() throws {
        linkToScenario(withId: 12032)

        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        WHEN("user creates a poll from the attachment picker") {
            userRobot.createPoll(question: question, options: options)
        }
        THEN("the poll message shows the question and the options") {
            userRobot
                .assertPollMessage(question: question, optionsCount: options.count)
                .assertPollOption(firstOption)
                .assertPollOption(secondOption)
        }
    }

    func test_optionIsChecked_whenUserVotesInPoll() throws {
        linkToScenario(withId: 12033)

        GIVEN("user creates a poll") {
            userRobot
                .login()
                .openChannel()
                .createPoll(question: question, options: options)
                .assertPollOption(firstOption, isChecked: false)
        }
        WHEN("user votes for an option") {
            userRobot.castPollVote(firstOption)
        }
        THEN("the option is checked") {
            userRobot.assertPollOption(firstOption, isChecked: true)
        }
    }

    func test_optionIsUnchecked_whenUserRemovesPollVote() throws {
        linkToScenario(withId: 12034)

        GIVEN("user creates a poll and votes") {
            userRobot
                .login()
                .openChannel()
                .createPoll(question: question, options: options)
                .castPollVote(firstOption)
                .assertPollOption(firstOption, isChecked: true)
        }
        WHEN("user taps on the voted option again") {
            userRobot.removePollVote(firstOption)
        }
        THEN("the option is unchecked") {
            userRobot.assertPollOption(firstOption, isChecked: false)
        }
    }

    func test_participantVoteIsShownInPollResults_whenParticipantVotesInPoll() throws {
        linkToScenario(withId: 12035)

        GIVEN("user creates a poll") {
            userRobot
                .login()
                .openChannel()
                .createPoll(question: question, options: options)
                .assertMessageDeliveryStatus(.sent)
        }
        AND("participant votes for an option") {
            participantRobot.castPollVote(option: firstOption)
        }
        WHEN("user opens the poll results") {
            userRobot
                .assertPollOptionVoteCount(firstOption, count: 1)
                .openPollResults()
        }
        THEN("the participant vote is shown") {
            userRobot.assertPollResults(voterName: participantRobot.name)
        }
    }

    func test_pollIsClosed_whenUserEndsPoll() throws {
        linkToScenario(withId: 12036)

        GIVEN("user creates a poll") {
            userRobot
                .login()
                .openChannel()
                .createPoll(question: question, options: options)
                .assertPollOption(firstOption)
        }
        WHEN("user ends the poll") {
            userRobot.endPoll()
        }
        THEN("the poll is shown as ended") {
            userRobot.assertPollClosed(question: question, optionsCount: options.count)
        }
    }

    // MARK: - iOS only

    func test_userVotesForSeveralOptions_whenPollAllowsMultipleVotes() throws {
        linkToScenario(withId: 12037)

        GIVEN("user creates a poll that allows multiple votes") {
            userRobot
                .login()
                .openChannel()
                .createPoll(question: question, options: options, multipleAnswers: true)
                .assertPollMessage(question: question, optionsCount: options.count, multipleAnswers: true)
        }
        WHEN("user votes for both options") {
            userRobot
                .castPollVote(firstOption)
                .assertPollOption(firstOption, isChecked: true)
                .castPollVote(secondOption)
        }
        THEN("both options are checked") {
            userRobot
                .assertPollOption(secondOption, isChecked: true)
                .assertPollOption(firstOption, isChecked: true)
        }
    }

    func test_participantOptionIsShown_whenParticipantSuggestsPollOption() throws {
        linkToScenario(withId: 12038)

        let suggestedOption = "Green"

        GIVEN("user creates a poll") {
            userRobot
                .login()
                .openChannel()
                .createPoll(question: question, options: options)
                .assertMessageDeliveryStatus(.sent)
        }
        WHEN("participant suggests a new option") {
            participantRobot.addPollOption(suggestedOption)
        }
        THEN("the new option is shown in the poll") {
            userRobot
                .assertPollMessage(question: question, optionsCount: options.count + 1)
                .assertPollOption(suggestedOption, isChecked: false)
        }
    }

    func test_participantCommentIsShown_whenParticipantAddsPollAnswer() throws {
        linkToScenario(withId: 12039)

        GIVEN("user creates a poll") {
            userRobot
                .login()
                .openChannel()
                .createPoll(question: question, options: options)
                .assertMessageDeliveryStatus(.sent)
        }
        WHEN("participant adds a comment to the poll") {
            participantRobot.addPollAnswer("Purple")
        }
        THEN("the poll shows the comment count") {
            userRobot.assertPollComments(count: 1)
        }
    }
}
