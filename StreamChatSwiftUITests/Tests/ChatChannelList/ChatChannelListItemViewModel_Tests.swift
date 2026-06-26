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

    func test_showInlineMutedIcon_whenMutedAndAfterChannelNameStyle_returnsTrue() {
        streamChat?.utils.channelListConfig.channelItemMutedStyle = .afterChannelName
        let channel = ChatChannel.mock(
            cid: .unique,
            muteDetails: .init(createdAt: .unique, updatedAt: .unique, expiresAt: nil)
        )
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "T")

        XCTAssertTrue(viewModel.showInlineMutedIcon)
        XCTAssertFalse(viewModel.showMutedTrailingIcon)
    }

    func test_showMutedTrailingIcon_whenMutedAndBottomRightCornerStyle_returnsTrue() {
        streamChat?.utils.channelListConfig.channelItemMutedStyle = .bottomRightCorner
        let channel = ChatChannel.mock(
            cid: .unique,
            muteDetails: .init(createdAt: .unique, updatedAt: .unique, expiresAt: nil)
        )
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "T")

        XCTAssertTrue(viewModel.showMutedTrailingIcon)
        XCTAssertFalse(viewModel.showInlineMutedIcon)
    }

    func test_mutedIconFlags_whenChannelIsNotMuted_returnFalse() {
        let channel = ChatChannel.mock(cid: .unique)
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "T")

        XCTAssertFalse(viewModel.showInlineMutedIcon)
        XCTAssertFalse(viewModel.showMutedTrailingIcon)
    }

    func test_preview_skipsEphemeralMessages() {
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

        let message = viewModel.preview.content as? ChannelItemPreview.MessageContent
        XCTAssertNotNil(message)
        XCTAssertTrue(message?.text.contains("Hello there") == true)
    }

    // MARK: - Read events

    func test_showReadEvents_whenLastMessageFailedToSend_returnsFalse() {
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

        XCTAssertFalse(viewModel.showReadEvents)
    }

    func test_showReadEvents_whenDraftPresentAndDraftsEnabled_returnsFalse() {
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

        XCTAssertFalse(viewModel.showReadEvents)
    }

    func test_showReadEvents_whenSentByCurrentUserAndReadEventsEnabled_returnsTrue() {
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

        XCTAssertTrue(viewModel.showReadEvents)
    }

    func test_showReadEvents_whenSentByOtherUser_returnsFalse() {
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hi",
            author: .mock(id: "other", name: "Other"),
            isSentByCurrentUser: false
        )
        let channel = ChatChannel.mock(cid: .unique, latestMessages: [message])
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "T")

        XCTAssertFalse(viewModel.showReadEvents)
    }

    func test_showReadEvents_whenReadEventsDisabled_returnsFalse() {
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

        XCTAssertFalse(viewModel.showReadEvents)
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

    // MARK: - Preview

    func test_preview_whenLastMessageFailedToSend_returnsFailedToSend() {
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

        XCTAssertTrue(viewModel.preview.content is ChannelItemPreview.FailedToSendContent)
    }

    func test_preview_whenTyping_returnsTypingWithChannel() {
        let typingUser = ChatUser.mock(id: "yoda", name: "Yoda")
        let channel = ChatChannel.mock(
            cid: .unique,
            config: .mock(typingEventsEnabled: true),
            currentlyTypingUsers: [typingUser]
        )
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "T")

        let typing = viewModel.preview.content as? ChannelItemPreview.TypingContent
        XCTAssertNotNil(typing)
        XCTAssertEqual(typing?.channel.cid, channel.cid)
    }

    func test_preview_whenDraftAvailableAndEnabled_returnsDraftWithText() {
        let draft = DraftMessage.mock(text: "Draft text")
        let channel = ChatChannel.mock(cid: .unique, draftMessage: draft)
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "T")

        let draftContent = viewModel.preview.content as? ChannelItemPreview.DraftContent
        XCTAssertNotNil(draftContent)
        XCTAssertEqual(draftContent?.text, "Draft text")
    }

    func test_preview_whenPreviewMessageDeleted_returnsDeleted() {
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

        let deleted = viewModel.preview.content as? ChannelItemPreview.DeletedContent
        XCTAssertNotNil(deleted)
        XCTAssertEqual(deleted?.isSentByCurrentUser, true)
    }

    func test_preview_whenGroupChannelWithMessage_includesAuthorName() {
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hello there",
            author: .mock(id: "yoda", name: "Yoda"),
            isSentByCurrentUser: false
        )
        let channel = ChatChannel.mockNonDMChannel(latestMessages: [message])
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "Group")

        let messageContent = viewModel.preview.content as? ChannelItemPreview.MessageContent
        XCTAssertNotNil(messageContent)
        XCTAssertEqual(messageContent?.authorName, "Yoda")
        XCTAssertTrue(messageContent?.text.contains("Hello there") == true)
        XCTAssertNil(messageContent?.attachmentIcon)
    }

    func test_preview_whenDMChannel_omitsAuthorName() {
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hi",
            author: .mock(id: "other", name: "Other"),
            isSentByCurrentUser: false
        )
        let channel = ChatChannel.mockDMChannel(memberCount: 2, latestMessages: [message])
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "Other")

        let messageContent = viewModel.preview.content as? ChannelItemPreview.MessageContent
        XCTAssertNotNil(messageContent)
        XCTAssertNil(messageContent?.authorName)
        XCTAssertTrue(messageContent?.text.contains("Hi") == true)
    }

    func test_preview_whenNoPreviewMessage_returnsEmptyPlaceholderText() {
        let channel = ChatChannel.mock(cid: .unique, latestMessages: [])
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "T")

        let messageContent = viewModel.preview.content as? ChannelItemPreview.MessageContent
        XCTAssertNotNil(messageContent)
        XCTAssertEqual(messageContent?.text, L10n.Channel.Item.emptyMessages)
        XCTAssertNil(messageContent?.authorName)
        XCTAssertNil(messageContent?.attachmentIcon)
    }

    func test_preview_precedence_failedToSendBeatsTyping() {
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

        XCTAssertTrue(viewModel.preview.content is ChannelItemPreview.FailedToSendContent)
    }

    // MARK: - Accessibility

    func test_accessibilityLabel_dmChannel_headerOmitsMemberCount() {
        let channel = ChatChannel.mockDMChannel(memberCount: 2, latestMessages: [])
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "Alice")

        let expected = [
            "Alice, \(L10n.Channel.Item.Accessibility.directMessage)",
            L10n.Channel.Item.emptyMessages
        ].joined(separator: ". ")
        XCTAssertEqual(viewModel.accessibilityLabel, expected)
    }

    func test_accessibilityLabel_groupChannel_includesGroupChatAndMemberCount() {
        let channel = ChatChannel.mockNonDMChannel(memberCount: 5, latestMessages: [])
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "Team")

        let expected = [
            "Team, \(L10n.Channel.Item.Accessibility.groupChat), \(L10n.Channel.Item.Accessibility.memberCount(5))",
            L10n.Channel.Item.emptyMessages
        ].joined(separator: ". ")
        XCTAssertEqual(viewModel.accessibilityLabel, expected)
    }

    func test_accessibilityLabel_groupChannel_usesSingularMemberForSingleMember() {
        let channel = ChatChannel.mockNonDMChannel(memberCount: 1, latestMessages: [])
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "Team")

        XCTAssertTrue(
            viewModel.accessibilityLabel.contains(L10n.Channel.Item.Accessibility.memberCount(1))
        )
    }

    func test_accessibilityLabel_whenChannelMuted_includesMutedState() {
        let channel = ChatChannel.mockNonDMChannel(
            memberCount: 3,
            latestMessages: [],
            muteDetails: .init(createdAt: .unique, updatedAt: .unique, expiresAt: nil)
        )
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "Team")

        let expected = [
            "Team, \(L10n.Channel.Item.Accessibility.groupChat), \(L10n.Channel.Item.Accessibility.memberCount(3))",
            L10n.Channel.Item.Accessibility.muted,
            L10n.Channel.Item.emptyMessages
        ].joined(separator: ". ")
        XCTAssertEqual(viewModel.accessibilityLabel, expected)
    }

    func test_accessibilityLabel_whenUnread_includesPluralUnreadCount() {
        let channel = ChatChannel.mockNonDMChannel(
            unreadCount: .mock(messages: 4),
            memberCount: 3,
            latestMessages: []
        )
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "Team")

        XCTAssertTrue(
            viewModel.accessibilityLabel.contains(L10n.Channel.Item.Accessibility.unreadCount(4))
        )
    }

    func test_accessibilityLabel_whenSingleUnread_includesSingularUnreadCount() {
        let channel = ChatChannel.mockNonDMChannel(
            unreadCount: .mock(messages: 1),
            memberCount: 3,
            latestMessages: []
        )
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "Team")

        XCTAssertTrue(
            viewModel.accessibilityLabel.contains(L10n.Channel.Item.Accessibility.unreadCount(1))
        )
    }

    func test_accessibilityLabel_whenNoUnread_omitsUnreadSentence() {
        let channel = ChatChannel.mockNonDMChannel(
            unreadCount: .noUnread,
            memberCount: 3,
            latestMessages: []
        )
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "Team")

        XCTAssertFalse(
            viewModel.accessibilityLabel.contains(L10n.Channel.Item.Accessibility.unreadCount(0))
        )
        XCTAssertFalse(viewModel.accessibilityLabel.contains("unread"))
    }

    func test_accessibilityLabel_lastMessageFromOtherUser() {
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hello there",
            author: .mock(id: "yoda", name: "Yoda"),
            isSentByCurrentUser: false
        )
        let channel = ChatChannel.mockNonDMChannel(
            lastMessageAt: Date(timeIntervalSince1970: 100_000),
            memberCount: 3,
            latestMessages: [message]
        )
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "Team")

        let expected = [
            "Team, \(L10n.Channel.Item.Accessibility.groupChat), \(L10n.Channel.Item.Accessibility.memberCount(3))",
            L10n.Channel.Item.Accessibility.lastMessage("Yoda", viewModel.timestampText, "Hello there")
        ].joined(separator: ". ")
        XCTAssertEqual(viewModel.accessibilityLabel, expected)
    }

    func test_accessibilityLabel_lastMessageFromCurrentUser_usesYouAndNoStatusWhenReadEventsDisabled() {
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "On my way",
            author: .mock(id: Self.currentUserId, name: "Me"),
            isSentByCurrentUser: true
        )
        let channel = ChatChannel.mockNonDMChannel(
            lastMessageAt: Date(timeIntervalSince1970: 100_000),
            config: .mock(readEventsEnabled: false),
            memberCount: 3,
            latestMessages: [message]
        )
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "Team")

        let expected = [
            "Team, \(L10n.Channel.Item.Accessibility.groupChat), \(L10n.Channel.Item.Accessibility.memberCount(3))",
            L10n.Channel.Item.Accessibility.lastMessage(
                L10n.Channel.Item.Accessibility.you,
                viewModel.timestampText,
                "On my way"
            )
        ].joined(separator: ". ")
        XCTAssertEqual(viewModel.accessibilityLabel, expected)
    }

    func test_accessibilityLabel_whenReadEventsEnabledAndNoReaders_includesSentStatus() {
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Ping",
            author: .mock(id: Self.currentUserId, name: "Me"),
            createdAt: Date(timeIntervalSince1970: 100),
            isSentByCurrentUser: true
        )
        let channel = ChatChannel.mockNonDMChannel(
            lastMessageAt: Date(timeIntervalSince1970: 100_000),
            config: .mock(readEventsEnabled: true),
            memberCount: 3,
            latestMessages: [message]
        )
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "Team")

        let expected = [
            "Team, \(L10n.Channel.Item.Accessibility.groupChat), \(L10n.Channel.Item.Accessibility.memberCount(3))",
            L10n.Channel.Item.Accessibility.lastMessageWithStatus(
                L10n.Channel.Item.Accessibility.you,
                viewModel.timestampText,
                L10n.Channel.Item.Accessibility.sent,
                "Ping"
            )
        ].joined(separator: ". ")
        XCTAssertEqual(viewModel.accessibilityLabel, expected)
    }

    func test_accessibilityLabel_whenReadEventsEnabledAndHasReaders_includesSentAndReadStatus() {
        let messageDate = Date(timeIntervalSince1970: 100)
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Ping",
            author: .mock(id: Self.currentUserId, name: "Me"),
            createdAt: messageDate,
            isSentByCurrentUser: true
        )
        let channel = ChatChannel.mockNonDMChannel(
            lastMessageAt: Date(timeIntervalSince1970: 100_000),
            config: .mock(readEventsEnabled: true),
            memberCount: 3,
            reads: [
                .init(
                    lastReadAt: messageDate.addingTimeInterval(10),
                    lastReadMessageId: message.id,
                    unreadMessagesCount: 0,
                    user: .mock(id: "reader", name: "Reader"),
                    lastDeliveredAt: nil,
                    lastDeliveredMessageId: nil
                )
            ],
            latestMessages: [message]
        )
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "Team")

        XCTAssertTrue(
            viewModel.accessibilityLabel.contains(L10n.Channel.Item.Accessibility.sentAndRead)
        )
    }

    func test_accessibilityLabel_whenPreviewMessageDeleted_usesDeletedPlaceholder() {
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Secret",
            author: .mock(id: "yoda", name: "Yoda"),
            createdAt: Date(timeIntervalSince1970: 0),
            deletedAt: Date(timeIntervalSince1970: 100),
            isSentByCurrentUser: false
        )
        let channel = ChatChannel.mockNonDMChannel(memberCount: 3, latestMessages: [message])
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "Team")

        let expected = [
            "Team, \(L10n.Channel.Item.Accessibility.groupChat), \(L10n.Channel.Item.Accessibility.memberCount(3))",
            L10n.Message.deletedMessagePlaceholder
        ].joined(separator: ". ")
        XCTAssertEqual(viewModel.accessibilityLabel, expected)
    }

    func test_accessibilityLabel_whenDraftPresent_includesDraftAndLastMessageTime() {
        let draft = DraftMessage.mock(text: "Draft text")
        let channel = ChatChannel.mockNonDMChannel(
            lastMessageAt: Date(timeIntervalSince1970: 100_000),
            memberCount: 3,
            latestMessages: [],
            draftMessage: draft
        )
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "Team")

        let expected = [
            "Team, \(L10n.Channel.Item.Accessibility.groupChat), \(L10n.Channel.Item.Accessibility.memberCount(3))",
            L10n.Channel.Item.Accessibility.draft("Draft text"),
            L10n.Channel.Item.Accessibility.lastMessageTime(viewModel.timestampText)
        ].joined(separator: ". ")
        XCTAssertEqual(viewModel.accessibilityLabel, expected)
    }

    func test_accessibilityLabel_whenLastMessageFailedToSend_usesFailedToSendText() {
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Oops",
            author: .mock(id: Self.currentUserId, name: "Me"),
            localState: .sendingFailed,
            isSentByCurrentUser: true
        )
        let channel = ChatChannel.mockNonDMChannel(memberCount: 3, latestMessages: [message])
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "Team")

        let expected = [
            "Team, \(L10n.Channel.Item.Accessibility.groupChat), \(L10n.Channel.Item.Accessibility.memberCount(3))",
            L10n.Channel.Item.messageFailedToSend
        ].joined(separator: ". ")
        XCTAssertEqual(viewModel.accessibilityLabel, expected)
    }

    func test_accessibilityLabel_whenEmptyChannel_usesEmptyPlaceholder() {
        let channel = ChatChannel.mockNonDMChannel(memberCount: 3, latestMessages: [])
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "Team")

        XCTAssertTrue(viewModel.accessibilityLabel.hasSuffix(L10n.Channel.Item.emptyMessages))
    }
}
