//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import XCTest

final class Logout_Tests: StreamTestCase {
    func test_userLogsInAsAnotherUser_afterLoggingOut() {
        linkToScenario(withId: 12098)

        let firstUserMessage = "message from Luke"
        let message = "message from Han"
        let unreadCount = 2

        GIVEN("user logs in") {
            userRobot
                .login()
                .openChannel()
                .sendMessage(firstUserMessage)
                .tapOnBackButton()
        }
        AND("user logs out") {
            userRobot
                .logoutAndConfirm()
                .assertStartPageIsShown()
        }
        WHEN("user logs in as another user") {
            backendRobot.setAppUser(id: "han_solo", name: "Han Solo")
            userRobot.loginAsSecondUser()
        }
        THEN("user observes channel list") {
            userRobot.waitForChannelListToLoad()
        }
        AND("the previous user's message is shown as someone else's") {
            userRobot
                .openChannel()
                .assertMessage(firstUserMessage)
                .assertMessageAuthor("Luke Skywalker")
        }
        AND("user can send a message") {
            userRobot
                .sendMessage(message)
                .assertMessageDeliveryStatus(.sent)
        }
        AND("unread count updates as expected") {
            userRobot.tapOnBackButton()
            participantRobot.sendMultipleMessages("New", count: unreadCount)
            userRobot.assertChannelUnreadCount(unreadCount)
        }
    }

    func test_channelListIsShown_whenUserLogsOutWhileChannelListIsLoadingAndLogsBackIn() {
        linkToScenario(withId: 12099)

        GIVEN("user logs in") {
            backendRobot.delayChannelList(by: 3)
            userRobot.login()
        }
        AND("user logs out while the loading shimmer effect is happening") {
            userRobot
                .assertChannelListIsLoading()
                .logoutAndConfirm()
        }
        THEN("the crash does not happen") {
            userRobot.assertStartPageIsShown()
        }
        WHEN("user logs in") {
            userRobot.login()
        }
        THEN("user observes channel list") {
            userRobot.waitForChannelListToLoad()
        }
    }
}
