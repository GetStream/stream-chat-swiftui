//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import XCTest

extension Reactions_Tests {
    func test_userAddsReactionUsingExtendedReactionsPicker() {
        linkToScenario(withId: 12040)

        let message = "test message"

        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        WHEN("participant sends the message") {
            participantRobot.sendMessage(message)
            userRobot.assertMessage(message)
        }
        AND("user adds the reaction using the extended reactions picker") {
            userRobot.toggleReactionUsingExtendedPicker(type: .lol)
        }
        THEN("the reaction is added") {
            userRobot.assertReaction(type: .lol, isPresent: true)
        }
    }

    func test_userRemovesReactionUsingExtendedReactionsPicker() {
        linkToScenario(withId: 12041)

        let message = "test message"

        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        AND("participant sends the message") {
            participantRobot.sendMessage(message)
            userRobot.assertMessage(message)
        }
        AND("user adds the reaction using the extended reactions picker") {
            userRobot
                .toggleReactionUsingExtendedPicker(type: .lol)
                .assertReaction(type: .lol, isPresent: true)
        }
        WHEN("user selects the same reaction in the extended reactions picker") {
            userRobot.toggleReactionUsingExtendedPicker(type: .lol)
        }
        THEN("the reaction is removed") {
            userRobot.assertReaction(type: .lol, isPresent: false)
        }
    }

    func test_reactionAuthorsSheetIsShown_whenUserTapsOnReaction() {
        linkToScenario(withId: 12042)

        let message = "test message"

        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        AND("participant sends the message") {
            participantRobot.sendMessage(message)
            userRobot.assertMessage(message)
        }
        AND("participant adds the reaction") {
            participantRobot.addReaction(type: .love)
            userRobot.assertReaction(type: .love, isPresent: true)
        }
        WHEN("user taps on the message reaction") {
            userRobot.tapOnMessageReactions()
        }
        THEN("the reaction authors sheet shows the participant") {
            userRobot.assertReactionAuthor(participantRobot.name)
        }
    }

    func test_userAddsReactionWhileOffline() throws {
        linkToScenario(withId: 12043)

        let message = "test message"

        GIVEN("user opens the channel") {
            userRobot
                .setConnectivitySwitchVisibility(to: .on)
                .login()
                .openChannel()
        }
        AND("user sends a message") {
            userRobot.sendMessage(message)
        }
        AND("user becomes offline") {
            userRobot.setConnectivity(to: .off)
        }
        WHEN("user adds a reaction") {
            userRobot.addReaction(type: .like)
        }
        THEN("user observes a new reaction") {
            userRobot.assertReaction(type: .like, isPresent: true)
        }
        WHEN("user becomes online") {
            userRobot.setConnectivity(to: .on)
        }
        THEN("user still observes a new reaction") {
            userRobot.assertReaction(type: .like, isPresent: true)
        }
    }

    func test_reactionIsAddedByParticipant_toThreadReply() {
        linkToScenario(withId: 12044)

        let message = "message"
        let threadReply = "thread reply"

        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        AND("participant sends a message") {
            participantRobot.sendMessage(message)
            userRobot.assertMessage(message)
        }
        AND("user replies to the message in thread") {
            userRobot.sendMessageInThread(threadReply)
        }
        WHEN("participant adds a reaction to the thread reply") {
            participantRobot.addReaction(type: .wow)
        }
        THEN("user observes the reaction on the thread reply") {
            userRobot
                .assertThreadReply(threadReply)
                .assertReaction(type: .wow, isPresent: true)
        }
    }
}
