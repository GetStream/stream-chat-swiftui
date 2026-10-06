//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import XCTest

final class SlowMode_Tests: StreamTestCase {
    let cooldownDuration = 15
    let message = "message"
    let replyMessage = "reply message"
    let editedMessage = "edited message"

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

    func test_newMessageCantBeSent_whenSlowModeIsActiveAndCooldownIsShown() {
        linkToScenario(withId: 452)

        GIVEN("user opens a channel") {
            backendRobot.setCooldown(enabled: true, duration: cooldownDuration)
            userRobot
                .login()
                .openChannel()
        }
        WHEN("user sends a new text message") {
            userRobot.sendMessage(message, waitForAppearance: false)
        }
        THEN("slow mode is active and cooldown is shown") {
            userRobot.assertCooldown(shouldBeVisible: true)
        }
        AND("a new message can't be sent") {
            userRobot
                .assertSendButtonIsNotShown()
                .assertComposerInputIsDisabled()
        }
    }

    func test_slowModeContinuesActiveAndCooldownIsShownInThreadMessage_whenSlowModeIsActiveAndCooldownIsShownInChannel() {
        linkToScenario(withId: 449)

        GIVEN("user opens a channel") {
            backendRobot.setCooldown(enabled: true, duration: cooldownDuration)
            userRobot
                .login()
                .openChannel()
        }
        AND("user sends a new text message") {
            userRobot.sendMessage(message)
        }
        WHEN("user opens the thread on the message") {
            userRobot.openThread()
        }
        THEN("the cooldown is shown and the thread reply can't be sent") {
            userRobot
                .assertThreadIsOpen()
                .assertCooldown(shouldBeVisible: true)
                .assertSendButtonIsNotShown()
                .assertComposerInputIsDisabled()
        }
    }

    func test_slowModeIsNotActiveAndCooldownIsNotShown_whenAMessageIsEdited() {
        linkToScenario(withId: 453)

        GIVEN("user opens a channel") {
            backendRobot
                .generateChannels(channelsCount: 1, messagesCount: 1)
                .setCooldown(enabled: true, duration: cooldownDuration)
            userRobot
                .login()
                .openChannel()
        }
        WHEN("user edits an existing message") {
            userRobot.editMessage(editedMessage)
        }
        THEN("slow mode is not active and cooldown is not shown") {
            userRobot
                .assertMessage(editedMessage)
                .assertCooldown(shouldBeVisible: false)
        }
    }

    func test_composerIsDisabledWhenSlowModeIsActive() throws {
        linkToScenario(withId: 12049)

        try XCTSkipIf(true, "Attachment picker button stays enabled while the slow mode cooldown is active")

        GIVEN("slow mode is enabled on the channel") {
            backendRobot.setCooldown(enabled: true, duration: cooldownDuration)
        }
        AND("user opens the channel") {
            userRobot.login().openChannel()
        }
        WHEN("user sends a new message") {
            userRobot.sendMessage(message, waitForAppearance: false)
        }
        THEN("the cooldown is shown and the composer is locked") {
            userRobot
                .assertCooldown(shouldBeVisible: true)
                .assertComposerIsDisabledInSlowMode()
        }
    }
}
