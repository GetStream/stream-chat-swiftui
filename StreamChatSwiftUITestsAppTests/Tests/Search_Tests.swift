//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import XCTest

/// The user stays on the channel list while the participant sends the message: the native search bar
/// is gone from the channel list after popping back from a channel in the SwiftUI test app.
final class Search_Tests: StreamTestCase {
    let sampleText = "Test"

    func test_userSearchesForMessage() {
        linkToScenario(withId: 12047)

        GIVEN("user opens the channel list") {
            userRobot.login().waitForChannelListToLoad()
        }
        AND("participant sends the message") {
            participantRobot.sendMessage(sampleText)
            userRobot.assertChannelPreview(contains: sampleText)
        }
        WHEN("user searches for the message on the channel list") {
            userRobot.search(sampleText)
        }
        THEN("the message is shown in the search results") {
            userRobot.assertMessageInSearchResults(sampleText)
        }
    }

    func test_userOpensMessageFromSearchResults() {
        linkToScenario(withId: 12048)

        GIVEN("user opens the channel list") {
            userRobot.login().waitForChannelListToLoad()
        }
        AND("participant sends the message") {
            participantRobot.sendMessage(sampleText)
            userRobot.assertChannelPreview(contains: sampleText)
        }
        AND("user searches for the message on the channel list") {
            userRobot.search(sampleText)
                .assertMessageInSearchResults(sampleText)
        }
        WHEN("user taps on the search result") {
            userRobot.tapOnSearchResult()
        }
        THEN("the message list is opened on the message") {
            userRobot.assertMessage(sampleText)
        }
    }
}
