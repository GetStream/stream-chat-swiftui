//
// Copyright © 2024 Stream.io Inc. All rights reserved.
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

    func test_sendsMessageWithOneEmoji() throws {
        linkToScenario(withId: 273)

        let message = "🍏"

        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        WHEN("user sends the emoji: '\(message)'") {
            userRobot.sendMessage(message)
        }
        THEN("the message is delivered") {
            userRobot.assertMessage(message)
        }
    }

    func test_sendsMessageWithMultipleEmojis() throws {
        linkToScenario(withId: 274)

        let message = "🍏🙂👍"

        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        WHEN("user sends a message with multiple emojis - \(message)") {
            userRobot.sendMessage(message)
        }
        THEN("the message is delivered") {
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

    func test_receivesMessage() throws {
        linkToScenario(withId: 254)

        let message = "message"
        let author = "Han Solo"

        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        WHEN("participant sends a message: '\(message)'") {
            participantRobot.sendMessage(message, waitBeforeSending: 0.5)
        }
        THEN("the message is delivered") {
            userRobot.assertMessageAuthor(author)
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

    func test_messageIncreases_whenUserEditsMessageWithOneLineText() throws {
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

    func test_composerGrowthLimit() throws {
        linkToScenario(withId: 260)

        throw XCTSkip("Check out SWUI-188")

        GIVEN("user opens the channel") {
            userRobot
                .login()
                .openChannel()
        }
        THEN("user verifies that composer does not grow more than 5 lines") {
            userRobot.assertComposerLimits(toNumberOfLines: 5)
        }
    }

    func test_typingIndicator() throws {
        linkToScenario(withId: 358)

        let typingEventsTimeout: Double = 4

        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        WHEN("participant starts typing") {
            participantRobot.wait(typingEventsTimeout).startTyping()
        }
        THEN("user observes typing indicator is shown") {
            let typingUserName = UserDetails.userName(for: participantRobot.currentUserId)
            userRobot.assertTypingIndicatorShown(typingUserName: typingUserName)
        }
        WHEN("participant stops typing") {
            participantRobot.wait(typingEventsTimeout).stopTyping()
        }
        THEN("user observes typing indicator has disappeared") {
            userRobot.assertTypingIndicatorHidden()
        }
    }

    func test_commandsPopupDisappear_whenUserTapsOnMessageList() throws {
        linkToScenario(withId: 364)

        throw XCTSkip("Check out SWUI-187")

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(count: 1, messagesCount: 30)
            userRobot.login().openChannel()
        }
        AND("user opens command suggestions") {
            userRobot.openComposerCommands()
        }
        WHEN("user taps on message list") {
            userRobot.tapOnMessageList()
        }
        THEN("command suggestions disappear") {
            userRobot.assertComposerCommands(shouldBeVisible: false)
        }
    }

    func test_offlineMessageInTheMessageList() throws {
        linkToScenario(withId: 365)

        throw XCTSkip("Check out SWUI-245")

        let message = "test message"

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(count: 1, messagesCount: 40)
            userRobot
                .setConnectivitySwitchVisibility(to: .on)
                .login()
                .openChannel()
        }
        AND("user becomes offline") {
            userRobot.setConnectivity(to: .off)
        }
        WHEN("participant sends a new message") {
            participantRobot.sendMessage(message)
        }
        AND("user becomes online") {
            userRobot.setConnectivity(to: .on)
        }
        THEN("user observes a new message from participant") {
            userRobot.assertMessage(message)
        }
    }

    func test_addMessageWhileOffline() throws {
        linkToScenario(withId: 366)

        throw XCTSkip("Check out SWUI-245")

        let message = "test message"

        GIVEN("user opens the channel") {
            userRobot
                .setIsLocalStorageEnabled(to: .on)
                .setConnectivitySwitchVisibility(to: .on)
                .login()
                .openChannel()
        }
        AND("user becomes offline") {
            userRobot.setConnectivity(to: .off)
        }
        WHEN("user sends a new message") {
            userRobot.sendMessage(message, waitForAppearance: false)
        }
        THEN("error indicator is shown for the message") {
            userRobot.assertMessageFailedToBeSent()
        }
        WHEN("user becomes online") {
            userRobot.setConnectivity(to: .on)
        }
        THEN("new message is delivered") {
            userRobot
                .assertMessage(message)
                .assertMessageDeliveryStatus(.sent, at: 0)
        }
    }

    func test_offlineRecoveryWithinSession() throws {
        linkToScenario(withId: 367)

        throw XCTSkip("Check out SWUI-245")

        let message = "test message"

        GIVEN("user opens the channel") {
            userRobot
                .setIsLocalStorageEnabled(to: .on)
                .setStaysConnectedInBackground(to: .on)
                .login()
                .openChannel()
        }
        AND("user goes to the background") {
            deviceRobot.moveApplication(to: .background)
        }
        WHEN("participant sends a new message") {
            participantRobot.wait(1).sendMessage(message)
        }
        AND("user comes back to the foreground") {
            deviceRobot.moveApplication(to: .foreground)
        }
        THEN("new message is delivered") {
            userRobot.assertMessage(message)
        }
    }
}

// MARK: Scroll to bottom

extension MessageList_Tests {
    
    func test_messageListScrollsDown_whenMessageListIsScrolledUp_andUserSendsNewMessage() throws {
        linkToScenario(withId: 359)

        throw XCTSkip("Check out SWUI-256")

        let newMessage = "New message"

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(count: 1, messagesCount: 30)
            userRobot.login().openChannel()
        }
        WHEN("user scrolls up") {
            userRobot.scrollMessageListUp()
        }
        AND("user sends a new message") {
            userRobot.sendMessage(newMessage)
        }
        THEN("message list is scrolled down") {
            userRobot
                .assertMessageIsVisible(newMessage)
                .assertScrollToBottomButton(isVisible: false)
        }
    }

    func test_messageListScrollsDown_whenMessageListIsScrolledDown_andUserReceivesNewMessage() throws {
        linkToScenario(withId: 360)

        let newMessage = "New message"

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(count: 1, messagesCount: 30)
            userRobot.login().openChannel()
        }
        WHEN("participant sends a message") {
            participantRobot.sendMessage(newMessage)
        }
        THEN("message list is scrolled down") {
            userRobot
                .assertMessageIsVisible(newMessage)
                .assertScrollToBottomButton(isVisible: false)
        }
    }

    func test_messageListDoesNotScrollDown_whenMessageListIsScrolledUp_andUserReceivesNewMessage() {
        linkToScenario(withId: 361)

        let newMessage = "New message"

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(count: 1, messagesCount: 30)
            userRobot.login().openChannel()
        }
        WHEN("user scrolls up") {
            userRobot.scrollMessageListUp()
        }
        AND("participant sends a message") {
            participantRobot.sendMessage(newMessage)
        }
        THEN("message list is not scrolled down") {
            userRobot
                .assertMessageIsNotVisible(newMessage)
                .assertScrollToBottomButton(isVisible: true)
        }
    }

    func test_messageListScrollsDown_whenUserTapsOnScrollToBottomButton() throws {
        linkToScenario(withId: 362)

        let newMessage = "New message"

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(count: 1, messagesCount: 30)
            userRobot.login().openChannel()
        }
        AND("user sends a new message") {
            userRobot.sendMessage(newMessage)
        }
        WHEN("user scrolls up") {
            userRobot.scrollMessageListUp()
        }
        AND("user taps on 'scroll to bottom' button") {
            userRobot.tapOnScrollToBottomButton()
        }
        THEN("message list is scrolled down") {
            userRobot
                .assertMessageIsVisible(newMessage)
                .assertScrollToBottomButton(isVisible: false)
        }
    }

    func test_reloadsSkippedMessages_whenScrolledToTheBottom() throws {
        linkToScenario(withId: 363)

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(count: 1, messagesCount: 30)
            userRobot.login().openChannel()
        }
        AND("user scrolls up") {
            userRobot.scrollMessageListUpSlow()
        }
        AND("participant sends some messages") {
            participantRobot.sendMultipleMessages(repeatingText: "Some message", count: 16)
        }
        WHEN("user scrolls to the bottom") {
            userRobot.tapOnScrollToBottomButton()
        }
        THEN("skipped messages are reloaded") {
            userRobot
                .assertMessageIsVisible("Some message-16")
                .assertScrollToBottomButton(isVisible: false)
        }
    }
    
    func test_scrollToBottom_unreadCount() throws {
        linkToScenario(withId: 1700)

        let newMessage = "New message"

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(count: 1, messagesCount: 30)
            userRobot.login().openChannel()
        }
        WHEN("user scrolls up") {
            userRobot.scrollMessageListUp(times: 2)
        }
        AND("participant sends a message") {
            participantRobot.sendMessage(newMessage)
        }
        THEN("message list is not scrolled down") {
            userRobot
                .assertMessageIsNotVisible(newMessage)
                .assertScrollToBottomButton(isVisible: true)
                .assertScrollToBottomButtonUnreadCount(1)
        }
        WHEN("user taps on scroll to bottom button") {
            userRobot.tapOnScrollToBottomButton()
        }
        AND("user scrolls up") {
            userRobot.scrollMessageListUp(times: 2)
        }
        THEN("unread count is not displayed") {
            userRobot
                .assertScrollToBottomButton(isVisible: true)
                .assertScrollToBottomButtonUnreadCount(0)
        }
    }
}

// MARK: Pagination

extension MessageList_Tests {
    
    func test_paginationOnMessageList() throws {
        linkToScenario(withId: 370)
        
        let messagesCount = 60
        
        WHEN("user opens the channel") {
            backendRobot.generateChannels(count: 1, messagesCount: messagesCount)
            userRobot.login().openChannel()
        }
        THEN("user makes sure that chat history is loaded") {
            userRobot.assertMessageListPagination(messagesCount: messagesCount)
        }
    }
    
    func test_paginationOnThread() throws {
        linkToScenario(withId: 371)
        
        let replyCount = 60
        
        GIVEN("user opens the channel") {
            backendRobot.generateChannels(count: 1, messagesCount: 1, replyCount: replyCount)
            userRobot.login().openChannel()
        }
        WHEN("user opens the thread") {
            userRobot.openThread()
        }
        THEN("user makes sure that thread history is loaded") {
            userRobot.assertThreadListPagination(messagesCount: replyCount + 1)
        }
    }
}

// MARK: Mentions

extension MessageList_Tests {
    
    func test_addingCommandHidesLeftButtons() throws {
        linkToScenario(withId: 372)
        
        throw XCTSkip("Check out SWUI-243")
        
        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        WHEN("user types '/'") {
            userRobot.typeText("/")
        }
        THEN("composer left buttons disappear") {
            userRobot.assertComposerLeftButtons(shouldBeVisible: false)
        }
        WHEN("user removes '/'") {
            userRobot.typeText(XCUIKeyboardKey.delete.rawValue)
        }
        THEN("composer left buttons appear") {
            userRobot.assertComposerLeftButtons(shouldBeVisible: true)
        }
    }
    
    func test_mentionsView() {
        linkToScenario(withId: 373)
        
        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        WHEN("user types '@'") {
            userRobot.typeText("@")
        }
        THEN("composer mention view appears") {
            userRobot.assertComposerMentions(shouldBeVisible: true)
        }
        WHEN("user removes '@'") {
            userRobot.typeText(XCUIKeyboardKey.delete.rawValue)
        }
        THEN("composer mention view disappears") {
            userRobot.assertComposerMentions(shouldBeVisible: false)
        }
    }
    
    func test_userFillsTheComposerMentioningParticipantThroughMentionsView() {
        linkToScenario(withId: 374)
        
        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        WHEN("user taps on participants name") {
            userRobot.mentionParticipant()
        }
        THEN("composer fills in participants name") {
            userRobot.assertMentionWasApplied()
        }
    }
}

// MARK: Links preview

extension MessageList_Tests {

    func test_addMessageWithLinkToUnsplash() {
        linkToScenario(withId: 375)

        let message = "https://unsplash.com/photos/1_2d3MRbI9c"

        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        WHEN("user sends a message with YouTube link") {
            userRobot
                .sendMessage(message)
                .scrollMessageListDown() // to hide the keyboard
        }
        THEN("user observes a preview of the image with description") {
            userRobot.assertLinkPreview()
        }
    }

    func test_addMessageWithLinkToYoutube() throws {
        linkToScenario(withId: 376)

        let message = "https://youtube.com/watch?v=xOX7MsrbaPY"

        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        WHEN("user sends a message with YouTube link") {
            userRobot
                .sendMessage(message)
                .scrollMessageListDown() // to hide the keyboard
        }
        THEN("user observes a preview of the video with description") {
            userRobot.assertLinkPreview(alsoVerifyServiceName: "YouTube")
        }
    }

    func test_participantAddsMessageWithLinkToUnsplash() {
        linkToScenario(withId: 377)

        let message = "https://unsplash.com/photos/1_2d3MRbI9c"

        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        WHEN("participant sends a message with Unsplash link") {
            participantRobot.sendMessage(message)
            userRobot.scrollMessageListDown() // to hide the keyboard
        }
        THEN("user observes a preview of the image with description") {
            userRobot.assertLinkPreview()
        }
    }

    func test_participantAddsMessageWithLinkToYoutube() {
        linkToScenario(withId: 378)

        let message = "https://youtube.com/watch?v=xOX7MsrbaPY"

        GIVEN("user opens the channel") {
            userRobot.login().openChannel()
        }
        WHEN("participant sends a message with YouTube link") {
            participantRobot.sendMessage(message)
            userRobot.scrollMessageListDown() // to hide the keyboard
        }
        THEN("user observes a preview of the video with description") {
            userRobot.assertLinkPreview(alsoVerifyServiceName: "YouTube")
        }
    }
}

// MARK: - Thread replies
extension MessageList_Tests {
    func test_threadReplyAppearsInThread_whenParticipantAddsThreadReply() throws {
        linkToScenario(withId: 379)
        
        throw XCTSkip("XCTest issue: Automation type mismatch: computed Other from legacy attributes vs ActivityIndicator from modern attribute.")

        let threadReply = "thread reply"

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(count: 1, messagesCount: 1)
            userRobot.login().openChannel()
        }
        WHEN("participant adds a thread reply") {
            participantRobot.replyToMessageInThread(threadReply)
        }
        AND("user enters thread") {
            userRobot.openThread()
        }
        THEN("user observes the thread reply in thread") {
            userRobot.assertThreadReply(threadReply)
        }
    }

    func test_threadReplyAppearsInChannelAndThread_whenParticipantAddsThreadReplySentAlsoToChannel() {
        linkToScenario(withId: 380)

        let threadReply = "thread reply"

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(count: 1, messagesCount: 1)
            userRobot.login().openChannel()
        }
        WHEN("participant adds a thread reply") {
            participantRobot.replyToMessageInThread(threadReply, alsoSendInChannel: true)
        }
        THEN("user observes the thread reply in channel") {
            userRobot.assertMessage(threadReply)
        }
        WHEN("user enters thread") {
            userRobot.openThread(messageCellIndex: 1, waitForThreadIcon: true)
        }
        THEN("user observes the thread reply in thread") {
            userRobot.assertThreadReply(threadReply)
        }
    }

    func test_threadReplyAppearsInChannelAndThread_whenUserAddsThreadReplySentAlsoToChannel() {
        linkToScenario(withId: 381)

        let threadReply = "thread reply"

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(count: 1, messagesCount: 1)
            userRobot.login().openChannel()
        }
        WHEN("user adds a thread reply and sends it also to main channel") {
            userRobot.replyToMessageInThread(threadReply, alsoSendInChannel: true)
        }
        THEN("user observes the thread reply in thread") {
            userRobot.assertThreadReply(threadReply)
        }
        AND("user observes the thread reply in channel") {
            userRobot
                .tapOnBackButton()
                .assertMessage(threadReply)
        }
    }

    func test_threadTypingIndicatorHidden_whenParticipantStopsTyping() throws {
        linkToScenario(withId: 382)

        throw XCTSkip("Check out SWUI-251")

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(count: 1, messagesCount: 1)
            userRobot.login().openChannel()
        }
        AND("user opens the thread") {
            userRobot.openThread()
        }
        WHEN("participant starts typing in thread") {
            participantRobot.wait(2).startTypingInThread()
        }
        THEN("user observes typing indicator is shown") {
            let typingUserName = UserDetails.userName(for: participantRobot.currentUserId)
            userRobot.assertTypingIndicatorShown(typingUserName: typingUserName)
        }
        WHEN("participant stops typing in thread") {
            participantRobot.wait(2).stopTypingInThread()
        }
        THEN("user observes typing indicator has disappeared") {
            userRobot.assertTypingIndicatorHidden()
        }
    }
}

// MARK: - Message grouping

extension MessageList_Tests {
    func test_messageEndsGroup_whenFollowedByErrorMessage() {
        linkToScenario(withId: 383)

        let message = "Hey there"
        let messageWithForbiddenContent = server.forbiddenWords.first ?? ""

        GIVEN("user opens the channel") {
            userRobot
                .login()
                .openChannel()
        }
        AND("user sends the 1st message") {
            userRobot.sendMessage(message)
        }
        AND("the timestamp is shown under the 1st message") {
            userRobot.assertMessageHasTimestamp()
        }
        WHEN("user sends a message that does not pass moderation") {
            userRobot.sendMessage(messageWithForbiddenContent, waitForAppearance: false)
        }
        THEN("messages are not grouped, 1st message shows the timestamp") {
            userRobot.assertMessageHasTimestamp(at: 1)
        }
    }

    func test_messageEndsGroup_whenFollowedByEphemeralMessage() {
        linkToScenario(withId: 384)

        let message = "Hey there"

        GIVEN("user opens the channel") {
            userRobot
                .login()
                .openChannel()
        }
        AND("user sends the 1st message") {
            userRobot.sendMessage(message)
        }
        AND("the timestamp is shown under the 1st message") {
            userRobot.assertMessageHasTimestamp()
        }
        WHEN("user sends an ephemeral message") {
            userRobot
                .sendGiphy(send: false)
                .scrollMessageListDown() // to hide the keyboard
        }
        THEN("messages are not grouped, 1st message shows the timestamp") {
            userRobot
                .assertMessageCount(2)
                .assertMessageHasTimestamp(at: 1)
        }
    }

    func test_messageRendersTimestampAgain_whenMessageLastInGroupIsHardDeleted() throws {
        linkToScenario(withId: 385)

        throw XCTSkip("Check out SWUI-245")

        GIVEN("user opens the channel") {
            backendRobot
                .generateChannels(count: 1, messagesCount: 1)
            userRobot
                .login()
                .openChannel()
        }
        AND("user inserts 3 group messages") {
            userRobot.sendMessage("Hey")
            userRobot.sendMessage("Hey2")
            userRobot.sendMessage("Hey3")
            userRobot.assertMessageHasTimestamp()
        }
        WHEN("user deletes last message") {
            userRobot.deleteMessage(hard: true)
        }
        THEN("previous message should re-render timestamp") {
            userRobot.assertMessageHasTimestamp(at: 0)
        }
    }
}

// MARK: Deleted messages

extension MessageList_Tests {
    func test_deletesMessage() throws {
        linkToScenario(withId: 386)

        throw XCTSkip("Check out SWUI-254")

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

    func test_messageDeleted_whenParticipantDeletesMessage() throws {
        linkToScenario(withId: 387)

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

    func test_threadReplyIsRemovedEverywhere_whenParticipantRemovesItFromChannel() {
        linkToScenario(withId: 390)

        let threadReply = "thread reply"

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(count: 1, messagesCount: 1)
            userRobot.login().openChannel()
        }
        AND("participant adds a thread reply and sends it also to main channel") {
            participantRobot.replyToMessageInThread(threadReply, alsoSendInChannel: true)
        }
        WHEN("participant removes the thread reply from channel") {
            participantRobot.deleteMessage()
        }
        THEN("user observes the thread reply removed in channel") {
            userRobot.assertDeletedMessage()
        }
        AND("user observes the thread reply removed in thread") {
            userRobot
                .openThread(messageCellIndex: 1, waitForThreadIcon: true)
                .assertDeletedMessage()
        }
    }

    func test_threadReplyIsRemovedEverywhere_whenUserRemovesItFromChannel() {
        linkToScenario(withId: 391)

        let threadReply = "thread reply"

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(count: 1, messagesCount: 1)
            userRobot.login().openChannel()
        }
        AND("user adds a thread reply and sends it also to main channel") {
            userRobot.replyToMessageInThread(threadReply, alsoSendInChannel: true)
        }
        WHEN("user removes thread reply from thread") {
            userRobot.deleteMessage()
        }
        THEN("user observes the thread reply removed in thread") {
            userRobot.assertDeletedMessage()
        }
        AND("user observes the thread reply removed in channel") {
            userRobot
                .tapOnBackButton()
                .assertDeletedMessage()
        }
    }

    func test_participantRemovesThreadReply() {
        linkToScenario(withId: 392)

        let threadReply = "thread reply"

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(count: 1, messagesCount: 1)
            userRobot.login().openChannel()
        }
        AND("participant adds a thread reply") {
            participantRobot.replyToMessageInThread(threadReply, alsoSendInChannel: false)
        }
        WHEN("participant removes the thread reply") {
            participantRobot.deleteMessage()
        }
        THEN("user observes a thread reply count button in channel") {
            userRobot.assertThreadReplyCountButton()
        }
        THEN("user observes the thread reply removed in thread") {
            userRobot.openThread().assertDeletedMessage()
        }
    }

    func test_threadReplyIsRemovedEverywhere_whenUserRemovesItFromThread() throws {
        linkToScenario(withId: 393)

        throw XCTSkip("Check out SWUI-244")

        let threadReply = "thread reply"

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(count: 1, messagesCount: 1)
            userRobot.login().openChannel()
        }
        AND("user adds a thread reply and sends it also to main channel") {
            userRobot.replyToMessageInThread(threadReply, alsoSendInChannel: true)
        }
        WHEN("user goes back to channel and removes thread reply") {
            userRobot
                .tapOnBackButton()
                .deleteMessage()
        }
        THEN("user observes the thread reply removed in channel") {
            userRobot.assertDeletedMessage()
        }
        AND("user observes the thread reply removed in thread") {
            userRobot
                .openThread(messageCellIndex: 1)
                .assertDeletedMessage()
        }
    }

    func test_userRemovesThreadReply() throws {
        linkToScenario(withId: 394)

        throw XCTSkip("Check out SWUI-244")

        let threadReply = "thread reply"

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(count: 1, messagesCount: 1)
            userRobot.login().openChannel()
        }
        AND("user adds a thread reply") {
            userRobot.replyToMessageInThread(threadReply, alsoSendInChannel: false)
        }
        WHEN("user removes the thread reply") {
            userRobot.deleteMessage()
        }
        THEN("user observes the thread reply removed in thread") {
            userRobot.assertDeletedMessage()
        }
        AND("user observes a thread reply count button in channel") {
            userRobot
                .tapOnBackButton()
                .assertThreadReplyCountButton()
        }
    }

    func test_hardDeletesMessage() throws {
        linkToScenario(withId: 395)

        throw XCTSkip("Check out SWUI-245")

        let message = "test message"

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(count: 1, messagesCount: 1)
            userRobot.login().openChannel()
        }
        WHEN("user sends the message: '\(message)'") {
            userRobot.sendMessage(message)
        }
        AND("user hard-deletes the message: '\(message)'") {
            userRobot.deleteMessage(hard: true)
        }
        THEN("the message is hard-deleted") {
            userRobot.assertHardDeletedMessage(withText: message)
        }
    }

    func test_messageDeleted_whenParticipantHardDeletesMessage() throws {
        linkToScenario(withId: 396)

        let message = "test message"

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(count: 1, messagesCount: 1)
            userRobot.login().openChannel()
        }
        WHEN("participant sends the message: '\(message)'") {
            participantRobot.sendMessage(message)
        }
        AND("the message is delivered") {
            userRobot.assertMessage(message)
        }
        AND("participant hard-deletes the message: '\(message)'") {
            participantRobot.deleteMessage(hard: true)
        }
        THEN("the message is hard-deleted") {
            userRobot.assertHardDeletedMessage(withText: message)
        }
    }
}
