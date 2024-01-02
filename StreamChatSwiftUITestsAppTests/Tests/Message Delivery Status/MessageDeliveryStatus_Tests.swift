//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import XCTest

final class MessageDeliveryStatus_Tests: StreamTestCase {

    let message = "message"
    var pendingMessage: String { "pending \(message)" }
    var failedMessage: String { "failed \(message)" }

    let threadReply = "thread reply"
    var pendingThreadReply: String { "pending \(threadReply)" }
    var failedThreadReply: String { "failed \(threadReply)" }

    override func setUpWithError() throws {
        try super.setUpWithError()
        addTags([.messageDeliveryStatus])
    }

    // MARK: Message List
    func test_singleCheckmarkShown_whenMessageIsSent() throws {
        linkToScenario(withId: 397)

        throw XCTSkip("Check out SWUI-245")

        GIVEN("user opens chat") {
            userRobot
                .login()
                .openChannel()
        }
        WHEN("user sends a new message") {
            userRobot.sendMessage(message)
        }
        THEN("user spots single checkmark below the message") {
            userRobot
                .assertMessageDeliveryStatus(.sent)
                .assertMessageReadCount(readBy: 0)
        }
    }

    func test_deliveryStatusShowsClocks_whenMessageIsInPendingState() throws {
        linkToScenario(withId: 398)

        throw XCTSkip("Check out SWUI-245")

        GIVEN("user opens the channel") {
            userRobot
                .login()
                .openChannel()
        }
        WHEN("user sends a new message") {
            backendRobot.delayServerResponse(byTimeInterval: 5.0)
            userRobot.sendMessage(pendingMessage, waitForAppearance: false)
        }
        THEN("message delivery status shows clocks") {
            userRobot.assertMessageDeliveryStatus(.pending)
        }
    }

    func test_errorIndicatorShown_whenMessageFailedToBeSent() throws {
        linkToScenario(withId: 399)

        throw XCTSkip("Check out SWUI-245")

        GIVEN("user becomes offline") {
            userRobot
                .setConnectivitySwitchVisibility(to: .on)
                .login()
                .setConnectivity(to: .off)
                .openChannel()

        }
        WHEN("user sends a new message") {
            userRobot.sendMessage(failedMessage, waitForAppearance: false)
        }
        THEN("error indicator is shown for the message") {
            userRobot.assertMessageFailedToBeSent()
        }
        AND("delivery status is hidden") {
            userRobot
                .assertMessageDeliveryStatus(nil)
                .assertMessageReadCount(readBy: 0)
        }
    }

    func test_doubleCheckmarkShown_whenMessageReadByParticipant() throws {
        linkToScenario(withId: 400)

        throw XCTSkip("Check out SWUI-245")

        GIVEN("user opens the channel") {
            userRobot
                .login()
                .openChannel()
        }
        AND("user succesfully sends new message") {
            userRobot.sendMessage(message)
        }
        WHEN("participant reads the user's message") {
            participantRobot.readMessageAfterDelay()
        }
        THEN("user spots double checkmark below the message") {
            userRobot.assertMessageDeliveryStatus(.read)
        }
        AND("user spots read by 1 number below the message") {
            userRobot.assertMessageReadCount(readBy: 1)
        }
    }

    func test_doubleCheckmarkShown_whenNewParticipantAdded() throws {
        linkToScenario(withId: 401)

        throw XCTSkip("Check out SWUI-245")

        GIVEN("user opens the channel") {
            userRobot
                .login()
                .openChannel()
        }
        AND("user succesfully sends new message") {
            userRobot.sendMessage(message)
        }
        AND("message is read by more than 1 participant") {
            participantRobot.readMessageAfterDelay()
            userRobot
                .assertMessageDeliveryStatus(.read)
                .assertMessageReadCount(readBy: 1)
        }
        WHEN("new participant is added to the channel") {
//            userRobot.addParticipant()
        }
        THEN("user spots double checkmark below the message") {
            userRobot.assertMessageDeliveryStatus(.read)
        }
        AND("user see read count 2 below the message") {
            userRobot.assertMessageReadCount(readBy: 2)
        }
    }

    func test_readByDecremented_whenParticipantIsRemoved() throws {
        linkToScenario(withId: 402)

        throw XCTSkip("Check out SWUI-245")

        let participantOne = participantRobot.currentUserId

        GIVEN("user opens the channel") {
            userRobot
                .login()
                .openChannel()
        }
        AND("user succesfully sends new message") {
            userRobot.sendMessage(message)
        }
        AND("is read by participant") {
            participantRobot.readMessageAfterDelay()
            userRobot
                .assertMessageDeliveryStatus(.read)
                .assertMessageReadCount(readBy: 1)
        }
        WHEN("participant is removed from the channel") {
//            userRobot.removeParticipant(withUserId: participantOne)
        }
        THEN("user spots single checkmark below the message") {
            userRobot.assertMessageDeliveryStatus(.sent)
        }
    }

    func test_deliveryStatusShownForTheLastMessageInGroup() throws {
        linkToScenario(withId: 403)
        let secondMessage = "second message"

        throw XCTSkip("Check out SWUI-245")

        GIVEN("user opens the channel") {
            userRobot
                .login()
                .openChannel()
        }
        AND("user succesfully sends new message") {
            userRobot.sendMessage(message)
        }
        AND("delivery status shows single checkmark") {
            userRobot.assertMessageDeliveryStatus(.sent)
        }
        WHEN("user sends another message") {
            userRobot.sendMessage(secondMessage)
        }
        THEN("delivery status for the previous message is hidden") {
            // indexes are reverted
            userRobot
                .assertMessageDeliveryStatus(nil, at: 1)
                .assertMessageDeliveryStatus(.sent, at: 0)
        }
    }

    func test_deliveryStatusHidden_whenMessageIsDeleted() throws {
        linkToScenario(withId: 404)

        throw XCTSkip("Check out SWUI-245")

        GIVEN("user opens the channel") {
            userRobot
                .login()
                .openChannel()
        }
        AND("user succesfully sends new message") {
            userRobot.sendMessage(message)
        }
        AND("delivery status shows single checkmark") {
            userRobot.assertMessageDeliveryStatus(.sent)
        }
        WHEN("user removes the message") {
            userRobot.deleteMessage()
        }
        THEN("delivery status is hidden") {
            userRobot
                .assertMessageDeliveryStatus(nil)
                .assertMessageReadCount(readBy: 0)
        }
    }
}

// MARK: Thread Reply

extension MessageDeliveryStatus_Tests {

    // MARK: Thread Previews
    func test_singleCheckmarkShown_whenMessageIsSent_andPreviewedInThread() throws {
        linkToScenario(withId: 405)

        throw XCTSkip("Check out SWUI-245")

        GIVEN("user opens chat") {
            userRobot
                .login()
                .openChannel()
        }
        AND("user succesfully sends a new message") {
            userRobot.sendMessage(message)
        }
        WHEN("user previews thread for message: \(message)") {
            userRobot.openThread()
        }
        THEN("user spots single checkmark below the message") {
            userRobot
                .assertMessageDeliveryStatus(.sent)
                .assertMessageReadCount(readBy: 0)
        }
    }

    func test_errorIndicatorShown_whenMessageFailedToBeSent_andCantBePreviewedInThread() throws {
        linkToScenario(withId: 406)

        throw XCTSkip("Check out SWUI-245")

        GIVEN("user becomes offline") {
            userRobot
                .setConnectivitySwitchVisibility(to: .on)
                .login()
                .setConnectivity(to: .off)
                .openChannel()
        }
        WHEN("user sends a new message") {
            userRobot.sendMessage(failedMessage, waitForAppearance: false)
        }
        THEN("error indicator is shown for the message") {
            userRobot.assertMessageFailedToBeSent()
        }
        AND("delivery status is not shown") {
            userRobot
                .assertMessageDeliveryStatus(nil)
                .assertMessageReadCount(readBy: 0)
        }
        AND("user can't preview this message in thread") {
            userRobot.assertContextMenuOptionNotAvailable(option: .threadReply)
        }
    }

    func test_doubleCheckmarkShown_whenMessageReadByParticipant_andPreviewedInThread() throws {
        linkToScenario(withId: 407)

        throw XCTSkip("Check out SWUI-245")

        GIVEN("user opens the channel") {
            userRobot
                .login()
                .openChannel()
        }
        AND("user succesfully sends new message") {
            userRobot.sendMessage(message)
        }
        AND("user previews thread for read message: \(message)") {
            userRobot.openThread()
        }
        WHEN("the message is read by participant") {
            participantRobot.readMessageAfterDelay()
        }
        THEN("user spots double checkmark below the message in thread") {
            userRobot.assertMessageDeliveryStatus(.read)
        }
        AND("user spots read by 1 number below the message") {
            userRobot.assertMessageReadCount(readBy: 1)
        }
    }

    // MARK: Thread Replies

    func test_singleCheckmarkShown_whenThreadReplyIsSent() throws {
        linkToScenario(withId: 408)

        throw XCTSkip("Check out SWUI-245")

        GIVEN("user opens chat") {
            userRobot
                .login()
                .openChannel()
        }
        WHEN("participant sends a new message") {
            participantRobot.sendMessage(message)
        }
        AND("user replies to the message in thread") {
            userRobot.replyToMessageInThread(threadReply)
        }
        THEN("user spots single checkmark below the thread reply") {
            userRobot
                .assertThreadReplyDeliveryStatus(.sent)
                .assertMessageReadCount(readBy: 0)
        }
    }

    func test_errorIndicatorShown_whenThreadReplyFailedToBeSent() throws {
        linkToScenario(withId: 409)

        throw XCTSkip("Check out SWUI-245")

        GIVEN("user becomes offline") {
            backendRobot.generateChannels(count: 1, messagesCount: 1)
            userRobot
                .setConnectivitySwitchVisibility(to: .on)
                .login()
                .setConnectivity(to: .off)
                .openChannel()
        }
        WHEN("user replies to message in thread") {
            userRobot.replyToMessageInThread(failedThreadReply, waitForAppearance: false)
        }
        THEN("error indicator is shown for the thread reply") {
            userRobot.assertThreadReplyFailedToBeSent()
        }
        AND("delivery status is not shown") {
            userRobot
                .assertThreadReplyDeliveryStatus(nil)
                .assertThreadReplyReadCount(readBy: 0)
        }
    }

    func test_doubleCheckmarkShown_whenThreadReplyReadByParticipant() throws {
        linkToScenario(withId: 410)

        throw XCTSkip("Check out SWUI-245")

        GIVEN("user opens the channel") {
            userRobot
                .login()
                .openChannel()
        }
        AND("participant sends a new message") {
            participantRobot.sendMessage(message)
        }
        WHEN("user replies to message in thread") {
            userRobot.replyToMessageInThread(threadReply)
        }
        AND("participant reads the user's thread reply") {
            participantRobot.readMessageAfterDelay()
        }
        THEN("user spots double checkmark below the message") {
            userRobot.assertMessageDeliveryStatus(.read)
        }
        AND("user spots read by 1 number below the message") {
            userRobot.assertMessageReadCount(readBy: 1)
        }
    }

    func test_doubleCheckmarkShownInThreadReply_whenNewParticipantAdded() throws {
        linkToScenario(withId: 411)

        throw XCTSkip("Check out SWUI-245")

        GIVEN("user opens the channel") {
            userRobot
                .login()
                .openChannel()
        }
        AND("participant sends a new message") {
            participantRobot.sendMessage(message)
        }
        AND("user replies to message in thread") {
            userRobot.replyToMessageInThread(threadReply)
        }
        WHEN("new participant is added to the channel") {
//            userRobot.addParticipant()
        }
        THEN("user spots double checkmark below the thread reply") {
            userRobot.assertMessageDeliveryStatus(.read)
        }
        AND("user see read count 2 below the message") {
            userRobot.assertMessageReadCount(readBy: 1)
        }
    }

    func test_readByDecrementedInThreadReply_whenParticipantIsRemoved() throws {
        linkToScenario(withId: 412)

        throw XCTSkip("Check out SWUI-245")

        let participantOne = participantRobot.currentUserId

        GIVEN("user opens the channel") {
            userRobot
                .login()
                .openChannel()
        }
        AND("participant sends a new message") {
            participantRobot.sendMessage(message)
        }
        AND("user replies to message in thread") {
            userRobot.replyToMessageInThread(threadReply)
        }
        AND("thread reply is read by participant") {
            participantRobot.readMessageAfterDelay()
            userRobot
                .assertMessageDeliveryStatus(.read)
                .assertMessageReadCount(readBy: 1)
        }
        WHEN("participant is removed from the channel") {
//            userRobot.removeParticipant(withUserId: participantOne)
        }
        THEN("user spots single checkmark below the message") {
            userRobot.assertMessageDeliveryStatus(.sent)
        }
    }

    func test_deliveryStatusShownForTheLastThreadReplyInGroup() throws {
        linkToScenario(withId: 413)

        throw XCTSkip("Check out SWUI-245")

        let secondMessage = "second message"

        GIVEN("user opens the channel") {
            userRobot
                .login()
                .openChannel()
        }
        AND("participant sends a new message") {
            participantRobot.sendMessage(message)
        }
        AND("user replies to message in thread") {
            userRobot.replyToMessageInThread(threadReply)
        }
        AND("delivery status shows single checkmark") {
            userRobot.assertMessageDeliveryStatus(.sent)
        }
        WHEN("user sends another message") {
            userRobot.sendMessage(secondMessage)
        }
        THEN("delivery status for the previous message is hidden") {
            // indexes are reverted
            userRobot
                .assertMessageDeliveryStatus(nil, at: 1)
                .assertMessageDeliveryStatus(.sent, at: 0)
        }
    }

    func test_deliveryStatusHidden_whenThreadReplyIsDeleted() throws {
        linkToScenario(withId: 414)

        throw XCTSkip("Check out SWUI-245")

        GIVEN("user opens the channel") {
            userRobot
                .login()
                .openChannel()
        }
        AND("participant sends a new message") {
            participantRobot.sendMessage(message)
        }
        AND("user replies to message in thread") {
            userRobot.replyToMessageInThread(threadReply)
        }
        AND("delivery status shows single checkmark") {
            userRobot.assertMessageDeliveryStatus(.sent)
        }
        WHEN("user removes the message") {
            userRobot.deleteMessage()
        }
        THEN("delivery status is hidden") {
            userRobot
                .assertMessageDeliveryStatus(nil)
                .assertMessageReadCount(readBy: 0)
        }
    }

    func test_deliveryStatusShownForPreviousMessage_whenErrorMessageShown() throws {
        linkToScenario(withId: 415)

        throw XCTSkip("Check out SWUI-245")

        GIVEN("user opens the channel") {
            userRobot
                .login()
                .openChannel()
        }
        AND("succesfully sends a new message") {
            userRobot.sendMessage(message)
        }
        WHEN("user sends message with invalid command") {
            userRobot.sendMessage("/command", waitForAppearance: false)
        }
        THEN("delivery status is shown for \(message)") {
            userRobot
                .assertMessageDeliveryStatus(.sent, at: 1)
                .assertMessageReadCount(readBy: 0, at: 1)
                .assertMessageDeliveryStatus(nil, at: 0)
                .assertMessageReadCount(readBy: 0, at: 0)
        }
    }
}

// MARK: Disabled Read Events feature

extension MessageDeliveryStatus_Tests {

    // MARK: Messages

    func test_deliveryStatusHidden_whenMessageIsSentAndReadEventsIsDisabled() throws {
        linkToScenario(withId: 416)

        throw XCTSkip("Check out SWUI-245")

        GIVEN("user opens chat") {
            backendRobot.setReadEvents(to: false)
            userRobot
                .login()
                .openChannel()
        }
        WHEN("user sends a new message") {
            userRobot.sendMessage(message)
        }
        THEN("delivery status is hidden") {
            userRobot
                .assertMessageDeliveryStatus(nil)
                .assertMessageReadCount(readBy: 0)
        }
    }

    func test_deliveryStatusShowsClocks_whenMessageIsInPendingStateAndReadEventsIsDisabled() throws {
        linkToScenario(withId: 417)

        throw XCTSkip("Check out SWUI-245")

        GIVEN("user opens the channel") {
            backendRobot.setReadEvents(to: false)
            userRobot
                .login()
                .openChannel()
        }
        WHEN("user sends a new message") {
            backendRobot.delayServerResponse(byTimeInterval: 5.0)
            userRobot.sendMessage(pendingMessage, waitForAppearance: false)
        }
        THEN("message delivery status shows clocks") {
            userRobot
                .assertMessageDeliveryStatus(.pending)
                .assertMessageReadCount(readBy: 0)
        }
    }

    func test_errorIndicatorShown_whenMessageFailedToBeSentAndReadEventsIsDisabled() throws {
        linkToScenario(withId: 418)

        throw XCTSkip("Check out SWUI-245")

        GIVEN("user becomes offline") {
            backendRobot.setReadEvents(to: false)
            userRobot
                .setConnectivitySwitchVisibility(to: .on)
                .login()
                .setConnectivity(to: .off)
                .openChannel()
        }
        WHEN("user sends a new message") {
            userRobot.sendMessage(failedMessage, waitForAppearance: false)
        }
        THEN("error indicator is shown for the message") {
            userRobot.assertMessageFailedToBeSent()
        }
        AND("delivery status is hidden") {
            userRobot
                .assertMessageDeliveryStatus(nil)
                .assertMessageReadCount(readBy: 0)
        }
    }

    func test_deliveryStatusHidden_whenMessageReadByParticipantAndReadEventsIsDisabled() throws {
        linkToScenario(withId: 419)

        throw XCTSkip("Check out SWUI-245")

        GIVEN("user opens the channel") {
            backendRobot.setReadEvents(to: false)
            userRobot
                .login()
                .openChannel()
        }
        AND("user succesfully sends new message") {
            userRobot.sendMessage(message)
        }
        WHEN("participant reads the user's message") {
            participantRobot.readMessageAfterDelay()
        }
        THEN("delivery status is hidden") {
            userRobot
                .assertMessageDeliveryStatus(nil)
                .assertMessageReadCount(readBy: 0)
        }
    }

    func test_deliveryStatusHidden_whenNewParticipantAddedAndReadEventsIsDisabled() throws {
        linkToScenario(withId: 420)

        throw XCTSkip("Check out SWUI-245")

        GIVEN("user opens the channel") {
            backendRobot.setReadEvents(to: false)
            userRobot
                .login()
                .openChannel()
        }
        AND("user succesfully sends new message") {
            userRobot.sendMessage(message)
        }
        AND("message is read by more than 1 participant") {
            participantRobot.readMessageAfterDelay()
        }
        WHEN("new participant is added to the channel") {
//            userRobot.addParticipant()
        }
        THEN("delivery status is hidden") {
            userRobot
                .assertMessageDeliveryStatus(nil)
                .assertMessageReadCount(readBy: 0)
        }
    }

    func test_deliveryStatusHidden_whenParticipantIsRemovedAndReadEventsIsDisabled() throws {
        linkToScenario(withId: 421)

        throw XCTSkip("Check out SWUI-245")

        let participantOne = participantRobot.currentUserId

        GIVEN("user opens the channel") {
            backendRobot.setReadEvents(to: false)
            userRobot
                .login()
                .openChannel()
        }
        AND("user succesfully sends new message") {
            userRobot.sendMessage(message)
        }
        AND("is read by participant") {
            participantRobot.readMessageAfterDelay()
        }
        WHEN("participant is removed from the channel") {
//            userRobot.removeParticipant(withUserId: participantOne)
        }
        AND("delivery status is hidden") {
            userRobot.assertMessageDeliveryStatus(nil)
        }
        AND("user doesn't see read count") {
            userRobot.assertMessageReadCount(readBy: 0)
        }
    }

    func test_deliveryStatusHiddenForMessagesInGroup_whenReadEventsIsDisabled() throws {
        linkToScenario(withId: 422)

        throw XCTSkip("Check out SWUI-245")

        let secondMessage = "second message"

        GIVEN("user opens the channel") {
            backendRobot.setReadEvents(to: false)
            userRobot
                .login()
                .openChannel()
        }
        AND("user succesfully sends new message") {
            userRobot.sendMessage(message)
        }
        AND("delivery status is hidden") {
            userRobot.assertMessageDeliveryStatus(nil)
        }
        WHEN("user sends another message") {
            userRobot.sendMessage(secondMessage)
        }
        THEN("delivery status is hidden for all messages") {
            // indexes are reverted
            userRobot
                .assertMessageDeliveryStatus(nil, at: 1)
                .assertMessageDeliveryStatus(nil, at: 0)
        }
    }

    func test_deliveryStatusHidden_whenMessageIsDeletedAndReadEventsIsDisabled() throws {
        linkToScenario(withId: 423)

        throw XCTSkip("Check out SWUI-245")

        GIVEN("user opens the channel") {
            backendRobot.setReadEvents(to: false)
            userRobot
                .login()
                .openChannel()
        }
        AND("user succesfully sends new message") {
            userRobot.sendMessage(message)
        }
        AND("delivery status is hidden") {
            userRobot.assertMessageDeliveryStatus(nil)
        }
        WHEN("user removes the message") {
            userRobot.deleteMessage()
        }
        THEN("delivery status stays hidden") {
            userRobot
                .assertMessageDeliveryStatus(nil)
                .assertMessageReadCount(readBy: 0)
        }
    }
}
