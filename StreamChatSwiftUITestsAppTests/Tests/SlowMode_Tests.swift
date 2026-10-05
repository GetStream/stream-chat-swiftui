//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import XCTest

final class SlowMode_Tests: StreamTestCase {
    let cooldownDuration = 15
    let message = "message"
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

    func test_newMessageCantBeSent_whenSlowModeIsActiveAndCooldownIsShown() {
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

    func test_aMessageCantBeReplied_whenSlowModeIsActiveAndCooldownIsShown() {
        GIVEN("user opens a channel") {
            backendRobot.setCooldown(enabled: true, duration: cooldownDuration)
            userRobot
                .login()
                .openChannel()
        }
        AND("user sends a new text message") {
            userRobot.sendMessage(message)
        }
        WHEN("user selects reply to a message from context menu") {
            userRobot.selectOptionFromContextMenu(option: .reply)
        }
        THEN("the cooldown is shown and the reply can't be sent") {
            userRobot
                .assertCooldown(shouldBeVisible: true)
                .assertSendButtonIsNotShown()
                .assertComposerInputIsDisabled()
        }
    }

    func test_slowModeContinuesActiveAndCooldownIsShownInThreadMessage_whenSlowModeIsActiveAndCooldownIsShownInChannel() {
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
