//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import XCTest

final class ChannelActions_Tests: StreamTestCase {
    func test_channelActionsSheetIsShown_whenUserSwipesTheChannel() {
        linkToScenario(withId: 11980)

        GIVEN("user logs in") {
            userRobot.login().waitForChannelListToLoad()
        }
        WHEN("user swipes the channel and taps on the more action") {
            userRobot
                .swipeChannel()
                .tapOnMoreSwipeAction()
        }
        THEN("the channel actions sheet is shown") {
            userRobot.assertChannelActionsSheetForGroupChannel()
        }
    }

    func test_userOpensChannelInfoFromTheChannelActionsSheet() {
        linkToScenario(withId: 11981)

        var channelName = ""

        GIVEN("user logs in") {
            userRobot.login().waitForChannelListToLoad()
            channelName = ChannelListPage.Attributes.name(in: ChannelListPage.cells.firstMatch).text
        }
        AND("user opens the channel actions sheet") {
            userRobot
                .swipeChannel()
                .tapOnMoreSwipeAction()
        }
        WHEN("user taps on the view info option") {
            userRobot.tapOnViewChannelInfo()
        }
        THEN("the group channel info screen is shown") {
            userRobot.assertGroupChannelInfoScreen(channelName: channelName)
        }
    }

    func test_userLeavesGroupChannel() {
        linkToScenario(withId: 11982)

        GIVEN("user logs in") {
            userRobot.login().waitForChannelListToLoad()
        }
        AND("user opens the channel info from the channel actions sheet") {
            userRobot
                .swipeChannel()
                .tapOnMoreSwipeAction()
                .tapOnViewChannelInfo()
        }
        WHEN("user leaves the group") {
            userRobot.tapOnLeaveGroupInChannelInfo()
        }
        THEN("the channel is gone from the channel list") {
            userRobot.assertChannelListIsEmpty()
        }
    }

    func test_userDeletesGroupChannel() {
        linkToScenario(withId: 11983)

        GIVEN("user logs in") {
            userRobot.login().waitForChannelListToLoad()
        }
        AND("user opens the channel actions sheet") {
            userRobot
                .swipeChannel()
                .tapOnMoreSwipeAction()
        }
        WHEN("user deletes the group") {
            userRobot.tapOnDeleteGroup()
        }
        THEN("the channel is gone from the channel list") {
            userRobot.assertChannelListIsEmpty()
        }
    }

    func test_userUnmutesChannelFromTheSwipeAction() {
        linkToScenario(withId: 11985)

        GIVEN("user logs in") {
            userRobot.login().waitForChannelListToLoad()
        }
        AND("user mutes the channel from the swipe action") {
            userRobot
                .swipeChannel()
                .tapOnMuteSwipeAction()
                .assertChannelIsMuted(true)
        }
        WHEN("user swipes the channel and taps on the unmute action") {
            userRobot
                .swipeChannel()
                .tapOnUnmuteSwipeAction()
        }
        THEN("the channel shows no muted icon") {
            userRobot.assertChannelIsMuted(false)
        }
    }
}
