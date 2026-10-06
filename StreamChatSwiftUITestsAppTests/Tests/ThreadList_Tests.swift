//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import XCTest

final class ThreadList_Tests: StreamTestCase {
    let parentMessageText = "Test"
    let replyText = "Reply"

    func test_threadListIsEmpty_whenChannelHasNoThreads() {
        linkToScenario(withId: 12050)

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

    func test_userOpensThreadFromTheThreadList() {
        linkToScenario(withId: 12052)

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
        linkToScenario(withId: 12053)

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
