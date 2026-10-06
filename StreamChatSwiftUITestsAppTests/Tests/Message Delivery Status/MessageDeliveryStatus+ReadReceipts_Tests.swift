//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import XCTest

extension MessageDeliveryStatus_Tests {
    func test_doubleCheckmarkShown_whenChannelThreadReplyReadByParticipant() throws {
        linkToScenario(withId: 12109)

        try XCTSkipIf(true, "https://linear.app/stream/issue/IOS-46")

        GIVEN("user opens the channel") {
            userRobot
                .login()
                .openChannel()
        }
        AND("participant sends a new message") {
            participantRobot.sendMessage(message)
        }
        AND("user successfully sends a new thread reply also in the channel") {
            userRobot.sendMessageInThread(threadReply, alsoSendInChannel: true)
        }
        AND("thread reply delivery status shows a single checkmark") {
            userRobot
                .assertThreadReplyDeliveryStatus(.sent)
                .assertMessageDeliveryStatusAnnouncement(.sent)
        }
        WHEN("participant has the channel scrolled to bottom and reads the thread reply") {
            participantRobot.readMessage()
        }
        THEN("thread reply delivery status shows a double checkmark") {
            userRobot
                .assertThreadReplyDeliveryStatus(.read)
                .assertMessageDeliveryStatusAnnouncement(.read)
        }
        AND("thread reply delivery status shows a double checkmark in the channel") {
            userRobot
                .tapOnBackButton()
                .assertMessageDeliveryStatus(.read)
                .assertMessageDeliveryStatusAnnouncement(.read)
        }
    }

    func test_deliveredCheckmarkTurnsRead_whenParticipantScrollsChannelToBottom() {
        linkToScenario(withId: 12110)

        GIVEN("user opens the channel") {
            userRobot
                .login()
                .openChannel()
        }
        AND("user successfully sends a new message") {
            userRobot
                .sendMessage(message)
                .assertMessageDeliveryStatusAnnouncement(.sent)
        }
        AND("participant has the channel scrolled up, so the message is delivered but not read") {
            participantRobot.markMessagesDelivered()
        }
        AND("message delivery status shows a grey double checkmark") {
            userRobot.assertMessageDeliveryStatusAnnouncement(.delivered)
        }
        WHEN("participant scrolls the channel to bottom") {
            participantRobot.readMessage()
        }
        THEN("message delivery status shows a blue double checkmark") {
            userRobot.assertMessageDeliveryStatusAnnouncement(.read)
        }
    }
}
