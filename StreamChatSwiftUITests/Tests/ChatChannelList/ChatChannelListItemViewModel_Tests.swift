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

        guard case let .message(content) = viewModel.preview.kind else {
            return XCTFail("Expected .message, got \(viewModel.preview.kind)")
        }
        XCTAssertTrue(content.text.contains("Hello there"))
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

        guard case .failedToSend = viewModel.preview.kind else {
            return XCTFail("Expected .failedToSend, got \(viewModel.preview.kind)")
        }
    }

    func test_preview_whenTyping_returnsTypingWithChannel() {
        let typingUser = ChatUser.mock(id: "yoda", name: "Yoda")
        let channel = ChatChannel.mock(
            cid: .unique,
            config: .mock(typingEventsEnabled: true),
            currentlyTypingUsers: [typingUser]
        )
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "T")

        guard case let .typing(typingChannel) = viewModel.preview.kind else {
            return XCTFail("Expected .typing, got \(viewModel.preview.kind)")
        }
        XCTAssertEqual(typingChannel.cid, channel.cid)
    }

    func test_preview_whenDraftAvailableAndEnabled_returnsDraftWithText() {
        let draft = DraftMessage.mock(text: "Draft text")
        let channel = ChatChannel.mock(cid: .unique, draftMessage: draft)
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "T")

        guard case let .draft(text) = viewModel.preview.kind else {
            return XCTFail("Expected .draft, got \(viewModel.preview.kind)")
        }
        XCTAssertEqual(text, "Draft text")
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

        guard case let .deleted(isSentByCurrentUser) = viewModel.preview.kind else {
            return XCTFail("Expected .deleted, got \(viewModel.preview.kind)")
        }
        XCTAssertTrue(isSentByCurrentUser)
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

        guard case let .message(content) = viewModel.preview.kind else {
            return XCTFail("Expected .message, got \(viewModel.preview.kind)")
        }
        XCTAssertEqual(content.authorName, "Yoda")
        XCTAssertTrue(content.text.contains("Hello there"))
        XCTAssertNil(content.attachmentIcon)
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

        guard case let .message(content) = viewModel.preview.kind else {
            return XCTFail("Expected .message, got \(viewModel.preview.kind)")
        }
        XCTAssertNil(content.authorName)
        XCTAssertTrue(content.text.contains("Hi"))
    }

    func test_preview_whenNoPreviewMessage_returnsEmptyPlaceholderText() {
        let channel = ChatChannel.mock(cid: .unique, latestMessages: [])
        let viewModel = ChatChannelListItemViewModel(channel: channel, channelName: "T")

        guard case let .message(content) = viewModel.preview.kind else {
            return XCTFail("Expected .message, got \(viewModel.preview.kind)")
        }
        XCTAssertEqual(content.text, L10n.Channel.Item.emptyMessages)
        XCTAssertNil(content.authorName)
        XCTAssertNil(content.attachmentIcon)
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

        guard case .failedToSend = viewModel.preview.kind else {
            return XCTFail("Expected .failedToSend to win over typing, got \(viewModel.preview.kind)")
        }
    }
}
