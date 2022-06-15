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
//        linkToScenario(withId: 25)

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
//        linkToScenario(withId: 26)

        let message = "message"

        GIVEN("user opens the channel") {
            userRobot
                .login()
                .openChannel()
        }
        WHEN("participant sends a message") {
            participantRobot
                .startTyping()
                .stopTyping()
                .sendMessage(message)
        }
        THEN("MessageList updates for user") {
            userRobot.assertMessage(message)
        }
    }

    func test_editsMessage() throws {
//        linkToScenario(withId: 39)
        
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
//        linkToScenario(withId: 37)
        
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
//        linkToScenario(withId: 64)
        
        let message = "🚢"
        let author = "Han Solo"
        
        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        WHEN("participant sends the emoji: '\(message)'") {
            participantRobot
                .startTyping()
                .stopTyping()
                .sendMessage(message)
        }
        THEN("the message is delivered") {
            userRobot.assertMessageAuthor(author)
        }
    }
    
    func test_messageDeleted_whenParticipantDeletesMessage() throws {
//        linkToScenario(withId: 38)
        
        let message = "test message"
        
        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        WHEN("participant sends the message: '\(message)'") {
            participantRobot.sendMessage(message)
        }
        AND("participant deletes the message: '\(message)'") {
            participantRobot.deleteMessage()
        }
        THEN("the message is deleted") {
            userRobot.assertDeletedMessage()
        }
    }
    
    func test_messageIsEdited_whenParticipantEditsMessage() throws {
//        linkToScenario(withId: 40)
        
        let message = "test message"
        let editedMessage = "hello"
        
        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        WHEN("participant sends the message: '\(message)'") {
            participantRobot
                .startTyping()
                .stopTyping()
                .sendMessage(message)
        }
        AND("participant edits the message: '\(editedMessage)'") {
            participantRobot.editMessage(editedMessage)
        }
        THEN("the message is edited") {
            userRobot.assertMessage(editedMessage)
        }
    }
    
    func test_messageIncreases_whenUserEditsMessageWithOneLineText() {
//        linkToScenario(withId: 99)

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
//        linkToScenario(withId: 100)
        
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
//        linkToScenario(withId: 57)

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
//        linkToScenario(withId: 73)
        
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

    func test_messageListScrollsDown_whenMessageListIsScrolledUp_andUserSendsNewMessage() {
//        linkToScenario(withId: 193)

        let newMessage = "New message"

        GIVEN("user opens the channel") {
            userRobot
                .login()
                .openChannel()
        }
        AND("channel is scrollable") {
            participantRobot.sendMultipleMessages(repeatingText: "message", count: 50)
        }
        WHEN("user scrolls up") {
            userRobot.scrollMessageListUp()
        }
        AND("user sends a new message") {
            userRobot.sendMessage(newMessage)
        }
        THEN("message list is scrolled down") {
            userRobot.assertMessageIsVisible(newMessage)
        }
    }

    func test_messageListScrollsDown_whenMessageListIsScrolledDown_andUserReceivesNewMessage() {
//        linkToScenario(withId: 75)

        let count = 50
        let message = "message"
        let newMessage = "New message"

        GIVEN("user opens the channel") {
            userRobot
                .login()
                .openChannel()
        }
        AND("channel is scrollable") {
            participantRobot.sendMultipleMessages(repeatingText: message, count: count)
        }
        WHEN("participant sends a message") {
            participantRobot.sendMessage(newMessage)
        }
        THEN("message list is scrolled down") {
            userRobot.assertMessageIsVisible(newMessage)
        }
    }

    func test_messageListDoesNotScrollDown_whenMessageListIsScrolledUp_andUserReceivesNewMessage() {
//        linkToScenario(withId: 194)

        let newMessage = "New message"

        GIVEN("user opens the channel") {
            userRobot
                .login()
                .openChannel()
        }
        AND("channel is scrollable") {
            participantRobot.sendMultipleMessages(repeatingText: "message", count: 50)
        }
        WHEN("user scrolls up") {
            userRobot.scrollMessageListUp()
        }
        AND("participant sends a message") {
            participantRobot.sendMessage(newMessage)
        }
        THEN("message list is scrolled up") {
            userRobot.assertMessageIsNotVisible(newMessage)
        }
    }

}
