//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import XCTest

final class SlowMode_Tests: StreamTestCase {
    let cooldownDuration = 5
    let message = "message"
    let anotherNewMessage = "Another new message"
    let replyMessage = "reply message"
    let editedMessage = "edited message"

    func test_slowModeIsActiveAndCooldownIsShown_whenNewMessageIsSent() throws {
        linkToScenario(withId: 450)

        GIVEN("user opens a channel") {
            backendRobot.setCooldown(enabled: true, duration: cooldownDuration)
            userRobot
                .login()
                .openChannel()
        }
        WHEN("user sends a new text message") {
            userRobot
                .assertCooldown(shouldBeVisible: false)
                .sendMessage(message, waitForAppearance: false)
        }
        THEN("slow mode is active and cooldown is shown") {
            userRobot.assertCooldown(shouldBeVisible: true)
        }
    }

    func test_slowModeIsActiveAndCooldownIsShown_whenAMessageIsReplied() throws {
        linkToScenario(withId: 454)

        GIVEN("user opens a channel") {
            backendRobot.setCooldown(enabled: true, duration: cooldownDuration)
            userRobot
                .login()
                .openChannel()
        }
        AND("participant sends a new text message") {
            participantRobot.sendMessage(message)
        }
        AND("user selects reply to a message from context menu") {
            userRobot.selectOptionFromContextMenu(option: .reply)
        }
        WHEN("user types a new text message") {
            userRobot.sendMessage(replyMessage, waitForAppearance: false)
        }
        THEN("slow mode is active and cooldown is shown") {
            userRobot.assertCooldown(shouldBeVisible: true)
        }
        AND("message is sent") {
            userRobot.assertQuotedMessage(replyText: replyMessage, quotedText: message)
        }
    }
}
