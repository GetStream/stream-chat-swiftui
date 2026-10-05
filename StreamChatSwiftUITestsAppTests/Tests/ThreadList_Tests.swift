//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import XCTest

final class ThreadList_Tests: StreamTestCase {
    let parentMessageText = "Test"
    let replyText = "Reply"

    func test_threadListIsEmpty_whenChannelHasNoThreads() {
        GIVEN("user logs in") {
            userRobot.login().waitForChannelListToLoad()
        }
        WHEN("user opens the thread list") {
            userRobot.openThreadList()
        }
        THEN("the thread list is empty") {
            userRobot.assertThreadListIsEmpty()
        }
    }

    func test_threadIsShownOnTheThreadList() {
        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        AND("participant sends the message") {
            participantRobot.sendMessage(parentMessageText)
            userRobot.assertMessage(parentMessageText)
        }
        AND("user replies to the message in the thread") {
            userRobot
                .sendMessageInThread(replyText)
                .assertThreadMessage(replyText)
        }
        WHEN("user opens the thread list") {
            userRobot
                .moveToChannelListFromThreadReplies()
                .openThreadList()
        }
        THEN("the thread is shown with one reply") {
            userRobot.assertThreadInThreadList(parentMessageText: parentMessageText, replies: 1)
        }
    }

    func test_userOpensThreadFromTheThreadList() {
        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        AND("participant sends the message") {
            participantRobot.sendMessage(parentMessageText)
            userRobot.assertMessage(parentMessageText)
        }
        AND("user replies to the message in the thread") {
            userRobot
                .sendMessageInThread(replyText)
                .assertThreadMessage(replyText)
        }
        AND("user opens the thread list") {
            userRobot
                .moveToChannelListFromThreadReplies()
                .openThreadList()
                .assertThreadInThreadList(parentMessageText: parentMessageText, replies: 1)
        }
        WHEN("user taps on the thread") {
            userRobot.openThreadFromThreadList(parentMessageText: parentMessageText)
        }
        THEN("the thread is opened on the reply") {
            userRobot.assertThreadMessage(replyText)
        }
    }

    func test_threadShowsUnreadBadge_whenParticipantRepliesInThread() {
        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        AND("participant sends the message") {
            participantRobot.sendMessage(parentMessageText)
            userRobot.assertMessage(parentMessageText)
        }
        AND("user replies to the message in the thread") {
            userRobot
                .sendMessageInThread(replyText)
                .assertThreadMessage(replyText)
        }
        AND("user opens the thread list") {
            userRobot
                .moveToChannelListFromThreadReplies()
                .openThreadList()
                .assertThreadInThreadList(parentMessageText: parentMessageText, replies: 1)
                .assertThreadUnreadCountInThreadList(0)
        }
        WHEN("participant replies in the thread") {
            participantRobot.sendMessageInThreadNotifyingThreadParticipants(replyText)
        }
        THEN("the thread shows one unread reply") {
            userRobot
                .assertThreadUnreadCountInThreadList(1)
        }
    }
}
