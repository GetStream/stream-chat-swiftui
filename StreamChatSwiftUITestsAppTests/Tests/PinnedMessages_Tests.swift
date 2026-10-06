//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import XCTest

final class PinnedMessages_Tests: StreamTestCase {
    let sampleText = "Test"

    func test_userUnpinsMessage() {
        linkToScenario(withId: 12025)

        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        AND("participant sends the message") {
            participantRobot.sendMessage(sampleText)
        }
        AND("user pins the message") {
            userRobot
                .assertMessage(sampleText)
                .pinMessage()
                .assertMessagePinnedLabel()
        }
        WHEN("user unpins the message") {
            userRobot.unpinMessage()
        }
        THEN("the message shows no pinned label") {
            userRobot.assertMessagePinnedLabel(isDisplayed: false)
        }
    }

    func test_participantUnpinsMessage() {
        linkToScenario(withId: 12027)

        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        AND("user sends the message") {
            userRobot.sendMessage(sampleText)
        }
        AND("the message is delivered") {
            userRobot.assertMessageDeliveryStatus(.sent)
        }
        AND("participant pins the message") {
            participantRobot.pinMesage()
        }
        AND("the message shows the pinned by participant label") {
            userRobot.assertMessagePinnedLabel(pinnedBy: participantRobot.name)
        }
        WHEN("participant unpins the message") {
            participantRobot.unpinMesage()
        }
        THEN("the message shows no pinned label") {
            userRobot.assertMessagePinnedLabel(pinnedBy: participantRobot.name, isDisplayed: false)
        }
    }

    func test_unpinnedMessageIsNotShownOnThePinnedMessagesScreen() {
        linkToScenario(withId: 12029)

        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        AND("participant sends the message") {
            participantRobot.sendMessage(sampleText)
        }
        AND("user pins the message") {
            userRobot
                .assertMessage(sampleText)
                .pinMessage()
                .assertMessagePinnedLabel()
        }
        WHEN("user unpins the message") {
            userRobot
                .unpinMessage()
                .assertMessagePinnedLabel(isDisplayed: false)
        }
        AND("user opens the pinned messages screen") {
            userRobot.openPinnedMessages()
        }
        THEN("no pinned message is shown") {
            userRobot
                .assertPinnedMessagesScreen()
                .assertPinnedMessagesAreEmpty()
        }
    }

    func test_userOpensMessageFromPinnedMessagesScreen() {
        linkToScenario(withId: 12030)

        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        AND("participant sends the message") {
            participantRobot.sendMessage(sampleText)
        }
        AND("user pins the message") {
            userRobot
                .assertMessage(sampleText)
                .pinMessage()
                .assertMessagePinnedLabel()
        }
        WHEN("user taps on the message on the pinned messages screen") {
            userRobot
                .openPinnedMessages()
                .assertMessageInPinnedMessages(sampleText)
                .openPinnedMessage(withText: sampleText)
        }
        THEN("the pinned message is shown in the channel") {
            userRobot
                .assertMessage(sampleText)
                .assertMessagePinnedLabel()
        }
    }

    func test_userPinsThreadReply() {
        linkToScenario(withId: 12031)

        let replyText = "Reply"

        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        AND("participant sends the message") {
            participantRobot.sendMessage(sampleText)
        }
        AND("user opens the thread") {
            userRobot.assertMessage(sampleText).openThread()
        }
        AND("participant replies in the thread") {
            participantRobot.sendMessageInThread(replyText)
        }
        WHEN("user pins the thread reply") {
            userRobot.pinMessage(replyText)
        }
        THEN("the thread reply shows the pinned by you label") {
            userRobot.assertMessagePinnedLabel(messageText: replyText)
        }
    }
}
