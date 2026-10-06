//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import XCTest

final class ChannelList_Tests: StreamTestCase {
    let message = "message"

    func test_participantMessageShownInChannelPreview_whenReturningFromOffline() throws {
        linkToScenario(withId: 349)
        
        GIVEN("user opens the channel") {
            userRobot
                .setConnectivitySwitchVisibility(to: .on)
                .login()
                .openChannel()
                .tapOnBackButton()
        }
        AND("user becomes offline") {
            userRobot.setConnectivity(to: .off)
        }
        WHEN("participant sends a new message") {
            participantRobot
                .sendMessage(message)
                .sleep(2.0)
        }
        AND("user becomes online") {
            userRobot.setConnectivity(to: .on)
        }
        THEN("list shows a preview of participant's message") {
            userRobot.assertLastMessageInChannelPreview(message)
        }
    }

    func test_paginationOnChannelList() throws {
        linkToScenario(withId: 350)

        try XCTSkipIf(true, "Check out SWUI-253")

        let channelsCount = 30

        WHEN("user opens the channel list") {
            backendRobot.generateChannels(channelsCount: channelsCount)
            userRobot.login()
        }
        THEN("user makes sure that all channels are loaded") {
            userRobot.assertChannelListPagination(channelsCount: channelsCount)
        }
    }
}

// MARK: - Preview

extension ChannelList_Tests {
    func test_errorMessageIsNotShownInChannelPreview_whenErrorMessageIsReceived() {
        linkToScenario(withId: 351)

        let message = "message"
        let invalidCommand = "invalid command"

        GIVEN("user opens the channel") {
            userRobot
                .login()
                .openChannel()
        }
        AND("user sends a message with invalid command") {
            userRobot
                .sendMessage(message)
                .sendMessage("/\(invalidCommand)", waitForAppearance: false)
        }
        WHEN("user goes back to the channel list") {
            userRobot.tapOnBackButton()
        }
        THEN("the error message is not shown in preview") {
            userRobot.assertLastMessageInChannelPreview(message)
        }
        AND("last message timestamp is shown") {
            userRobot.assertLastMessageTimestampInChannelPreview(isHidden: false)
        }
    }
}
