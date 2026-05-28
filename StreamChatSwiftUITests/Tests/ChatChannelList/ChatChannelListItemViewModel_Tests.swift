//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import XCTest

@MainActor final class ChatChannelListItemViewModel_Tests: StreamChatTestCase {
    override func setUp() {
        super.setUp()
        streamChat?.utils.messageListConfig = .init(draftMessagesEnabled: true)
        streamChat?.utils.channelListConfig.channelItemMutedStyle = .bottomRightCorner
    }

    // MARK: - Title row

    func test_channelName_returnsInitializerValueByDefault() {
        let channel = ChatChannel.mock(cid: .unique)
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "Provided")

        XCTAssertEqual(viewModel.channelName, "Provided")
    }

    func test_channelName_canBeOverriddenBySubclass() {
        final class CustomViewModel: ChatChannelListItemViewModel {
            override var channelName: String { "Overridden" }
        }
        let channel = ChatChannel.mock(cid: .unique)
        let viewModel = CustomViewModel(channel: channel, channelName: "Test")

        XCTAssertEqual(viewModel.channelName, "Overridden")
    }

    func test_timestampText_whenLastMessageAtIsNil_returnsEmptyString() {
        let channel = ChatChannel.mock(cid: .unique, lastMessageAt: nil)
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "Test")

        XCTAssertEqual(viewModel.timestampText, "")
    }

    func test_timestampText_whenLastMessageAtIsPresent_returnsFormattedString() {
        let channel = ChatChannel.mock(cid: .unique, lastMessageAt: Date(timeIntervalSince1970: 100))
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "Test")

        XCTAssertFalse(viewModel.timestampText.isEmpty)
    }

    func test_unreadCount_returnsChannelUnreadMessagesCount() {
        let channel = ChatChannel.mock(cid: .unique, unreadCount: .mock(messages: 7))
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "Test")

        XCTAssertEqual(viewModel.unreadCount, 7)
    }

    func test_hasUnread_whenChannelHasNoUnreads_returnsFalse() {
        let channel = ChatChannel.mock(cid: .unique, unreadCount: .noUnread)
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "Test")

        XCTAssertFalse(viewModel.hasUnread)
    }

    func test_hasUnread_whenChannelHasUnreads_returnsTrue() {
        let channel = ChatChannel.mock(cid: .unique, unreadCount: .mock(messages: 1))
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "Test")

        XCTAssertTrue(viewModel.hasUnread)
    }

    func test_isMuted_followsChannelMuteDetails() {
        let muted = ChatChannel.mock(
            cid: .unique,
            muteDetails: .init(createdAt: .unique, updatedAt: .unique, expiresAt: nil)
        )
        let notMuted = ChatChannel.mock(cid: .unique)

        XCTAssertTrue(ChatChannelListItemViewModel(channel: muted, channelName: "T").isMuted)
        XCTAssertFalse(ChatChannelListItemViewModel(channel: notMuted, channelName: "T").isMuted)
    }

    func test_shouldShowInlineMutedIcon_whenMutedAndAfterChannelNameStyle_returnsTrue() {
        streamChat?.utils.channelListConfig.channelItemMutedStyle = .afterChannelName
        let channel = ChatChannel.mock(
            cid: .unique,
            muteDetails: .init(createdAt: .unique, updatedAt: .unique, expiresAt: nil)
        )
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "T")

        XCTAssertTrue(viewModel.shouldShowInlineMutedIcon)
        XCTAssertFalse(viewModel.shouldShowMutedTrailingIcon)
    }

    func test_shouldShowMutedTrailingIcon_whenMutedAndBottomRightCornerStyle_returnsTrue() {
        streamChat?.utils.channelListConfig.channelItemMutedStyle = .bottomRightCorner
        let channel = ChatChannel.mock(
            cid: .unique,
            muteDetails: .init(createdAt: .unique, updatedAt: .unique, expiresAt: nil)
        )
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "T")

        XCTAssertTrue(viewModel.shouldShowMutedTrailingIcon)
        XCTAssertFalse(viewModel.shouldShowInlineMutedIcon)
    }

    func test_mutedIconFlags_whenChannelIsNotMuted_returnFalse() {
        let channel = ChatChannel.mock(cid: .unique)
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "T")

        XCTAssertFalse(viewModel.shouldShowInlineMutedIcon)
        XCTAssertFalse(viewModel.shouldShowMutedTrailingIcon)
    }

    // MARK: - Subtitle: author

    func test_subtitleAuthorName_whenDMChannelWithTwoMembers_returnsNil() {
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hi",
            author: .mock(id: "other", name: "Other"),
            isSentByCurrentUser: false
        )
        let channel = ChatChannel.mockDMChannel(memberCount: 2, latestMessages: [message])
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "Other")

        XCTAssertNil(viewModel.subtitleAuthorName)
    }

    func test_subtitleAuthorName_whenGroupChannelSentByCurrentUser_returnsYou() {
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hi",
            author: .mock(id: Self.currentUserId, name: "Me"),
            isSentByCurrentUser: true
        )
        let channel = ChatChannel.mockNonDMChannel(latestMessages: [message])
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "Group")

        XCTAssertEqual(viewModel.subtitleAuthorName, L10n.Channel.Item.you)
    }

    func test_subtitleAuthorName_whenGroupChannelSentByOther_returnsAuthorName() {
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hi",
            author: .mock(id: "yoda", name: "Yoda"),
            isSentByCurrentUser: false
        )
        let channel = ChatChannel.mockNonDMChannel(latestMessages: [message])
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "Group")

        XCTAssertEqual(viewModel.subtitleAuthorName, "Yoda")
    }

    func test_subtitleAuthorName_whenPreviewMessageIsPoll_returnsNil() {
        let pollMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: .mock(id: "u", name: "User"),
            isSentByCurrentUser: false,
            poll: .mock(name: "Pick one")
        )
        let channel = ChatChannel.mockNonDMChannel(latestMessages: [pollMessage])
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "Group")

        XCTAssertNil(viewModel.subtitleAuthorName)
    }

    func test_subtitleAuthorName_whenNoPreviewMessage_returnsNil() {
        let channel = ChatChannel.mockNonDMChannel(latestMessages: [])
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "Group")

        XCTAssertNil(viewModel.subtitleAuthorName)
    }

    // MARK: - Subtitle: text

    func test_subtitleText_whenNoPreviewMessage_returnsEmptyMessagesPlaceholder() {
        let channel = ChatChannel.mock(cid: .unique, latestMessages: [])
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "T")

        XCTAssertEqual(viewModel.subtitleText, L10n.Channel.Item.emptyMessages)
    }

    func test_subtitleText_whenPreviewMessagePresent_returnsFormattedString() {
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hello there",
            author: .mock(id: "u", name: "User"),
            isSentByCurrentUser: false
        )
        let channel = ChatChannel.mockNonDMChannel(latestMessages: [message])
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "Group")

        XCTAssertTrue(viewModel.subtitleText.contains("Hello there"))
    }

    func test_previewMessage_skipsEphemeralMessages() {
        let regular = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hello there",
            type: .regular,
            author: .mock(id: "u", name: "User"),
            createdAt: Date(timeIntervalSince1970: 100),
            isSentByCurrentUser: false
        )
        let ephemeral = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "/giphy cats",
            type: .ephemeral,
            author: .mock(id: Self.currentUserId, name: "Me"),
            createdAt: Date(timeIntervalSince1970: 200),
            isSentByCurrentUser: true
        )
        let channel = ChatChannel.mockDMChannel(memberCount: 2, latestMessages: [ephemeral, regular])
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "Other")

        XCTAssertFalse(viewModel.isPreviewMessageSentByCurrentUser)
        XCTAssertTrue(viewModel.subtitleText.contains("Hello there"))
    }

    func test_isPreviewMessageDeleted_whenPreviewIsDeleted_returnsTrue() {
        let date = Date(timeIntervalSince1970: 100)
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Deleted",
            author: .mock(id: "u", name: "User"),
            createdAt: date.addingTimeInterval(-100),
            deletedAt: date,
            isSentByCurrentUser: false
        )
        let channel = ChatChannel.mock(cid: .unique, latestMessages: [message])
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "T")

        XCTAssertTrue(viewModel.isPreviewMessageDeleted)
    }

    func test_isPreviewMessageSentByCurrentUser_followsMessageFlag() {
        let mine = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hi",
            author: .mock(id: Self.currentUserId, name: "Me"),
            isSentByCurrentUser: true
        )
        let others = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hi",
            author: .mock(id: "other", name: "Other"),
            isSentByCurrentUser: false
        )

        let mineChannel = ChatChannel.mock(cid: .unique, latestMessages: [mine])
        let othersChannel = ChatChannel.mock(cid: .unique, latestMessages: [others])

        XCTAssertTrue(
            ChatChannelListItemViewModel(channel: mineChannel, channelName: "T")
                .isPreviewMessageSentByCurrentUser
        )
        XCTAssertFalse(
            ChatChannelListItemViewModel(channel: othersChannel, channelName: "T")
                .isPreviewMessageSentByCurrentUser
        )
    }

    // MARK: - Failed to send

    func test_lastMessageFailedToSend_whenLocalStateIsSendingFailed_returnsTrue() {
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hi",
            author: .mock(id: Self.currentUserId, name: "Me"),
            localState: .sendingFailed,
            isSentByCurrentUser: true
        )
        let channel = ChatChannel.mock(cid: .unique, latestMessages: [message])
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "T")

        XCTAssertTrue(viewModel.lastMessageFailedToSend)
    }

    func test_lastMessageFailedToSend_whenLocalStateIsNil_returnsFalse() {
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hi",
            author: .mock(id: Self.currentUserId, name: "Me"),
            localState: nil,
            isSentByCurrentUser: true
        )
        let channel = ChatChannel.mock(cid: .unique, latestMessages: [message])
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "T")

        XCTAssertFalse(viewModel.lastMessageFailedToSend)
    }

    // MARK: - Drafts

    func test_isDraftMessagesEnabled_followsConfig() {
        streamChat?.utils.messageListConfig = .init(draftMessagesEnabled: true)
        let channel = ChatChannel.mock(cid: .unique)
        XCTAssertTrue(
            ChatChannelListItemViewModel(channel: channel, channelName: "T")
                .isDraftMessagesEnabled
        )

        streamChat?.utils.messageListConfig = .init(draftMessagesEnabled: false)
        XCTAssertFalse(
            ChatChannelListItemViewModel(channel: channel, channelName: "T")
                .isDraftMessagesEnabled
        )
    }

    func test_draftMessageText_whenNoDraft_returnsNil() {
        let channel = ChatChannel.mock(cid: .unique, draftMessage: nil)
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "T")

        XCTAssertNil(viewModel.draftMessageText)
    }

    func test_draftMessageText_whenDraftPresent_returnsFormattedString() {
        let draft = DraftMessage.mock(text: "Draft text")
        let channel = ChatChannel.mock(cid: .unique, draftMessage: draft)
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "T")

        XCTAssertEqual(viewModel.draftMessageText, "Draft text")
    }

    // MARK: - Read events

    func test_shouldShowReadEvents_whenLastMessageFailedToSend_returnsFalse() {
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hi",
            author: .mock(id: Self.currentUserId, name: "Me"),
            localState: .sendingFailed,
            isSentByCurrentUser: true
        )
        let channel = ChatChannel.mock(cid: .unique, latestMessages: [message])
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "T")

        XCTAssertFalse(viewModel.shouldShowReadEvents)
    }

    func test_shouldShowReadEvents_whenDraftPresentAndDraftsEnabled_returnsFalse() {
        let myMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hi",
            author: .mock(id: Self.currentUserId, name: "Me"),
            isSentByCurrentUser: true
        )
        let draft = DraftMessage.mock(text: "Draft")
        let channel = ChatChannel.mock(
            cid: .unique,
            latestMessages: [myMessage],
            draftMessage: draft
        )
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "T")

        XCTAssertFalse(viewModel.shouldShowReadEvents)
    }

    func test_shouldShowReadEvents_whenSentByCurrentUserAndReadEventsEnabled_returnsTrue() {
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hi",
            author: .mock(id: Self.currentUserId, name: "Me"),
            isSentByCurrentUser: true
        )
        let channel = ChatChannel.mock(
            cid: .unique,
            config: .mock(readEventsEnabled: true),
            latestMessages: [message]
        )
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "T")

        XCTAssertTrue(viewModel.shouldShowReadEvents)
    }

    func test_shouldShowReadEvents_whenSentByOtherUser_returnsFalse() {
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hi",
            author: .mock(id: "other", name: "Other"),
            isSentByCurrentUser: false
        )
        let channel = ChatChannel.mock(cid: .unique, latestMessages: [message])
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "T")

        XCTAssertFalse(viewModel.shouldShowReadEvents)
    }

    func test_shouldShowReadEvents_whenReadEventsDisabled_returnsFalse() {
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hi",
            author: .mock(id: Self.currentUserId, name: "Me"),
            isSentByCurrentUser: true
        )
        let channel = ChatChannel.mock(
            cid: .unique,
            config: .mock(readEventsEnabled: false),
            latestMessages: [message]
        )
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "T")

        XCTAssertFalse(viewModel.shouldShowReadEvents)
    }

    func test_previewMessageLocalState_returnsPreviewMessageLocalState() {
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hi",
            author: .mock(id: Self.currentUserId, name: "Me"),
            localState: .sendingFailed,
            isSentByCurrentUser: true
        )
        let channel = ChatChannel.mock(cid: .unique, latestMessages: [message])
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "T")

        XCTAssertEqual(viewModel.previewMessageLocalState, .sendingFailed)
    }

    // MARK: - Typing indicator

    func test_shouldShowTypingIndicator_whenNoOneIsTyping_returnsFalse() {
        let channel = ChatChannel.mock(
            cid: .unique,
            config: .mock(typingEventsEnabled: true),
            currentlyTypingUsers: []
        )
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "T")

        XCTAssertFalse(viewModel.shouldShowTypingIndicator)
    }

    func test_shouldShowTypingIndicator_whenSomeoneIsTypingAndEventsEnabled_returnsTrue() {
        let typingUser = ChatUser.mock(id: "yoda", name: "Yoda")
        let channel = ChatChannel.mock(
            cid: .unique,
            config: .mock(typingEventsEnabled: true),
            currentlyTypingUsers: [typingUser]
        )
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "T")

        XCTAssertTrue(viewModel.shouldShowTypingIndicator)
    }

    func test_shouldShowTypingIndicator_whenTypingEventsDisabled_returnsFalse() {
        let typingUser = ChatUser.mock(id: "yoda", name: "Yoda")
        let channel = ChatChannel.mock(
            cid: .unique,
            config: .mock(typingEventsEnabled: false),
            currentlyTypingUsers: [typingUser]
        )
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "T")

        XCTAssertFalse(viewModel.shouldShowTypingIndicator)
    }

    // MARK: - Subtitle (combined)

    func test_subtitle_whenLastMessageFailedToSend_returnsFailedToSend() {
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hi",
            author: .mock(id: Self.currentUserId, name: "Me"),
            localState: .sendingFailed,
            isSentByCurrentUser: true
        )
        let channel = ChatChannel.mock(cid: .unique, latestMessages: [message])
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "T")

        guard case .failedToSend = viewModel.subtitle.kind else {
            return XCTFail("Expected .failedToSend, got \(viewModel.subtitle.kind)")
        }
    }

    func test_subtitle_whenTyping_returnsTypingWithText() {
        let typingUser = ChatUser.mock(id: "yoda", name: "Yoda")
        let channel = ChatChannel.mock(
            cid: .unique,
            config: .mock(typingEventsEnabled: true),
            currentlyTypingUsers: [typingUser]
        )
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "T")

        guard case let .typing(text) = viewModel.subtitle.kind else {
            return XCTFail("Expected .typing, got \(viewModel.subtitle.kind)")
        }
        XCTAssertEqual(text, viewModel.typingIndicatorText)
        XCTAssertFalse(text.isEmpty)
    }

    func test_typingIndicatorText_matchesChannelTypingIndicatorString() {
        let typingUser = ChatUser.mock(id: "yoda", name: "Yoda")
        let channel = ChatChannel.mock(
            cid: .unique,
            config: .mock(typingEventsEnabled: true),
            currentlyTypingUsers: [typingUser]
        )
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "T")

        XCTAssertEqual(
            viewModel.typingIndicatorText,
            channel.typingIndicatorString(currentUserId: Self.currentUserId)
        )
    }

    func test_subtitle_whenDraftAvailableAndEnabled_returnsDraftWithText() {
        let draft = DraftMessage.mock(text: "Draft text")
        let channel = ChatChannel.mock(cid: .unique, draftMessage: draft)
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "T")

        guard case let .draft(text) = viewModel.subtitle.kind else {
            return XCTFail("Expected .draft, got \(viewModel.subtitle.kind)")
        }
        XCTAssertEqual(text, "Draft text")
    }

    func test_subtitle_whenPreviewMessageDeleted_returnsDeleted() {
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hi",
            author: .mock(id: Self.currentUserId, name: "Me"),
            createdAt: Date(timeIntervalSince1970: 0),
            deletedAt: Date(timeIntervalSince1970: 100),
            isSentByCurrentUser: true
        )
        let channel = ChatChannel.mock(cid: .unique, latestMessages: [message])
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "T")

        guard case let .deleted(isSentByCurrentUser) = viewModel.subtitle.kind else {
            return XCTFail("Expected .deleted, got \(viewModel.subtitle.kind)")
        }
        XCTAssertTrue(isSentByCurrentUser)
    }

    func test_subtitle_whenGroupChannelWithMessage_returnsAuthorPreview() {
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hello there",
            author: .mock(id: "yoda", name: "Yoda"),
            isSentByCurrentUser: false
        )
        let channel = ChatChannel.mockNonDMChannel(latestMessages: [message])
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "Group")

        guard case let .authorPreview(authorName, contentText, attachmentIcon) = viewModel.subtitle.kind else {
            return XCTFail("Expected .authorPreview, got \(viewModel.subtitle.kind)")
        }
        XCTAssertEqual(authorName, "Yoda")
        XCTAssertTrue(contentText.contains("Hello there"))
        XCTAssertNil(attachmentIcon)
    }

    func test_subtitle_whenDMChannelWithoutAuthorPrefix_returnsPlainText() {
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hi",
            author: .mock(id: "other", name: "Other"),
            isSentByCurrentUser: false
        )
        let channel = ChatChannel.mockDMChannel(memberCount: 2, latestMessages: [message])
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "Other")

        guard case let .plain(text) = viewModel.subtitle.kind else {
            return XCTFail("Expected .plain, got \(viewModel.subtitle.kind)")
        }
        XCTAssertTrue(text.contains("Hi"))
    }

    func test_subtitle_whenNoPreviewMessage_returnsPlainEmptyPlaceholder() {
        let channel = ChatChannel.mock(cid: .unique, latestMessages: [])
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "T")

        guard case let .plain(text) = viewModel.subtitle.kind else {
            return XCTFail("Expected .plain, got \(viewModel.subtitle.kind)")
        }
        XCTAssertEqual(text, L10n.Channel.Item.emptyMessages)
    }

    func test_subtitle_precedence_failedToSendBeatsTyping() {
        let typingUser = ChatUser.mock(id: "yoda", name: "Yoda")
        let failed = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hi",
            author: .mock(id: Self.currentUserId, name: "Me"),
            localState: .sendingFailed,
            isSentByCurrentUser: true
        )
        let channel = ChatChannel.mock(
            cid: .unique,
            config: .mock(typingEventsEnabled: true),
            currentlyTypingUsers: [typingUser],
            latestMessages: [failed]
        )
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "T")

        guard case .failedToSend = viewModel.subtitle.kind else {
            return XCTFail("Expected .failedToSend to win over typing, got \(viewModel.subtitle.kind)")
        }
    }
}
