//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChatSwiftUI
import XCTest

final class QuotedReply_Tests: StreamTestCase {
    let messageCount = 30
    let pageSize = 25
    let quotedText = "1"
    let parentText = "some messsage text"
    let replyText = "quoted reply"

    func test_whenSwipingMessage_thenMessageIsQuotedReply() {
        linkToScenario(withId: 9854)

        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        WHEN("user swipes a message") {
            participantRobot.sendMessage(parentText)
            userRobot.swipeMessage()
        }
        THEN("user quoted the message") {
            userRobot
                .sendMessage("Quoting")
                .assertQuotedMessage(parentText)
        }
    }

    func test_quotedReplyInList_whenUserAddsQuotedReply() throws {
        linkToScenario(withId: 368)

        let quotedText = "2"
        let messageCount = 20
        var firstParticipantsMessageIndex = 0

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(channelsCount: 1, messagesCount: messageCount)
            userRobot.login().openChannel()
        }
        WHEN("user adds a quoted reply to participant message") {
            userRobot
                .scrollMessageListUp(times: 2)
            
            firstParticipantsMessageIndex = MessageListPage.cells.count - 2
            
            userRobot
                .quoteMessage(replyText, messageCellIndex: firstParticipantsMessageIndex)
        }
        THEN("user observes the quote reply in message list") {
            userRobot
                .assertScrollToBottomButton(isVisible: false)
                .assertQuotedMessage(replyText: replyText, quotedText: quotedText)
        }
        WHEN("user taps on a quoted message") {
            userRobot.tapOnQuotedMessage(quotedText, at: 0)
        }
        THEN("user is scrolled up to the quoted message") {
            userRobot
                .assertScrollToBottomButton(isVisible: true)
                .assertMessageIsVisible(at: firstParticipantsMessageIndex)
        }
    }

    func test_quotedReplyInList_whenParticipantAddsQuotedReply_Message() {
        linkToScenario(withId: 369)

        let messageCount = 20

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(channelsCount: 1, messagesCount: messageCount)
            userRobot.login().openChannel()
        }
        WHEN("participant adds a quoted reply") {
            participantRobot.quoteMessage(replyText, last: false)
        }
        THEN("user observes the quote reply in message list") {
            userRobot
                .assertScrollToBottomButton(isVisible: false)
                .assertQuotedMessage(replyText: replyText, quotedText: quotedText)
        }
        WHEN("user taps on a quoted message") {
            userRobot.tapOnQuotedMessage(quotedText, at: 0)
        }
        THEN("user is scrolled up to the quoted message") {
            userRobot
                .assertScrollToBottomButton(isVisible: true)
                .assertMessageIsVisible(at: messageCount - 1)
        }
    }

    func test_quotedReplyNotInList_whenUserAddsQuotedReply() throws {
        linkToScenario(withId: 1701)
        
        let quotedText = "2"
        var firstParticipantsMessageIndex = 0

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(channelsCount: 1, messagesCount: messageCount)
            userRobot.login().openChannel()
        }
        WHEN("user adds a quoted reply to participant message") {
            userRobot
                .scrollMessageListUp(times: 3)
            
            firstParticipantsMessageIndex = MessageListPage.cells.count - 2
            
            userRobot
                .quoteMessage(replyText, messageCellIndex: firstParticipantsMessageIndex)
        }
        THEN("user observes the quote reply in message list") {
            userRobot
                .assertScrollToBottomButton(isVisible: false)
                .assertQuotedMessage(replyText: replyText, quotedText: quotedText)
        }
        WHEN("user taps on a quoted message") {
            userRobot.tapOnQuotedMessage(quotedText, at: 0)
        }
        THEN("user is scrolled up to the quoted message") {
            userRobot
                .assertScrollToBottomButton(isVisible: true)
                .assertMessageIsVisible(at: firstParticipantsMessageIndex)
        }
    }

    func test_quotedReplyNotInList_whenParticipantAddsQuotedReply_Message() {
        linkToScenario(withId: 1702)

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(channelsCount: 1, messagesCount: messageCount)
            userRobot.login().openChannel()
        }
        WHEN("participant adds a quoted reply") {
            participantRobot.quoteMessage(replyText, last: false)
        }
        THEN("user observes the quote reply in message list") {
            userRobot
                .assertScrollToBottomButton(isVisible: false)
                .assertQuotedMessage(replyText: replyText, quotedText: quotedText)
        }
        WHEN("user taps on a quoted message") {
            userRobot.tapOnQuotedMessage(quotedText, at: 0)
        }
        THEN("user is scrolled up to the quoted message") {
            userRobot
                .assertScrollToBottomButton(isVisible: true)
                .assertFirstMessageIsVisible(quotedText)
        }
    }

    func test_quotedReplyNotInList_whenParticipantAddsQuotedReply_File() {
        linkToScenario(withId: 1703)

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(channelsCount: 1, messagesCount: messageCount)
            userRobot.login().openChannel()
        }
        WHEN("participant sends file as a quoted reply") {
            participantRobot.quoteMessageWithAttachment(type: .file, last: false)
        }
        THEN("user observes the quote reply in message list") {
            userRobot
                .assertScrollToBottomButton(isVisible: false)
                .assertFile(isPresent: true)
                .assertQuotedMessage(quotedText: quotedText)
        }
        WHEN("user taps on a quoted message") {
            userRobot.tapOnQuotedMessage(quotedText, at: 0)
        }
        THEN("user is scrolled up to the quoted message") {
            userRobot
                .assertScrollToBottomButton(isVisible: true)
                .assertFirstMessageIsVisible(quotedText)
        }
    }

    func test_quotedReplyNotInList_whenParticipantAddsQuotedReply_Giphy() {
        linkToScenario(withId: 1704)

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(channelsCount: 1, messagesCount: messageCount)
            userRobot.login().openChannel()
        }
        WHEN("participant sends giphy as a quoted reply") {
            participantRobot.quoteMessageWithGiphy(last: false)
        }
        THEN("user observes the quote reply in message list") {
            userRobot
                .assertScrollToBottomButton(isVisible: false)
                .assertGiphyImage()
                .assertQuotedMessage(quotedText: quotedText)
        }
        WHEN("user taps on a quoted message") {
            userRobot.tapOnQuotedMessage(quotedText, at: 0)
        }
        THEN("user is scrolled up to the quoted message") {
            userRobot
                .assertScrollToBottomButton(isVisible: true)
                .assertFirstMessageIsVisible(quotedText)
        }
    }

    func test_quotedReplyIsDeletedByParticipant_deletedMessageIsShown() {
        linkToScenario(withId: 388)

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(channelsCount: 1, messagesCount: 1)
            userRobot.login().openChannel()
        }
        AND("participant adds a quoted reply") {
            participantRobot.quoteMessage(replyText)
        }
        WHEN("participant deletes a quoted message") {
            participantRobot.deleteMessage()
        }
        THEN("user observes Message deleted") {
            userRobot.assertDeletedMessage()
        }
    }
    
    func test_originalQuoteIsDeletedByParticipant_deletedMessageIsShown() {
        linkToScenario(withId: 9855)

        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        AND("participant sends a message") {
            participantRobot.sendMessage("1")
        }
        AND("user adds a quoted reply") {
            userRobot.quoteMessage(replyText)
        }
        WHEN("participant deletes an original message") {
            participantRobot.deleteMessage()
        }
        THEN("deleted message is shown") {
            userRobot.assertDeletedMessage(at: 1)
        }
        AND("deleted message is shown in quoted reply bubble") {
            userRobot.assertQuotedMessage(L10n.Message.deletedMessagePlaceholder)
        }
    }

    func test_quotedReplyIsDeletedByUser_deletedMessageIsShown() {
        linkToScenario(withId: 389)

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(channelsCount: 1, messagesCount: 1)
            userRobot.login().openChannel()
        }
        AND("user adds a quoted reply") {
            userRobot.quoteMessage(replyText)
        }
        WHEN("user deletes a quoted message") {
            userRobot.deleteMessage()
        }
        THEN("deleted message is shown") {
            userRobot.assertDeletedMessage()
        }
    }
    
    func test_originalQuoteIsDeletedByUser_deletedMessageIsShown() {
        linkToScenario(withId: 9856)

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(channelsCount: 1, messagesCount: 1)
            userRobot.login().openChannel()
        }
        AND("user adds a quoted reply") {
            userRobot.quoteMessage(replyText)
        }
        WHEN("user deletes an original message") {
            userRobot.deleteMessage(messageCellIndex: 1)
        }
        THEN("deleted message is shown") {
            userRobot.assertDeletedMessage(at: 1)
        }
        AND("deleted message is shown in quoted reply bubble") {
            userRobot.assertQuotedMessage(L10n.Message.deletedMessagePlaceholder)
        }
    }

    func test_unreadCount_whenUserSendsInvalidCommand_and_jumpingOnQuotedMessage() {
        linkToScenario(withId: 1705)

        let invalidCommand = "invalid command"

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(channelsCount: 1, messagesCount: messageCount)
            userRobot.login().openChannel()
        }
        WHEN("user adds a quoted reply to participant message") {
            userRobot
                .scrollMessageListUp(times: 3)
                .quoteMessage(replyText, messageCellIndex: messageCount - 1)
        }
        AND("user quotes a message with invalid command") {
            userRobot.quoteMessage("/\(invalidCommand)", messageCellIndex: 0, waitForAppearance: false)
        }
        THEN("user observes invalid command alert") {
            userRobot.assertInvalidCommand(invalidCommand)
        }
        WHEN("user taps on a quoted message") {
            userRobot.tapOnQuotedMessage(quotedText, at: 1)
        }
        THEN("user is scrolled up to the quoted message") {
            userRobot
                .assertScrollToBottomButton(isVisible: true)
                .assertScrollToBottomButtonUnreadCount(0)
        }
    }

    func test_quotedReplyInList_whenUserAddsQuotedReply_InThread() {
        linkToScenario(withId: 9857)

        let messageCount = 10
        let replyToMessageIndex = messageCount - 1

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(
                channelsCount: 1,
                messagesCount: 1,
                repliesCount: messageCount,
                messagesText: parentText
            )
            userRobot.login().openChannel()
        }
        WHEN("user adds a quoted reply to participant message in thread") {
            userRobot
                .openThread()
                .scrollMessageListUp(times: 2)
                .quoteMessage(replyText, messageCellIndex: replyToMessageIndex, waitForAppearance: false)
        }
        THEN("user observes the quote reply in thread") {
            userRobot
                .assertScrollToBottomButton(isVisible: false)
                .assertQuotedMessage(replyText: replyText, quotedText: quotedText)
        }
        WHEN("user taps on a quoted message") {
            userRobot.tapOnQuotedMessage(quotedText, at: 0)
        }
        THEN("user is scrolled up to the quoted message") {
            userRobot
                .assertScrollToBottomButton(isVisible: true)
                .assertMessageIsVisible(at: replyToMessageIndex)
        }
    }

    func test_quotedReplyInList_whenParticipantAddsQuotedReply_Message_InThread() throws {
        linkToScenario(withId: 9858)
        
        throw XCTSkip("https://linear.app/stream/issue/IOS-479")

        let messageCount = 25

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(
                channelsCount: 1,
                messagesCount: 1,
                repliesCount: messageCount,
                messagesText: parentText
            )
            userRobot.login().openChannel()
        }
        WHEN("participant adds a quoted reply") {
            participantRobot.quoteMessageInThread(replyText, last: false)
        }
        THEN("user observes the quote reply in thread") {
            userRobot
                .openThread()
                .assertQuotedMessage(replyText: replyText, quotedText: quotedText)
                .assertScrollToBottomButton(isVisible: false)
        }
        WHEN("user taps on a quoted message") {
            userRobot.tapOnQuotedMessage(quotedText, at: 0)
        }
        THEN("user is scrolled up to the quoted message") {
            userRobot
                .assertMessage(quotedText, at: messageCount)
                .assertMessageIsVisible(at: messageCount)
                .assertScrollToBottomButton(isVisible: true)
        }
    }

    func test_quotedReplyNotInList_whenUserAddsQuotedReply_InThread() throws {
        linkToScenario(withId: 9859)
        
        throw XCTSkip("https://linear.app/stream/issue/IOS-479")

        let replyToMessageIndex = messageCount - 1

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(
                channelsCount: 1,
                messagesCount: 1,
                repliesCount: messageCount,
                messagesText: parentText
            )
            userRobot.login().openChannel()
        }
        WHEN("user adds a quoted reply to participant message in thread") {
            userRobot
                .openThread()
                .scrollMessageListUp(times: 3)
                .quoteMessage(replyText, messageCellIndex: replyToMessageIndex, waitForAppearance: false)
                .waitForMessageVisibility(at: 0)
        }
        THEN("user observes the quote reply") {
            userRobot
                .assertQuotedMessage(replyText: replyText, quotedText: quotedText)
                .assertScrollToBottomButton(isVisible: false)
        }
        WHEN("user taps on a quoted message") {
            userRobot.tapOnQuotedMessage(quotedText, at: 0)
        }
        THEN("user is scrolled up to the quoted message") {
            userRobot
                .assertMessage(quotedText, at: messageCount)
                .assertMessageIsVisible(at: messageCount)
                .assertScrollToBottomButton(isVisible: true)
        }
    }

    func test_quotedReplyNotInList_whenParticipantAddsQuotedReply_Message_InThread() throws {
        linkToScenario(withId: 9860)
        
        throw XCTSkip("https://linear.app/stream/issue/IOS-479")

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(
                channelsCount: 1,
                messagesCount: 1,
                repliesCount: messageCount,
                messagesText: parentText
            )
            userRobot.login().openChannel()
        }
        WHEN("participant adds a quoted reply in thread") {
            participantRobot.quoteMessageInThread(replyText, last: false)
        }
        THEN("user observes the quote reply in thread") {
            userRobot
                .openThread()
                .assertQuotedMessage(replyText: replyText, quotedText: quotedText)
                .assertScrollToBottomButton(isVisible: false)
        }
        WHEN("user taps on a quoted message") {
            userRobot.tapOnQuotedMessage(quotedText, at: 0)
        }
        THEN("user is scrolled up to the quoted message") {
            userRobot
                .assertMessage(quotedText, at: pageSize)
                .assertMessageIsVisible(at: pageSize)
                .assertScrollToBottomButton(isVisible: true)
        }
    }

    func test_quotedReplyNotInList_whenParticipantAddsQuotedReply_File_InThread() throws {
        linkToScenario(withId: 9861)
        
        throw XCTSkip("https://linear.app/stream/issue/IOS-479")

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(
                channelsCount: 1,
                messagesCount: 1,
                repliesCount: messageCount,
                messagesText: parentText
            )
            userRobot.login().openChannel()
        }
        WHEN("participant sends file as a quoted reply in thread") {
            participantRobot.quoteMessageWithAttachmentInThread(type: .file, last: false)
        }
        THEN("user observes the quote reply in thread") {
            userRobot
                .openThread()
                .assertFile(isPresent: true)
                .assertQuotedMessage(quotedText: quotedText)
                .assertScrollToBottomButton(isVisible: false)
        }
        WHEN("user taps on a quoted message") {
            userRobot.tapOnQuotedMessage(quotedText, at: 0)
        }
        THEN("user is scrolled up to the quoted message") {
            userRobot
                .assertFirstMessageIsVisible("1")
                .assertScrollToBottomButton(isVisible: true)
        }
    }
    
    // NOTE: There used to be a problem with tapping on a Send button on iOS > 16
    func test_quotedReplyNotInList_whenParticipantAddsQuotedReply_Giphy_InThread() throws {
        linkToScenario(withId: 9862)
        
        throw XCTSkip("https://linear.app/stream/issue/IOS-479")

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(
                channelsCount: 1,
                messagesCount: 1,
                repliesCount: messageCount,
                messagesText: parentText
            )
            userRobot.login().openChannel()
        }
        WHEN("participant sends giphy as a quoted reply") {
            participantRobot.quoteMessageWithGiphyInThread(last: false)
        }
        THEN("user observes the quote reply in thread") {
            userRobot
                .openThread()
                .assertGiphyImage()
                .assertQuotedMessage(quotedText: quotedText)
                .assertScrollToBottomButton(isVisible: false)
        }
        WHEN("user taps on a quoted message") {
            userRobot.tapOnQuotedMessage(quotedText, at: 0)
        }
        THEN("user is scrolled up to the quoted message") {
            userRobot
                .assertScrollToBottomButton(isVisible: true, timeout: 15)
                .assertMessageIsVisible(at: pageSize)
        }
    }

    func test_unreadCount_whenUserSendsInvalidCommand_and_jumpingOnQuotedMessage_InThread() throws {
        linkToScenario(withId: 9863)
        
        throw XCTSkip("https://linear.app/stream/issue/IOS-479")

        let invalidCommand = "invalid command"
        let replyToMessageIndex = messageCount - 1

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(
                channelsCount: 1,
                messagesCount: 1,
                repliesCount: messageCount,
                messagesText: parentText
            )
            userRobot.login().openChannel()
        }
        THEN("user adds a quoted reply in thread") {
            userRobot
                .openThread()
                .scrollMessageListUp(times: 3)
                .quoteMessage(replyText, messageCellIndex: replyToMessageIndex, waitForAppearance: false)
        }
        AND("user quotes a message with invalid command") {
            userRobot.quoteMessage("/\(invalidCommand)", messageCellIndex: 0, waitForAppearance: false)
        }
        THEN("user observes invalid command alert") {
            userRobot.assertInvalidCommand(invalidCommand)
        }
        WHEN("user taps on a quoted message") {
            userRobot.tapOnQuotedMessage(quotedText, at: 1)
        }
        THEN("user is scrolled up to the quoted message") {
            userRobot
                .assertScrollToBottomButton(isVisible: true)
                .assertScrollToBottomButtonUnreadCount(0)
        }
    }

    func test_threadRepliesCount() {
        linkToScenario(withId: 9864)
        
        let repliesCount = 5

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(
                channelsCount: 1,
                messagesCount: 1,
                repliesCount: repliesCount,
                messagesText: parentText
            )
            userRobot.login().openChannel()
        }
        THEN("user observes the number of replies in the channel") {
            userRobot.assertThreadReplyCountButton(replies: repliesCount)
        }
    }

    func test_quotedReplyInThreadAndAlsoInChannel() {
        linkToScenario(withId: 9865)

        let quotedText = String(messageCount)

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(
                channelsCount: 1,
                messagesCount: 1,
                repliesCount: messageCount,
                messagesText: parentText
            )
            userRobot.login().openChannel()
        }
        WHEN("participant adds a quoted reply in thread and also in channel") {
            participantRobot.quoteMessageInThread(replyText, alsoSendInChannel: true)
        }
        THEN("user observes the quoted reply in channel") {
            userRobot
                .assertQuotedMessage(replyText: replyText, quotedText: quotedText)
                .assertScrollToBottomButton(isVisible: false)
        }
        AND("user observes the quoted reply also in thread") {
            userRobot
                .openThread()
                .assertQuotedMessage(replyText: replyText, quotedText: quotedText)
                .assertScrollToBottomButton(isVisible: false)
        }
    }

    func test_quotedReplyIsDeletedByParticipant_deletedMessageIsShown_InThread() {
        linkToScenario(withId: 9866)

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(
                channelsCount: 1,
                messagesCount: 1,
                repliesCount: 1,
                messagesText: parentText
            )
            userRobot.login().openChannel()
        }
        AND("participant adds a quoted reply") {
            participantRobot.quoteMessageInThread(replyText)
        }
        WHEN("participant deletes a quoted message") {
            participantRobot.deleteMessage()
        }
        THEN("user observes Message deleted in thread") {
            userRobot.openThread().assertDeletedMessage()
        }
    }
    
    func test_originalQuoteIsDeletedByParticipant_deletedMessageIsShown_InThread() {
        linkToScenario(withId: 9867)

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(
                channelsCount: 1,
                messagesCount: 1,
                messagesText: parentText
            )
            userRobot.login().openChannel()
        }
        AND("participant sends a message") {
            participantRobot.sendMessageInThread("1")
        }
        AND("user adds a quoted reply") {
            userRobot
                .openThread(waitForThreadIcon: true)
                .quoteMessage(replyText)
        }
        WHEN("participant deletes an original message") {
            participantRobot.deleteMessage()
        }
        THEN("deleted message is shown") {
            userRobot.assertDeletedMessage(at: 1)
        }
        AND("deleted message is shown in quoted reply bubble") {
            userRobot.assertQuotedMessage(L10n.Message.deletedMessagePlaceholder)
        }
    }

    func test_quotedReplyIsDeletedByUser_deletedMessageIsShown_InThread() {
        linkToScenario(withId: 9868)

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(
                channelsCount: 1,
                messagesCount: 1,
                repliesCount: 1,
                messagesText: parentText
            )
            userRobot.login().openChannel()
        }
        AND("user adds a quoted reply in thread") {
            userRobot
                .openThread(waitForThreadIcon: true)
                .quoteMessage(replyText)
        }
        WHEN("user deletes a quoted message") {
            userRobot.deleteMessage()
        }
        THEN("deleted message is shown") {
            userRobot.assertDeletedMessage()
        }
    }
    
    func test_originalQuoteIsDeletedByUser_deletedMessageIsShown_InThread() {
        linkToScenario(withId: 9869)

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(channelsCount: 1, messagesCount: 1)
            userRobot.login().openChannel()
        }
        AND("user adds a quoted reply") {
            userRobot.openThread().quoteMessage(replyText)
        }
        WHEN("user deletes an original message") {
            userRobot.deleteMessage(messageCellIndex: 1)
        }
        THEN("deleted message is shown") {
            userRobot.assertDeletedMessage(at: 1)
        }
        AND("deleted message is shown in quoted reply bubble") {
            userRobot.assertQuotedMessage(L10n.Message.deletedMessagePlaceholder)
        }
    }

    func test_rootMessageShouldOnlyBeVisibleInTheLastPageInThread() throws {
        linkToScenario(withId: 9870)
        
        throw XCTSkip("https://linear.app/stream/issue/IOS-479")

        let replyCount = 30

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(
                channelsCount: 1,
                messagesCount: 1,
                repliesCount: replyCount,
                messagesText: parentText
            )
            userRobot.login().openChannel()
        }
        WHEN("user opens the thread with \(replyCount) replies") {
            userRobot.openThread()
        }
        THEN("parent message is not loaded") {
            userRobot.assertParentMessageInThread(withText: parentText, isLoaded: false)
        }
        WHEN("user scrolls up to load one more page") {
            userRobot.scrollMessageListUp(times: 2)
        }
        THEN("parent message is loaded") {
            userRobot.assertParentMessageInThread(withText: parentText, isLoaded: true)
        }
    }
    
    func test_rootMessageShouldNotBeVisibleInThreadIfMessageCountEqualToPageSize() throws {
        linkToScenario(withId: 9871)
        
        throw XCTSkip("https://linear.app/stream/issue/IOS-479")

        let pageSize = 25
        
        GIVEN("user opens the channel") {
            backendRobot.generateChannels(
                channelsCount: 1,
                messagesCount: 1,
                repliesCount: pageSize,
                messagesText: parentText
            )
            userRobot.login().openChannel()
        }
        WHEN("user opens the thread with \(pageSize) replies") {
            userRobot.openThread()
        }
        THEN("parent message is not loaded") {
            userRobot.assertParentMessageInThread(withText: parentText, isLoaded: false)
        }
        WHEN("user scrolls up to load one more page") {
            userRobot.scrollMessageListUp(times: 2)
        }
        THEN("parent message is loaded") {
            userRobot.assertParentMessageInThread(withText: parentText, isLoaded: true)
        }
    }
    
    func test_rootMessageShouldBeVisibleInThreadIfMessageCountLessThanPageSize() {
        linkToScenario(withId: 9872)

        let messageCount = 15
        
        GIVEN("user opens the channel") {
            backendRobot.generateChannels(
                channelsCount: 1,
                messagesCount: 1,
                repliesCount: messageCount,
                messagesText: parentText
            )
            userRobot.login().openChannel()
        }
        WHEN("user opens the thread with \(messageCount) replies") {
            userRobot.openThread(waitForThreadIcon: true)
        }
        THEN("parent message is loaded") {
            userRobot.assertParentMessageInThread(withText: parentText, isLoaded: true)
        }
    }
    
    func test_quoteReplyRootMessageWhenNotInTheList() throws {
        linkToScenario(withId: 9873)
        
        throw XCTSkip("https://linear.app/stream/issue/IOS-479")

        GIVEN("user opens the thread with \(messageCount) replies") {
            backendRobot.generateChannels(
                channelsCount: 1,
                messagesCount: 1,
                repliesCount: messageCount,
                messagesText: parentText
            )
            userRobot.login().openChannel().openThread()
        }
        WHEN("user quote replies root message") {
            userRobot
                .scrollMessageListUp(times: 3)
                .quoteMessage(replyText, messageCellIndex: messageCount, waitForAppearance: false)
        }
        AND("user reenters the thread") {
            userRobot
                .tapOnBackButton()
                .openThread()
        }
        AND("user jumps to root message") {
            userRobot.tapOnQuotedMessage(parentText)
        }
        THEN("parent message is loaded") {
            userRobot.assertParentMessageInThread(withText: parentText, isLoaded: true)
        }
    }
}
