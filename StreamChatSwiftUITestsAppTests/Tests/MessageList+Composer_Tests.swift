//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import XCTest

extension MessageList_Tests {
    func test_composerSizeChange() {
        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        THEN("composer grows when user types multiple lines") {
            userRobot.assertComposerGrows(whenTypingLines: 3)
        }
    }

    func test_composerSizeDoesNotChange() {
        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        THEN("composer does not grow beyond its limit") {
            userRobot.assertComposerDoesNotGrow(afterLines: 6)
        }
    }

    func test_commandsPopupDisappear_whenUserTapsOnMessageList() {
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
