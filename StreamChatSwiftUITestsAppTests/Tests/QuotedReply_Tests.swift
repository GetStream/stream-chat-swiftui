//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import XCTest

final class QuotedReply_Tests: StreamTestCase {
    
    let messageCount = 30
    let parentMessage = "1"
    let quotedMessage = "quoted reply"
    
    override func setUpWithError() throws {
        throw XCTSkip("At the moment, quoted replies do not work well enough on our testing framework")
        
        try super.setUpWithError()
        addTags([.coreFeatures])
        assertMockServer()
    }
    
    override func tearDownWithError() throws {}
    
    func test_quotedReplyInList_whenUserAddsQuotedReply() {
        linkToScenario(withId: 368)
        
        let messageCount = 20
        
        GIVEN("user opens the channel") {
            backendRobot.generateChannels(count: 1, messagesCount: 20)
            userRobot.login().openChannel()
        }
        WHEN("user adds a quoted reply to participant message") {
            userRobot
                .scrollMessageListUp(times: 4)
                .quoteMessage(quotedMessage, messageCellIndex: messageCount - 1, waitForAppearance: false)
                .waitForMessageVisibility(at: 0)
        }
        THEN("user observes the quote reply in message list") {
            userRobot
                .assertQuotedMessage(replyText: quotedMessage, quotedText: parentMessage)
                .assertScrollToBottomButton(isVisible: false)
        }
        WHEN("user taps on a quoted message") {
            userRobot.tapOnQuotedMessage(parentMessage, at: 0)
        }
        THEN("user is scrolled up to the quoted message") {
            userRobot
                .assertMessageIsVisible(at: messageCount)
                .assertScrollToBottomButton(isVisible: true)
        }
    }
    
    func test_quotedReplyInList_whenParticipantAddsQuotedReply_Message() {
        linkToScenario(withId: 369)
        
        let messageCount = 20
        
        GIVEN("user opens the channel") {
            backendRobot.generateChannels(count: 1, messagesCount: messageCount)
            userRobot.login().openChannel()
        }
        WHEN("participant adds a quoted reply") {
            participantRobot.quoteMessage(quotedMessage, toLastMessage: false)
            userRobot.waitForMessageVisibility(at: 0)
        }
        THEN("user observes the quote reply in message list") {
            userRobot
                .assertQuotedMessage(replyText: quotedMessage, quotedText: parentMessage)
                .assertScrollToBottomButton(isVisible: false)
        }
        WHEN("user taps on a quoted message") {
            userRobot.tapOnQuotedMessage(parentMessage, at: 0)
        }
        THEN("user is scrolled up to the quoted message") {
            userRobot
                .assertMessageIsVisible(at: messageCount)
                .assertScrollToBottomButton(isVisible: true)
        }
    }
    
    func test_quotedReplyNotInList_whenUserAddsQuotedReply() throws {
        linkToScenario(withId: 1701)
        
        GIVEN("user opens the channel") {
            backendRobot.generateChannels(count: 1, messagesCount: messageCount)
            userRobot.login().openChannel()
        }
        WHEN("user adds a quoted reply to participant message") {
            userRobot
                .scrollMessageListUp(times: 4)
                .quoteMessage(quotedMessage, messageCellIndex: messageCount - 1, waitForAppearance: false)
                .waitForMessageVisibility(at: 0)
        }
        THEN("user observes the quote reply in message list") {
            userRobot
                .assertQuotedMessage(replyText: quotedMessage, quotedText: parentMessage)
                .assertScrollToBottomButton(isVisible: false)
        }
        WHEN("user taps on a quoted message") {
            userRobot.tapOnQuotedMessage(parentMessage, at: 0)
        }
        THEN("user is scrolled up to the quoted message") {
            userRobot
                .assertMessageIsVisible(at: messageCount)
                .assertScrollToBottomButton(isVisible: true)
        }
    }
    
    func test_quotedReplyNotInList_whenParticipantAddsQuotedReply_Message() {
         linkToScenario(withId: 1702)
        
        GIVEN("user opens the channel") {
            backendRobot.generateChannels(count: 1, messagesCount: messageCount)
            userRobot.login().openChannel()
        }
        WHEN("participant adds a quoted reply") {
            participantRobot.quoteMessage(quotedMessage, toLastMessage: false)
            userRobot.waitForMessageVisibility(at: 0)
        }
        THEN("user observes the quote reply in message list") {
            userRobot
                .assertQuotedMessage(replyText: quotedMessage, quotedText: parentMessage)
                .assertScrollToBottomButton(isVisible: false)
        }
        WHEN("user taps on a quoted message") {
            userRobot.tapOnQuotedMessage(parentMessage, at: 0)
        }
        THEN("user is scrolled up to the quoted message") {
            userRobot
                .assertMessageIsVisible(at: messageCount)
                .assertScrollToBottomButton(isVisible: true)
        }
    }
    
    func test_quotedReplyNotInList_whenParticipantAddsQuotedReply_File() {
         linkToScenario(withId: 1703)
        
        GIVEN("user opens the channel") {
            backendRobot.generateChannels(count: 1, messagesCount: messageCount)
            userRobot.login().openChannel()
        }
        WHEN("participant sends file as a quoted reply") {
            participantRobot.uploadAttachment(type: .file, asReplyToFirstMessage: true)
            userRobot.waitForMessageVisibility(at: 0)
        }
        THEN("user observes the quote reply in message list") {
            userRobot
                .assertQuotedMessage(quotedText: parentMessage)
                .assertScrollToBottomButton(isVisible: false)
                .assertFile(isPresent: true)
        }
        WHEN("user taps on a quoted message") {
            userRobot.tapOnQuotedMessage(parentMessage, at: 0)
        }
        THEN("user is scrolled up to the quoted message") {
            userRobot
                .assertMessageIsVisible(at: messageCount)
                .assertScrollToBottomButton(isVisible: true)
        }
    }
    
    func test_quotedReplyNotInList_whenParticipantAddsQuotedReply_Giphy() {
         linkToScenario(withId: 1704)
        
        GIVEN("user opens the channel") {
            backendRobot.generateChannels(count: 1, messagesCount: messageCount)
            userRobot.login().openChannel()
        }
        WHEN("participant sends giphy as a quoted reply") {
            participantRobot.replyWithGiphy(toLastMessage: false)
            userRobot.waitForMessageVisibility(at: 0)
        }
        THEN("user observes the quote reply in message list") {
            userRobot
                .assertGiphyImage()
                .assertQuotedMessage(quotedText: parentMessage)
                .assertScrollToBottomButton(isVisible: false)
        }
        WHEN("user taps on a quoted message") {
            userRobot.tapOnQuotedMessage(parentMessage, at: 0)
        }
        THEN("user is scrolled up to the quoted message") {
            userRobot
                .assertMessageIsVisible(at: messageCount)
                .assertScrollToBottomButton(isVisible: true)
        }
    }

    func test_quotedReplyIsDeletedByParticipant_deletedMessageIsShown() {
         linkToScenario(withId: 388)

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(count: 1, messagesCount: 1)
            userRobot.login().openChannel()
        }
        AND("participant adds a quoted reply") {
            participantRobot.quoteMessage(quotedMessage)
        }
        WHEN("participant deletes a quoted message") {
            participantRobot.deleteMessage()
        }
        THEN("user observes Message deleted") {
            userRobot.assertDeletedMessage()
        }
    }

    func test_quotedReplyIsDeletedByUser_deletedMessageIsShown() {
         linkToScenario(withId: 389)

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(count: 1, messagesCount: 1)
            userRobot.login().openChannel()
        }
        AND("user adds a quoted reply") {
            userRobot.quoteMessage(quotedMessage)
        }
        WHEN("user deletes a quoted message") {
            userRobot.deleteMessage()
        }
        THEN("deleted message is shown") {
            userRobot.assertDeletedMessage()
        }
    }
    
    func test_unreadCount_whenUserSendsInvalidCommand_and_jumpingOnQuotedMessage() throws {
         linkToScenario(withId: 1705)
        
        let invalidCommand = "invalid command"
        
        GIVEN("user opens the channel") {
            backendRobot.generateChannels(count: 1, messagesCount: messageCount)
            userRobot.login().openChannel()
        }
        WHEN("user adds a quoted reply to participant message") {
            userRobot
                .scrollMessageListUp(times: 4)
                .quoteMessage(quotedMessage, messageCellIndex: messageCount - 1)
        }
        AND("user sends a message with invalid command") {
            userRobot.sendMessage("/\(invalidCommand)", waitForAppearance: false)
        }
        AND("user taps on a quoted message") {
            userRobot.tapOnQuotedMessage(parentMessage, at: 0)
        }
        THEN("user observes error message") {
            userRobot
                .assertScrollToBottomButton(isVisible: true)
                .assertScrollToBottomButtonUnreadCount(0)
        }
    }
}
