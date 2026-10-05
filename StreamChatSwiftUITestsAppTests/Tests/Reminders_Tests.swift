//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import XCTest

final class Reminders_Tests: StreamTestCase {
    let sampleText = "Test"
    let oneHourInSeconds = 3600

    override func setUpWithError() throws {
        try super.setUpWithError()
        backendRobot.setMessageReminders(enabled: true)
    }

    func test_reminderSavedForLaterIsShownOnTheMessage() {
        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        AND("participant sends the message") {
            participantRobot.sendMessage(sampleText)
        }
        AND("the message is saved for later") {
            userRobot.assertMessage(sampleText)
            backendRobot.createReminder()
        }
        WHEN("user reopens the channel") {
            userRobot
                .moveToChannelListFromMessageList()
                .openChannel()
        }
        THEN("the message is shown as saved for later") {
            userRobot.assertMessageReminder(remindAtIsSet: false)
        }
    }

    func test_scheduledReminderIsShownOnTheMessage() {
        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        AND("participant sends the message") {
            participantRobot.sendMessage(sampleText)
        }
        AND("a reminder for the message is due in one hour") {
            userRobot.assertMessage(sampleText)
            backendRobot.createReminder(remindAtSeconds: oneHourInSeconds)
        }
        WHEN("user reopens the channel") {
            userRobot
                .moveToChannelListFromMessageList()
                .openChannel()
        }
        THEN("the message shows when the reminder is due") {
            userRobot.assertMessageReminder(remindAtIsSet: true)
        }
    }
}
