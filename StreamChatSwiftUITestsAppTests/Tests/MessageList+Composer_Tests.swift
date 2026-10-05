//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import XCTest

extension MessageList_Tests {
    func test_composerSizeChange() {
        linkToScenario(withId: 12005)

        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        THEN("composer grows when user types multiple lines") {
            userRobot.assertComposerGrows(whenTypingLines: 3)
        }
    }

    func test_composerSizeDoesNotChange() {
        linkToScenario(withId: 12006)

        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        THEN("composer does not grow beyond its limit") {
            userRobot.assertComposerDoesNotGrow(afterLines: 6)
        }
    }

    func test_commandsPopupDisappear_whenUserTapsOnMessageList() {
        linkToScenario(withId: 364)

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(channelsCount: 1, messagesCount: 30)
            userRobot.login().openChannel()
        }
        AND("user opens command suggestions") {
            userRobot
                .typeText("/")
                .assertComposerCommands(shouldBeVisible: true)
        }
        WHEN("user taps on message list") {
            userRobot.tapOnMessageList()
        }
        THEN("command suggestions disappear") {
            userRobot.assertComposerCommands(shouldBeVisible: false)
        }
    }
}
