//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import XCTest

extension ChannelList_Tests {
    func test_channelPreviewIsUpdated_whenThreadReplyIsSentAlsoInTheChannel() {
        let channelMessage = "Channel message"
        let threadReply = "Thread reply"

        GIVEN("user opens the channel") {
            userRobot
                .login()
                .openChannel()
        }
        AND("user sends a message") {
            userRobot.sendMessage(channelMessage)
        }
        AND("user adds thread reply to this message also in the channel") {
            userRobot.sendMessageInThread(threadReply, alsoSendInChannel: true)
        }
        WHEN("user goes back to the channel list") {
            userRobot.moveToChannelListFromThreadReplies()
        }
        THEN("the channel preview shows the thread reply") {
            userRobot.assertChannelPreview(contains: threadReply)
        }
        AND("last message timestamp is shown") {
            userRobot.assertLastMessageTimestampInChannelPreview(isHidden: false)
        }
    }

    func test_channelPreviewShowsMessageDeleted_whenTheOnlyMessageInChannelIsDeleted() {
        GIVEN("user opens the channel") {
            userRobot
                .login()
                .openChannel()
        }
        AND("participant sends a message") {
            participantRobot.sendMessage(message)
            userRobot.assertMessage(message)
        }
        AND("participant deletes the message") {
            participantRobot.deleteMessage()
        }
        WHEN("user goes back to the channel list") {
            userRobot.tapOnBackButton()
        }
        THEN("the channel preview shows the deleted message placeholder") {
            userRobot.assertChannelPreview(contains: "Message deleted")
        }
        AND("last message timestamp is shown") {
            userRobot.assertLastMessageTimestampInChannelPreview(isHidden: false)
        }
    }

    func test_channelPreviewIsUpdated_whenParticipantEditsPreviewMessage() {
        let editedMessage = "edited message"

        GIVEN("user opens the channel") {
            userRobot
                .login()
                .openChannel()
        }
        AND("participant sends a message") {
            participantRobot.sendMessage(message)
            userRobot.assertMessage(message)
        }
        WHEN("participant edits the message") {
            participantRobot.editMessage(editedMessage)
            userRobot.assertMessage(editedMessage)
        }
        AND("user goes back to the channel list") {
            userRobot.tapOnBackButton()
        }
        THEN("the channel preview shows the edited message") {
            userRobot.assertChannelPreview(contains: editedMessage)
        }
    }
}

// MARK: - Truncate channel

extension ChannelList_Tests {
    func test_messageList_and_channelPreview_AreUpdatedWhenChannelTruncatedWithMessage() {
        let message = "Channel truncated"

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(channelsCount: 1, messagesCount: 42)
            userRobot.login().openChannel()
        }
        WHEN("the channel is truncated with system message") {
            backendRobot.truncateChannel(withMessage: true)
        }
        THEN("user observes only the system message") {
            userRobot
                .assertSystemMessage(message)
                .assertMessageCount(1)
                .assertScrollToBottomButton(isVisible: false)
                .assertScrollToBottomButtonUnreadCount(0)
        }
        WHEN("user goes to channel list") {
            userRobot.tapOnBackButton()
        }
        THEN("the channel preview shows system message") {
            userRobot.assertChannelPreview(contains: message)
        }
        AND("last message timestamp is shown") {
            userRobot.assertLastMessageTimestampInChannelPreview(isHidden: false)
        }
    }

    func test_messageList_and_channelPreview_AreUpdatedWhenChannelTruncatedWithoutMessage() throws {
        try XCTSkipIf(true, "The channel preview shows a timestamp (31/12/1) for a channel truncated without a message")

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(channelsCount: 1, messagesCount: 42)
            userRobot.login().openChannel()
        }
        WHEN("the channel is truncated without system message") {
            backendRobot.truncateChannel(withMessage: false)
        }
        THEN("user observes no messages") {
            userRobot
                .assertMessageCount(0)
                .assertScrollToBottomButton(isVisible: false)
                .assertScrollToBottomButtonUnreadCount(0)
        }
        WHEN("user goes to channel list") {
            userRobot.tapOnBackButton()
        }
        THEN("the channel preview is empty") {
            userRobot.assertChannelPreview(contains: "No messages")
        }
        AND("last message timestamp is not shown") {
            userRobot.assertLastMessageTimestampInChannelPreview(isHidden: true)
        }
    }
}

// MARK: - Typing indicator

extension ChannelList_Tests {
    func test_typingIndicatorShownInChannelPreview_whenParticipantTypes() {
        GIVEN("user opens the channel list") {
            userRobot.login().waitForChannelListToLoad()
        }
        WHEN("participant starts typing") {
            participantRobot.startTyping()
        }
        THEN("the channel preview shows the typing indicator") {
            userRobot.assertTypingIndicatorInChannelPreview(isShown: true)
        }
        WHEN("participant stops typing") {
            participantRobot.stopTyping()
        }
        THEN("the channel preview hides the typing indicator") {
            userRobot.assertTypingIndicatorInChannelPreview(isShown: false)
        }
    }
}
