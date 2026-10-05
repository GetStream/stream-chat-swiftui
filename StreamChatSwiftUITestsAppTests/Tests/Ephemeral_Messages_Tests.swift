//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import XCTest

final class Ephemeral_Messages_Tests: StreamTestCase {
    func test_userObservesAnimatedGiphy_whenParticipantAddsGiphyMessage() throws {
        linkToScenario(withId: 436)

        GIVEN("user opens a channel") {
            userRobot
                .login()
                .openChannel()
        }
        WHEN("participant sends a giphy") {
            participantRobot.uploadGiphy()
        }
        THEN("user observes the animated gif") {
            userRobot.assertGiphyImage()
        }
    }

    func test_messageIsNotSent_whenUserSendsInvalidCommand() throws {
        linkToScenario(withId: 437)

        let message = "message"
        let invalidCommand = "invalid command"

        GIVEN("user opens the channel") {
            userRobot
                .login()
                .openChannel()
        }
        WHEN("user sends a message with invalid command") {
            userRobot
                .sendMessage(message, waitForAppearance: true)
                .sendMessage("/\(invalidCommand)", waitForAppearance: false)
        }
        THEN("user observes error message") {
            userRobot
                .assertInvalidCommand(invalidCommand)
                .assertMessageHasTimestamp(false, at: 0)
                .assertMessageDeliveryStatus(nil, at: 0)
        }
        AND("the previous message has timestamp and delivery status shown") {
            userRobot
                .assertMessageDeliveryStatus(.sent, at: 1)
                .assertMessageHasTimestamp(at: 1)
        }
    }

    func test_channelListNotModified_whenEphemeralMessageShown() throws {
        linkToScenario(withId: 438)

        GIVEN("user opens a channel") {
            userRobot
                .login()
                .openChannel()
        }
        WHEN("user runs a giphy command") {
            userRobot.uploadGiphy(send: false)
        }
        WHEN("user goes back to channel list") {
            userRobot.tapOnBackButton()
        }
        THEN("message is not added to the channel list") {
            userRobot.assertLastMessageInChannelPreview("No messages")
        }
    }

    func test_deliveryStatusHidden_whenEphemeralMessageShown() throws {
        linkToScenario(withId: 439)
        
        try XCTSkipIf(true, "https://linear.app/stream/issue/IOS-1324")

        GIVEN("user opens a channel") {
            userRobot
                .login()
                .openChannel()
        }
        WHEN("user runs a giphy command") {
            userRobot.uploadGiphy(send: false)
        }
        THEN("delivery status is hidden for ephemeral messages") {
            userRobot.assertMessageDeliveryStatus(nil)
        }
    }

    func test_deliveryStatusHidden_whenEphemeralMessageShownInThread() throws {
        linkToScenario(withId: 440)
        
        try XCTSkipIf(true, "https://linear.app/stream/issue/IOS-1324")

        GIVEN("user opens a channel") {
            backendRobot.generateChannels(channelsCount: 1, messagesCount: 1)
            userRobot.login().openChannel()
        }
        WHEN("user runs a giphy command in thread") {
            userRobot
                .openThread()
                .uploadGiphy(send: false)
        }
        THEN("delivery status is hidden for ephemeral messages") {
            userRobot.assertMessageDeliveryStatus(nil)
        }
    }

    func test_userObservesAnimatedGiphy_whenUserAddsGiphyMessage() {
        GIVEN("user opens a channel") {
            userRobot.login().openChannel()
        }
        WHEN("user sends a giphy using giphy command") {
            userRobot.uploadGiphy()
        }
        THEN("user observes the animated gif") {
            userRobot
                .assertGiphyImage()
                .assertGiphyButtons(areDisplayed: false)
        }
    }

    func test_userObservesAnimatedGiphy_afterAddingGiphyThroughComposerMenu() {
        GIVEN("user opens a channel") {
            userRobot.login().openChannel()
        }
        WHEN("user sends a giphy using the composer commands menu") {
            userRobot.uploadGiphy(useComposerCommand: true)
        }
        THEN("user observes the animated gif") {
            userRobot
                .assertGiphyImage()
                .assertGiphyButtons(areDisplayed: false)
        }
    }

    func test_userObservesAnimatedGiphy_whenUserAddsGiphyMessageInThread() {
        GIVEN("user opens a channel") {
            backendRobot.generateChannels(channelsCount: 1, messagesCount: 1)
            userRobot.login().openChannel()
        }
        WHEN("user runs a giphy command in thread") {
            userRobot
                .openThread()
                .uploadGiphy()
        }
        THEN("user observes the animated gif in thread") {
            userRobot.assertGiphyImageInThread()
        }
    }

    func test_userObservesAnimatedGiphy_whenParticipantAddsGiphyMessageInThread() {
        GIVEN("user opens a channel") {
            backendRobot.generateChannels(channelsCount: 1, messagesCount: 1)
            userRobot.login().openChannel()
        }
        WHEN("participant sends a giphy in thread") {
            participantRobot.uploadGiphyInThread()
        }
        THEN("user observes the animated gif in thread") {
            userRobot
                .openThread(waitForThreadIcon: true)
                .assertGiphyImageInThread()
        }
    }

    func test_messageIsNotSent_whenUserCancelsEphemeralMessage() {
        GIVEN("user opens a channel") {
            userRobot.login().openChannel()
        }
        WHEN("user cancels a giphy") {
            userRobot
                .uploadGiphy(send: false)
                .tapOnCancelGiphyButton()
        }
        THEN("user does not observe the animated gif") {
            userRobot
                .assertGiphyImageNotVisible()
                .assertGiphyButtons(areDisplayed: false)
        }
    }

    func test_userObservesAnimatedGiphy_whenUserAddsGiphyMessage_AfterShuffling() {
        GIVEN("user opens a channel") {
            userRobot.login().openChannel()
        }
        WHEN("user shuffles a giphy") {
            userRobot
                .uploadGiphy(send: false)
                .tapOnShuffleGiphyButton()
        }
        THEN("the giphy is shuffled but not sent") {
            userRobot
                .assertEphemeralGiphyImage()
                .assertGiphyButtons(areDisplayed: true)
        }
        WHEN("user sends a giphy") {
            userRobot.tapOnSendGiphyButton()
        }
        THEN("user observes the animated gif") {
            userRobot
                .assertGiphyImage()
                .assertGiphyButtons(areDisplayed: false)
        }
    }
}
