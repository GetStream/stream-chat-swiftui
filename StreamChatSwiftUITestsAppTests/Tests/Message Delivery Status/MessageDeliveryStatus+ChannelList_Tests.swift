//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import XCTest

final class MessageDeliveryStatus_ChannelList_Tests: StreamTestCase {
    let message = "message"
    var failedMessage: String { "failed \(message)" }

    let threadReply = "thread reply"
    var pendingThreadReply: String { "pending \(threadReply)" }
    var failedThreadReply: String { "failed \(threadReply)" }

    func test_deliveryStatusClocksShownInPreview_whenTheLastMessageIsInPendingState() throws {
        linkToScenario(withId: 424)

        GIVEN("user opens the channel") {
            userRobot
                .login()
                .openChannel()
        }
        AND("user sends new message") {
            backendRobot.delayNewMessages(by: 10)
            userRobot.sendMessage(message, waitForAppearance: false)
        }
        WHEN("user retuns to the channel list before the message is sent") {
            userRobot.tapOnBackButton()
        }
        THEN("last message delivery status in the channel preview shows clocks on the left") {
            userRobot.assertMessageDeliveryStatusInChannelPreview(.pending)
        }
    }

    func test_errorIndicatorShownInPreview_whenMessageFailedToBeSent() throws {
        linkToScenario(withId: 426)

        try XCTSkipIf(true, "Channel preview keeps the pending clock instead of the failed-to-send state")

        GIVEN("user opens the channel") {
            userRobot
                .setConnectivitySwitchVisibility(to: .on)
                .login()
                .openChannel()
        }
        AND("user's message is not sent") {
            userRobot
                .setConnectivity(to: .off)
                .sendMessage(failedMessage, waitForAppearance: false)
                .assertMessageFailedToBeSent()
        }
        WHEN("user retuns to the channel list") {
            userRobot.tapOnBackButton()
        }
        THEN("error indicator is shown in the channel preview instead of the delivery status") {
            userRobot
                .assertLastMessageInChannelPreview("Message failed to send")
                .assertMessageDeliveryStatusInChannelPreview(nil)
        }
    }
}

// MARK: Thread Reply

extension MessageDeliveryStatus_ChannelList_Tests {
    func test_singleCheckmarkShownForMessageInPreview_whenThreadReplyFailedToBeSent() throws {
        linkToScenario(withId: 431)
        
        GIVEN("user opens the channel") {
            userRobot
                .setConnectivitySwitchVisibility(to: .on)
                .login()
                .openChannel()
        }
        AND("user sends a new message") {
            userRobot.sendMessage(message)
        }
        AND("user becomes offline") {
            userRobot.setConnectivity(to: .off)
        }
        AND("user replies to message in thread") {
            userRobot.sendMessageInThread(failedThreadReply, waitForAppearance: false)
        }
        WHEN("user retuns to the channel list") {
            userRobot.moveToChannelListFromThreadReplies()
        }
        THEN("delivery status shows single checkmark for the last channel message") {
            userRobot
                .assertLastMessageInChannelPreview(message)
                .assertMessageDeliveryStatusInChannelPreview(.sent)
        }
    }
}
