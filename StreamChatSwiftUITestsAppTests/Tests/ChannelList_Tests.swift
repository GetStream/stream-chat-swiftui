//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import XCTest

final class ChannelList_Tests: StreamTestCase {

    let message = "message"

    override func setUpWithError() throws {
        try super.setUpWithError()
        addTags([.coreFeatures])
    }

    func test_newMessageShownInChannelPreview_whenComingBackFromChannel() {
        linkToScenario(withId: 348)

        GIVEN("user opens the channel") {
            userRobot
                .login()
                .openChannel()
        }
        WHEN("participant sends a new message") {
            participantRobot.sendMessage(message)
        }
        AND("user goes back to channel list") {
            userRobot.tapOnBackButton()
        }
        THEN("user observes a preview of participants message") {
            userRobot.assertLastMessageInChannelPreview(message)
        }
    }

    func test_participantMessageShownInChannelPreview_whenReturningFromOffline() throws {
        linkToScenario(withId: 349)

        throw XCTSkip("Check out SWUI-245")

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
                .wait(2.0)
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

        throw XCTSkip("Check out SWUI-253")

        let channelsCount = 30

        WHEN("user opens the channel list") {
            backendRobot.generateChannels(count: channelsCount)
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

    func test_channelPreviewShowsNoMessages_whenChannelIsEmpty() {
        linkToScenario(withId: 352)

        WHEN("user opens channel list") {
            userRobot.login()
        }
        AND("the channel has no messages") {}
        THEN("the channel preview shows No messages") {
            userRobot.assertLastMessageInChannelPreview(message)
        }
        AND("last message timestamp is hidden") {
            userRobot.assertLastMessageTimestampInChannelPreview(isHidden: true)
        }
    }

    func test_channelPreviewShowsNoMessages_whenTheOnlyMessageInChannelIsDeleted() throws {
        linkToScenario(withId: 353)

        throw XCTSkip("Check out SWUI-246")

        let message = "Hey"

        GIVEN("user opens the channel") {
            userRobot
                .login()
                .openChannel()
        }
        AND("user sends a message") {
            userRobot.sendMessage(message)
        }
        AND("user deletes the message") {
            userRobot.deleteMessage()
        }
        WHEN("user goes back to the channel list") {
            userRobot.tapOnBackButton()
        }
        THEN("the channel preview shows No messages") {
            userRobot.assertLastMessageInChannelPreview("No messages")
        }
        AND("last message timestamp is hidden") {
            userRobot.assertLastMessageTimestampInChannelPreview(isHidden: true)
        }
    }

    func test_channelPreviewShowsPreviousMessage_whenLastMessageIsDeleted() throws {
        linkToScenario(withId: 354)

        throw XCTSkip("Check out SWUI-246")

        let message1 = "Previous message"
        let message2 = "Last message"

        GIVEN("user opens the channel") {
            userRobot
                .login()
                .openChannel()
        }
        AND("user sends 2 messages") {
            userRobot
                .sendMessage(message1)
                .sendMessage(message2)
        }
        AND("user deletes the last message") {
            userRobot.deleteMessage()
        }
        WHEN("user goes back to the channel list") {
            userRobot.tapOnBackButton()
        }
        THEN("the channel preview shows previous message") {
            userRobot.assertLastMessageInChannelPreview(message1)
        }
        AND("last message timestamp is shown") {
            userRobot.assertLastMessageTimestampInChannelPreview(isHidden: false)
        }
    }

    func test_channelPreviewIsNotUpdated_whenThreadReplyIsSent() throws {
        linkToScenario(withId: 355)

        throw XCTSkip("Check out SWUI-244")

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
        AND("user adds thread reply to this message") {
            userRobot.replyToMessageInThread(threadReply)
        }
        WHEN("user goes back to the channel list") {
            userRobot.moveToChannelListFromThreadReplies()
        }
        THEN("the channel preview shows the last message in the channel") {
            userRobot.assertLastMessageInChannelPreview(channelMessage)
        }
        AND("last message timestamp is shown") {
            userRobot.assertLastMessageTimestampInChannelPreview(isHidden: false)
        }
    }

    func test_channelPreviewIsUpdated_whenPreviewMessageIsEdited() {
        linkToScenario(withId: 356)

        let originalMessage = "message"
        let editedMessage = "edited message"

        GIVEN("user opens the channel") {
            userRobot
                .login()
                .openChannel()
        }
        AND("user sends a message") {
            userRobot.sendMessage(originalMessage)
        }
        WHEN("user edits the message") {
            userRobot.editMessage(editedMessage)
        }
        AND("user goes back to the channel list") {
            userRobot.tapOnBackButton()
        }
        THEN("the channel preview shows edited message") {
            userRobot.assertLastMessageInChannelPreview(editedMessage)
        }
        AND("last message timestamp is shown") {
            userRobot.assertLastMessageTimestampInChannelPreview(isHidden: false)
        }
    }
}

// MARK: - Truncate channel

extension ChannelList_Tests {

    func test_messageList_and_channelPreview_AreUpdatedWhenChannelTruncatedWithMessage() throws {
        linkToScenario(withId: 357)

        throw XCTSkip("Check out SWUI-245")

        let message = "Channel truncated"

        GIVEN("user opens the channel") {
            backendRobot.generateChannels(count: 1, messagesCount: 42)
            userRobot.login().openChannel()
        }
        WHEN("user truncates the channel with system message") {
            userRobot.truncateChannel(withMessage: true)
        }
        THEN("user observes only the system message") {
            userRobot
                .assertMessage(message)
                .assertMessageCount(1)
                .assertScrollToBottomButton(isVisible: false)
                .assertScrollToBottomButtonUnreadCount(0)
        }
        WHEN("user goes to channel list") {
            userRobot.tapOnBackButton()
        }
        THEN("the channel preview shows system message") {
            userRobot.assertLastMessageInChannelPreview(message)
        }
        AND("last message timestamp is shown") {
            userRobot.assertLastMessageTimestampInChannelPreview(isHidden: false)
        }
    }
}
