//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import XCTest

final class MessageList_Tests: StreamTestCase {
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        addTags([.coreFeatures])
    }

    func test_messageListUpdates_whenUserSendsMessage() {
        linkToScenario(withId: 237)

        let message = "message"

        GIVEN("user opens the channel") {
            userRobot
                .login()
                .openChannel()
        }
        WHEN("user sends a message") {
            userRobot.sendMessage(message)
        }
        THEN("message list updates") {
            userRobot.assertMessage(message)
        }
    }

    func test_messageListUpdates_whenParticipantSendsMessage() {
        linkToScenario(withId: 258)

        let message = "message"

        GIVEN("user opens the channel") {
            userRobot
                .login()
                .openChannel()
        }
        WHEN("participant sends a message") {
            participantRobot.sendMessage(message, waitBeforeSending: 0.5)
        }
        THEN("MessageList updates for user") {
            userRobot.assertMessage(message)
        }
    }

    func test_editsMessage() throws {
        linkToScenario(withId: 264)
        
        let message = "test message"
        let editedMessage = "hello"
        
        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        WHEN("user sends the message: '\(message)'") {
            userRobot.sendMessage(message)
        }
        AND("user edits the message: '\(editedMessage)'") {
            userRobot.editMessage(editedMessage)
        }
        THEN("the message is edited") {
            userRobot.assertMessage(editedMessage)
        }
    }
    
    func test_deletesMessage() throws {
        linkToScenario(withId: 262)
        
        let message = "test message"
        
        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        WHEN("user sends the message: '\(message)'") {
            userRobot.sendMessage(message)
        }
        AND("user deletes the message: '\(message)'") {
            userRobot.deleteMessage()
        }
        THEN("the message is deleted") {
            userRobot.assertDeletedMessage()
        }
    }
    
    func test_receivesMessage() throws {
        linkToScenario(withId: 254)
        
        let message = "🚢"
        let author = "Han Solo"
        
        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        WHEN("participant sends the emoji: '\(message)'") {
            participantRobot.sendMessage(message, waitBeforeSending: 0.5)
        }
        THEN("the message is delivered") {
            userRobot.assertMessageAuthor(author)
        }
    }
    
    func test_messageDeleted_whenParticipantDeletesMessage() throws {
        linkToScenario(withId: 261)
        
        let message = "test message"
        
        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        WHEN("participant sends the message: '\(message)'") {
            participantRobot.sendMessage(message, waitBeforeSending: 0.5)
        }
        AND("participant deletes the message: '\(message)'") {
            participantRobot.deleteMessage()
        }
        THEN("the message is deleted") {
            userRobot.assertDeletedMessage()
        }
    }
    
    func test_messageIsEdited_whenParticipantEditsMessage() throws {
        linkToScenario(withId: 266)
        
        let message = "test message"
        let editedMessage = "hello"
        
        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        WHEN("participant sends the message: '\(message)'") {
            participantRobot.sendMessage(message, waitBeforeSending: 0.5)
        }
        AND("participant edits the message: '\(editedMessage)'") {
            participantRobot.editMessage(editedMessage)
        }
        THEN("the message is edited") {
            userRobot.assertMessage(editedMessage)
        }
    }
    
    func test_messageIncreases_whenUserEditsMessageWithOneLineText() {
        linkToScenario(withId: 267)

        let message = "test message"
        
        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        AND("user sends a one line message: '\(message)'") {
            userRobot.sendMessage(message)
        }
        THEN("user verifies that message cell increases after editing") {
            userRobot.assertMessageSizeChangesAfterEditing(linesCountShouldBeIncreased: true)
        }
    }
    
    func test_messageDecreases_whenUserEditsMessage() throws {
        linkToScenario(withId: 259)
        
        let message = "test\nmessage"
        
        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        AND("user sends a two line message: '\(message)'") {
            userRobot.sendMessage(message)
        }
        THEN("user verifies that message cell decreases after editing") {
            userRobot.assertMessageSizeChangesAfterEditing(linesCountShouldBeIncreased: false)
        }
    }

    func test_messageWithMultipleLinesShown_userSendsMessageWithMultipleLines() {
        linkToScenario(withId: 252)

        let message = "1\n2\n3lines increased"
        GIVEN("user opens the channel") {
            userRobot
                .login()
                .openChannel()
        }
        WHEN("user sends a message with N new lines (e.g.: 3)") {
            userRobot.sendMessage(message)
        }
        THEN("user observes a message cell with N lines") {
            userRobot.assertMessage(message)
        }
    }
    
    func test_typingIndicatorHidden_whenParticipantStopsTyping() {
        linkToScenario(withId: 260)
        
        GIVEN("user opens the channel") {
            userRobot
                .login()
                .openChannel()
        }
        WHEN("participant starts typing") {
            participantRobot.startTyping()
        }
        AND("participant stops typing") {
            participantRobot.stopTyping()
        }
        THEN("user observes typing indicator has disappeared") {
            userRobot.assertTypingIndicatorHidden()
        }
    }

}
