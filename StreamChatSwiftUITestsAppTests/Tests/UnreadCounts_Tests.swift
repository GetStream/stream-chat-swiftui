//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import XCTest

final class UnreadCounts_Tests: StreamTestCase {
    private let sampleText = "Test"
    private let participantMessage = "Participant message"

    func test_newMessageInMutedChannel_doesNotIncrementUnreadCount() {
        linkToScenario(withId: 12092)

        GIVEN("user is in the channel list") {
            userRobot.login().waitForChannelListToLoad()
        }
        AND("user has a muted channel") {
            userRobot
                .swipeChannel()
                .tapOnMuteSwipeAction()
                .assertChannelIsMuted(true)
        }
        WHEN("participant sends a message to the muted channel") {
            participantRobot.sendMessage(participantMessage)
            userRobot.assertChannelPreview(contains: participantMessage)
        }
        THEN("unread messages count is not incremented") {
            userRobot.assertChannelUnreadCount(0)
        }
    }

    func test_newMessageFromMutedUser_doesNotIncrementUnreadCount() {
        linkToScenario(withId: 12093)

        GIVEN("user opens an unmuted channel") {
            userRobot.login().openChannel()
        }
        AND("the channel has muted participant") {
            participantRobot.sendMessage(sampleText)
            userRobot
                .muteMessageAuthor(sampleText)
                .assertMuteMessageAuthorOption(sampleText, isAuthorMuted: true)
        }
        AND("user is in the channel list") {
            userRobot.moveToChannelListFromMessageList()
        }
        WHEN("muted participant sends a message to the channel") {
            participantRobot.sendMessage(participantMessage)
            userRobot.assertChannelPreview(contains: participantMessage)
        }
        THEN("unread messages count is not incremented") {
            userRobot.assertChannelUnreadCount(0)
        }
    }

    func test_newSystemMessage_incrementsUnreadCount() {
        linkToScenario(withId: 12094)

        let systemMessage = "System message"

        GIVEN("user opens the unmuted channel and sends the message") {
            userRobot.login().openChannel().sendMessage(sampleText)
        }
        AND("the message is delivered") {
            userRobot.assertMessageDeliveryStatus(.sent)
        }
        AND("user moves back to the channel list") {
            userRobot.tapOnBackButton()
        }
        WHEN("participant performs action that results in system message posted to the channel") {
            participantRobot.sendSystemMessage(systemMessage)
        }
        THEN("unread messages count is incremented") {
            userRobot
                .assertChannelPreview(contains: systemMessage)
                .assertChannelUnreadCount(1)
        }
    }

    func test_newThreadReplyAlsoSentInChannel_incrementsUnreadCount() {
        linkToScenario(withId: 12095)

        GIVEN("user opens the unmuted channel and sends the message") {
            userRobot.login().openChannel().sendMessage(sampleText)
        }
        AND("the message is delivered") {
            userRobot.assertMessageDeliveryStatus(.sent)
        }
        AND("user moves back to the channel list") {
            userRobot.tapOnBackButton()
        }
        WHEN("participant sends a thread reply also to the channel") {
            participantRobot.sendMessageInThread(participantMessage, alsoSendInChannel: true)
        }
        THEN("unread messages count is incremented") {
            userRobot
                .assertChannelPreview(contains: participantMessage)
                .assertChannelUnreadCount(1)
        }
    }

    func test_hardDeleteOfUnseenMessage_decrementsUnreadCount() {
        linkToScenario(withId: 12096)

        GIVEN("user opens the unmuted channel and sends the message") {
            userRobot.login().openChannel().sendMessage(sampleText)
        }
        AND("the message is delivered") {
            userRobot.assertMessageDeliveryStatus(.sent)
        }
        AND("user moves back to the channel list") {
            userRobot.tapOnBackButton()
        }
        AND("participant sends a thread reply also to the channel") {
            participantRobot.sendMessageInThread(participantMessage, alsoSendInChannel: true)
        }
        AND("the unread messages count is incremented") {
            userRobot.assertChannelUnreadCount(1)
        }
        WHEN("participant hard deletes the message") {
            participantRobot.deleteMessage(hard: true)
        }
        THEN("unread messages count is decremented") {
            userRobot.assertChannelUnreadCount(0)
        }
    }
}
