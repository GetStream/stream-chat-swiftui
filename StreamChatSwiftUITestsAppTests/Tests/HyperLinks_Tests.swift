//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import XCTest

final class HyperLinks_Tests: StreamTestCase {
    private let giphyGifLink = "Look at https://giphy.com/gifs/test-gw3IWyGkC0rsazTi"

    func test_giphyLinkPreview() {
        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        WHEN("user sends a giphy url") {
            userRobot.sendMessage(giphyGifLink)
        }
        THEN("user observes a message with link preview") {
            userRobot
                .assertMessage(giphyGifLink)
                .assertLinkPreviewInMessageList()
        }
    }

    func test_participantSendsLinkToGiphy() {
        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        WHEN("participant sends a giphy url") {
            participantRobot.sendMessage(giphyGifLink)
        }
        THEN("user observes a message with link preview") {
            userRobot
                .assertMessage(giphyGifLink)
                .assertLinkPreviewInMessageList()
        }
    }

    func test_messageWithLinkOpensSafari() {
        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        WHEN("user sends a message with YouTube link") {
            userRobot
                .sendMessage("Some link: https://youtube.com")
                .scrollMessageListDown() // to hide the keyboard
        }
        THEN("user observes safari opening") {
            userRobot.assertLinkOpensSafari()
        }
    }

    func test_messageWithLinkOpensSafari_whenNoHttpScheme() {
        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        WHEN("user sends a message with YouTube link without https://") {
            userRobot
                .sendMessage("Some link: youtube.com")
                .scrollMessageListDown() // to hide the keyboard
        }
        THEN("user observes safari opening") {
            userRobot.assertLinkOpensSafari()
        }
    }
}
