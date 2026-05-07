//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import StreamSwiftTestHelpers
import XCTest

@MainActor final class ChatChannelListItemView_Tests: StreamChatTestCase {
    override func setUp() {
        super.setUp()

        streamChat?.utils.messageListConfig = .init(draftMessagesEnabled: true)
    }

    func test_channelListItem_audioMessage() throws {
        // Given
        let message = try mockAudioMessage(text: "Audio", isSentByCurrentUser: true)
        let channel = ChatChannel.mock(cid: .unique, latestMessages: [message])
        
        // When
        let view = ChatChannelListItem(
            channel: channel,
            channelName: "Test",
            onItemTap: { _ in }
        )
        .frame(width: defaultScreenSize.width)
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_channelListItem_imageMessage() throws {
        // Given
        let message = try mockImageMessage(text: "Image", isSentByCurrentUser: true)
        let channel = ChatChannel.mock(cid: .unique, latestMessages: [message])
        
        // When
        let view = ChatChannelListItem(
            channel: channel,
            channelName: "Test",
            onItemTap: { _ in }
        )
        .frame(width: defaultScreenSize.width)
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_channelListItem_videoMessage() throws {
        // Given
        let message = try mockVideoMessage(text: "Video", isSentByCurrentUser: true)
        let channel = ChatChannel.mock(cid: .unique, latestMessages: [message])
        
        // When
        let view = ChatChannelListItem(
            channel: channel,
            channelName: "Test",
            onItemTap: { _ in }
        )
        .frame(width: defaultScreenSize.width)
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_channelListItem_fileMessage() throws {
        // Given
        let message = try mockFileMessage(title: "Filename", text: "File", isSentByCurrentUser: true)
        let channel = ChatChannel.mock(cid: .unique, latestMessages: [message])
        
        // When
        let view = ChatChannelListItem(
            channel: channel,
            channelName: "Test",
            onItemTap: { _ in }
        )
        .frame(width: defaultScreenSize.width)
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_channelListItem_muted_defaultStyle() throws {
        // Given
        let message = try mockPollMessage(isSentByCurrentUser: false)
        let channel = ChatChannel.mock(
            cid: .unique,
            latestMessages: [message],
            muteDetails: .init(createdAt: .unique, updatedAt: .unique, expiresAt: nil)
        )

        // When
        let view = ChatChannelListItem(
            channel: channel,
            channelName: "Test",
            onItemTap: { _ in }
        )
        .frame(width: defaultScreenSize.width)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_channelListItem_muted_channelNameStyle() throws {
        // Given
        streamChat?.utils.channelListConfig.channelItemMutedStyle = .afterChannelName
        let message = try mockPollMessage(isSentByCurrentUser: false)
        let channel = ChatChannel.mock(
            cid: .unique,
            unreadCount: .mock(messages: 4),
            latestMessages: [message],
            muteDetails: .init(createdAt: .unique, updatedAt: .unique, expiresAt: nil)
        )

        // When
        let view = ChatChannelListItem(
            channel: channel,
            channelName: "Test",
            onItemTap: { _ in }
        )
        .frame(width: defaultScreenSize.width)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_channelListItem_muted_bottomRightCornerStyle() throws {
        // Given
        streamChat?.utils.channelListConfig.channelItemMutedStyle = .bottomRightCorner
        let message = try mockPollMessage(isSentByCurrentUser: false)
        let channel = ChatChannel.mock(
            cid: .unique,
            unreadCount: .mock(messages: 4),
            latestMessages: [message],
            muteDetails: .init(createdAt: .unique, updatedAt: .unique, expiresAt: nil)
        )

        // When
        let view = ChatChannelListItem(
            channel: channel,
            channelName: "Test",
            onItemTap: { _ in }
        )
        .frame(width: defaultScreenSize.width)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_channelListItem_giphyMessage() throws {
        // Given
        let message = try mockGiphyMessage(text: "", isSentByCurrentUser: true)
        let channel = ChatChannel.mock(cid: .unique, latestMessages: [message])
        
        // When
        let view = ChatChannelListItem(
            channel: channel,
            channelName: "Test",
            onItemTap: { _ in }
        )
        .frame(width: defaultScreenSize.width)
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_channelListItem_giphyMessage_groupChannel() throws {
        // Given
        let message = try mockGiphyMessage(text: "", isSentByCurrentUser: false)
        let channel = ChatChannel.mockNonDMChannel(
            name: "Group Chat",
            latestMessages: [message]
        )
        
        // When
        let view = ChatChannelListItem(
            channel: channel,
            channelName: "Group Chat",
            onItemTap: { _ in }
        )
        .frame(width: defaultScreenSize.width)
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_channelListItem_ephemeralMessageSkipped_showsPreviousMessage() throws {
        // Given
        let regularMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hello there",
            type: .regular,
            author: .mock(id: "user", name: "User"),
            createdAt: Date(timeIntervalSince1970: 100),
            isSentByCurrentUser: false
        )
        let ephemeralMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "/giphy cats",
            type: .ephemeral,
            author: .mock(id: Self.currentUserId, name: "Me"),
            createdAt: Date(timeIntervalSince1970: 200),
            isSentByCurrentUser: true
        )
        let channel = ChatChannel.mockDMChannel(
            memberCount: 2,
            latestMessages: [ephemeralMessage, regularMessage]
        )

        // When
        let view = ChatChannelListItem(
            channel: channel,
            channelName: "User",
            onItemTap: { _ in }
        )
        .frame(width: defaultScreenSize.width)

        // Then
        AssertSnapshot(view)
    }

    func test_channelListItem_pollMessage_youCreated() throws {
        // Given
        let message = try mockPollMessage(isSentByCurrentUser: true)
        let channel = ChatChannel.mock(cid: .unique, latestMessages: [message])
        
        // When
        let view = ChatChannelListItem(
            channel: channel,
            channelName: "Test",
            onItemTap: { _ in }
        )
        .frame(width: defaultScreenSize.width)
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_channelListItem_pollMessage_someoneCreated() throws {
        // Given
        let message = try mockPollMessage(isSentByCurrentUser: false)
        let channel = ChatChannel.mock(cid: .unique, latestMessages: [message])
        
        // When
        let view = ChatChannelListItem(
            channel: channel,
            channelName: "Test",
            onItemTap: { _ in }
        )
        .frame(width: defaultScreenSize.width)
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_channelListItem_pollMessage_youVoted() throws {
        // Given
        let currentUserId = Self.currentUserId
        let message = try mockPollMessage(isSentByCurrentUser: false, latestVotes: [
            .mock(pollId: .unique, optionId: .unique, user: .mock(id: currentUserId), updatedAt: nil),
            .unique,
            .unique
        ])
        let channel = ChatChannel.mock(cid: .unique, membership: .mock(id: currentUserId), latestMessages: [message])

        // When
        let view = ChatChannelListItem(
            channel: channel,
            channelName: "Test",
            onItemTap: { _ in }
        )
        .frame(width: defaultScreenSize.width)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_channelListItem_pollMessage_someoneVoted() throws {
        // Given
        let currentUserId = Self.currentUserId
        let message = try mockPollMessage(isSentByCurrentUser: false, latestVotes: [
            .mock(pollId: .unique, optionId: .unique, user: .mock(id: .unique, name: "Steve Jobs"), updatedAt: nil),
            .unique,
            .mock(pollId: .unique, optionId: .unique, user: .mock(id: currentUserId), updatedAt: nil)
        ])
        let channel = ChatChannel.mock(cid: .unique, membership: .mock(id: currentUserId), latestMessages: [message])

        // When
        let view = ChatChannelListItem(
            channel: channel,
            channelName: "Test",
            onItemTap: { _ in }
        )
        .frame(width: defaultScreenSize.width)
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_channelListItem_translatedText_participant() throws {
        // Given
        let message = try mockTranslatedMessage(
            text: "Hello",
            translations: [.spanish: "Hola"],
            isSentByCurrentUser: false
        )
        let channel = ChatChannel.mock(
            cid: .unique,
            membership: .mock(id: .unique, language: .spanish),
            latestMessages: [message]
        )
        
        // When
        let view = ChatChannelListItem(
            channel: channel,
            channelName: "Test",
            onItemTap: { _ in }
        )
        .frame(width: defaultScreenSize.width)
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_channelListItem_translatedText_me() throws {
        // Given
        let message = try mockTranslatedMessage(
            text: "Hello",
            translations: [.spanish: "Hola"],
            isSentByCurrentUser: true
        )
        let channel = ChatChannel.mock(
            cid: .unique,
            membership: .mock(id: .unique, language: .spanish),
            latestMessages: [message]
        )
        
        // When
        let view = ChatChannelListItem(
            channel: channel,
            channelName: "Test",
            onItemTap: { _ in }
        )
        .frame(width: defaultScreenSize.width)
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_channelListItem_draftMessage() throws {
        // Given
        let message = DraftMessage.mock(text: "Draft message")
        let channel = ChatChannel.mock(cid: .unique, latestMessages: [.mock()], draftMessage: message)

        // When
        let view = ChatChannelListItem(
            channel: channel,
            channelName: "Test",
            onItemTap: { _ in }
        )
        .frame(width: defaultScreenSize.width)
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_channelListItem_draftMessageWithAttachment() throws {
        // Given
        let message = try DraftMessage.mock(text: "Draft message", attachments: [.dummy(payload: JSONEncoder().encode(
            ImageAttachmentPayload(
                title: "Test",
                imageRemoteURL: .localYodaImage,
                file: .init(url: .localYodaQuote)
            )
        ))])
        let channel = ChatChannel.mock(cid: .unique, latestMessages: [.mock()], draftMessage: message)

        // When
        let view = ChatChannelListItem(
            channel: channel,
            channelName: "Test",
            onItemTap: { _ in }
        )
        .frame(width: defaultScreenSize.width)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_channelListItem_messageDelivered() throws {
        let date = Date(timeIntervalSince1970: 100)

        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Test message",
            author: .mock(id: .unique, name: "Darth Vader"),
            createdAt: date.addingTimeInterval(-100),
            isSentByCurrentUser: true
        )
        let channel = ChatChannel.mock(
            cid: .unique,
            config: .mock(readEventsEnabled: true),
            reads: [
                .init(
                    lastReadAt: .distantPast,
                    lastReadMessageId: nil,
                    unreadMessagesCount: 0,
                    user: .unique,
                    lastDeliveredAt: date,
                    lastDeliveredMessageId: message.id
                )
            ],
            latestMessages: [message]
        )
        
        // When
        let view = ChatChannelListItem(
            channel: channel,
            channelName: "Test",
            onItemTap: { _ in }
        )
        .frame(width: defaultScreenSize.width)
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_channelListItem_messageDeliveredAndRead() throws {
        let date = Date(timeIntervalSince1970: 100)

        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Test message",
            author: .mock(id: .unique, name: "Darth Vader"),
            createdAt: date.addingTimeInterval(-100),
            isSentByCurrentUser: true
        )
        let channel = ChatChannel.mock(
            cid: .unique,
            config: .mock(readEventsEnabled: true),
            reads: [
                .init(
                    lastReadAt: date.addingTimeInterval(10),
                    lastReadMessageId: message.id,
                    unreadMessagesCount: 0,
                    user: .unique,
                    lastDeliveredAt: date,
                    lastDeliveredMessageId: message.id
                )
            ],
            latestMessages: [message]
        )

        // When
        let view = ChatChannelListItem(
            channel: channel,
            channelName: "Test",
            onItemTap: { _ in }
        )
        .frame(width: defaultScreenSize.width)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_channelListItem_messageFailedToSend() throws {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hello there",
            author: .mock(id: Self.currentUserId, name: "You"),
            createdAt: Date(timeIntervalSince1970: 100),
            localState: .sendingFailed,
            isSentByCurrentUser: true
        )
        let channel = ChatChannel.mock(
            cid: .unique,
            latestMessages: [message]
        )

        // When
        let view = ChatChannelListItem(
            channel: channel,
            channelName: "Test",
            onItemTap: { _ in }
        )
        .frame(width: defaultScreenSize.width)

        // Then
        AssertSnapshot(view)
    }

    func test_channelListItem_messagePending() throws {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hey, how are you?",
            author: .mock(id: Self.currentUserId, name: "You"),
            createdAt: Date(timeIntervalSince1970: 100),
            localState: .pendingSend,
            isSentByCurrentUser: true
        )
        let channel = ChatChannel.mock(
            cid: .unique,
            config: .mock(readEventsEnabled: true),
            latestMessages: [message]
        )

        // When
        let view = ChatChannelListItem(
            channel: channel,
            channelName: "Test",
            onItemTap: { _ in }
        )
        .frame(width: defaultScreenSize.width)

        // Then
        AssertSnapshot(view)
    }

    func test_channelListItem_emptyMessages() throws {
        // Given
        let channel = ChatChannel.mock(cid: .unique)

        // When
        let view = ChatChannelListItem(
            channel: channel,
            channelName: "Test",
            onItemTap: { _ in }
        )
        .frame(width: defaultScreenSize.width)

        // Then
        AssertSnapshot(view)
    }

    func test_channelListItem_voiceRecordingMessage() throws {
        // Given
        let message = try mockVoiceRecordingMessage(text: "", isSentByCurrentUser: true)
        let channel = ChatChannel.mock(cid: .unique, latestMessages: [message])

        // When
        let view = ChatChannelListItem(
            channel: channel,
            channelName: "Test",
            onItemTap: { _ in }
        )
        .frame(width: defaultScreenSize.width)

        // Then
        AssertSnapshot(view)
    }

    func test_channelListItem_groupChannel_authorNamePrefix() throws {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hey everyone!",
            type: .regular,
            author: .mock(id: "other-user", name: "John"),
            createdAt: Date(timeIntervalSince1970: 100),
            localState: nil,
            isSentByCurrentUser: false
        )
        let channel = ChatChannel.mockNonDMChannel(
            name: "Group Chat",
            latestMessages: [message]
        )

        // When
        let view = ChatChannelListItem(
            channel: channel,
            channelName: "Group Chat",
            onItemTap: { _ in }
        )
        .frame(width: defaultScreenSize.width)

        // Then
        AssertSnapshot(view)
    }

    func test_channelListItem_groupChannel_youPrefix() throws {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hey everyone!",
            type: .regular,
            author: .mock(id: Self.currentUserId, name: "Me"),
            createdAt: Date(timeIntervalSince1970: 100),
            localState: nil,
            isSentByCurrentUser: true
        )
        let channel = ChatChannel.mockNonDMChannel(
            name: "Group Chat",
            latestMessages: [message]
        )

        // When
        let view = ChatChannelListItem(
            channel: channel,
            channelName: "Group Chat",
            onItemTap: { _ in }
        )
        .frame(width: defaultScreenSize.width)

        // Then
        AssertSnapshot(view)
    }

    func test_channelListItem_dmChannel_noAuthorPrefix() throws {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hello!",
            type: .regular,
            author: .mock(id: "other-user", name: "John"),
            createdAt: Date(timeIntervalSince1970: 100),
            localState: nil,
            isSentByCurrentUser: false
        )
        let channel = ChatChannel.mockDMChannel(
            memberCount: 2,
            latestMessages: [message]
        )

        // When
        let view = ChatChannelListItem(
            channel: channel,
            channelName: "John",
            onItemTap: { _ in }
        )
        .frame(width: defaultScreenSize.width)

        // Then
        AssertSnapshot(view)
    }

    func test_channelListItem_groupChannel_imageAttachmentPreview() throws {
        // Given
        let message = try mockImageMessage(text: "Check this out", isSentByCurrentUser: false)
        let channel = ChatChannel.mockNonDMChannel(
            name: "Group Chat",
            latestMessages: [message]
        )

        // When
        let view = ChatChannelListItem(
            channel: channel,
            channelName: "Group Chat",
            onItemTap: { _ in }
        )
        .frame(width: defaultScreenSize.width)

        // Then
        AssertSnapshot(view)
    }

    func test_channelListItem_deletedMessage_dmChannel() throws {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "This was the original message",
            author: .mock(id: "other-user", name: "John"),
            createdAt: Date(timeIntervalSince1970: 100),
            deletedAt: Date(timeIntervalSince1970: 200),
            isSentByCurrentUser: false
        )
        let channel = ChatChannel.mockDMChannel(
            memberCount: 2,
            latestMessages: [message]
        )

        // When
        let view = ChatChannelListItem(
            channel: channel,
            channelName: "John",
            onItemTap: { _ in }
        )
        .frame(width: defaultScreenSize.width)

        // Then
        AssertSnapshot(view)
    }

    func test_channelListItem_deletedMessage_groupChannel() throws {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "This was the original message",
            author: .mock(id: "other-user", name: "John"),
            createdAt: Date(timeIntervalSince1970: 100),
            deletedAt: Date(timeIntervalSince1970: 200),
            isSentByCurrentUser: false
        )
        let channel = ChatChannel.mockNonDMChannel(
            name: "Group Chat",
            latestMessages: [message]
        )

        // When
        let view = ChatChannelListItem(
            channel: channel,
            channelName: "Group Chat",
            onItemTap: { _ in }
        )
        .frame(width: defaultScreenSize.width)

        // Then
        AssertSnapshot(view)
    }

    func test_channelListItem_deletedMessage_sentByCurrentUser() throws {
        // Given
        let date = Date(timeIntervalSince1970: 100)
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Deleted message",
            author: .mock(id: Self.currentUserId, name: "Me"),
            createdAt: date.addingTimeInterval(-100),
            deletedAt: date,
            isSentByCurrentUser: true
        )
        let channel = ChatChannel.mock(
            cid: .unique,
            config: .mock(readEventsEnabled: true),
            reads: [
                .init(
                    lastReadAt: date.addingTimeInterval(10),
                    lastReadMessageId: message.id,
                    unreadMessagesCount: 0,
                    user: .unique,
                    lastDeliveredAt: date,
                    lastDeliveredMessageId: message.id
                )
            ],
            latestMessages: [message]
        )

        // When
        let view = ChatChannelListItem(
            channel: channel,
            channelName: "Test",
            onItemTap: { _ in }
        )
        .frame(width: defaultScreenSize.width)

        // Then
        AssertSnapshot(view)
    }

    // MARK: - private

    private func mockVoiceRecordingMessage(text: String, isSentByCurrentUser: Bool) throws -> ChatMessage {
        try .mock(
            id: .unique,
            cid: .unique,
            text: text,
            type: .regular,
            author: .mock(id: "user", name: "User"),
            createdAt: Date(timeIntervalSince1970: 100),
            attachments: [
                .dummy(
                    type: .voiceRecording,
                    payload: JSONEncoder().encode(VoiceRecordingAttachmentPayload(
                        title: "Recording",
                        voiceRecordingRemoteURL: URL(string: "url")!,
                        file: .init(type: .aac, size: 123, mimeType: nil),
                        duration: 12,
                        waveformData: [0, 0.1, 0.5, 1],
                        extraData: nil
                    ))
                )
            ],
            localState: nil,
            isSentByCurrentUser: isSentByCurrentUser
        )
    }

    private func mockAudioMessage(text: String, isSentByCurrentUser: Bool) throws -> ChatMessage {
        try .mock(
            id: .unique,
            cid: .unique,
            text: text,
            type: .regular,
            author: .mock(id: "user", name: "User"),
            createdAt: Date(timeIntervalSince1970: 100),
            attachments: [
                .dummy(
                    type: .audio,
                    payload: JSONEncoder().encode(AudioAttachmentPayload(
                        title: "Some Audio",
                        audioRemoteURL: URL(string: "url")!,
                        file: .init(type: .mp3, size: 123, mimeType: nil),
                        extraData: nil
                    ))
                )
            ],
            localState: nil,
            isSentByCurrentUser: isSentByCurrentUser
        )
    }
    
    private func mockImageMessage(text: String, isSentByCurrentUser: Bool) throws -> ChatMessage {
        try .mock(
            id: .unique,
            cid: .unique,
            text: text,
            type: .regular,
            author: .mock(id: "user", name: "User"),
            createdAt: Date(timeIntervalSince1970: 100),
            attachments: [
                .dummy(
                    type: .image,
                    payload: JSONEncoder().encode(ImageAttachmentPayload(
                        title: "Test",
                        imageRemoteURL: URL(string: "Url")!,
                        file: AttachmentFile(type: .png, size: 123, mimeType: nil)
                    ))
                )
            ],
            localState: nil,
            isSentByCurrentUser: isSentByCurrentUser
        )
    }

    private func mockVideoMessage(text: String, isSentByCurrentUser: Bool) throws -> ChatMessage {
        try .mock(
            id: .unique,
            cid: .unique,
            text: text,
            type: .regular,
            author: .mock(id: "user", name: "User"),
            createdAt: Date(timeIntervalSince1970: 100),
            attachments: [
                .dummy(
                    type: .video,
                    payload: JSONEncoder().encode(VideoAttachmentPayload(
                        title: "Test",
                        videoRemoteURL: URL(string: "Url")!,
                        file: .init(type: .mp4, size: 123, mimeType: nil),
                        extraData: nil
                    ))
                )
            ],
            localState: nil,
            isSentByCurrentUser: isSentByCurrentUser
        )
    }
    
    private func mockFileMessage(title: String?, text: String, isSentByCurrentUser: Bool) throws -> ChatMessage {
        try .mock(
            id: .unique,
            cid: .unique,
            text: text,
            type: .regular,
            author: .mock(id: "user", name: "User"),
            createdAt: Date(timeIntervalSince1970: 100),
            attachments: [
                .dummy(
                    type: .file,
                    payload: JSONEncoder().encode(FileAttachmentPayload(
                        title: title,
                        assetRemoteURL: URL(string: "Url")!,
                        file: .init(type: .pdf, size: 123, mimeType: nil),
                        extraData: nil
                    ))
                )
            ],
            localState: nil,
            isSentByCurrentUser: isSentByCurrentUser
        )
    }
    
    private func mockGiphyMessage(text: String, isSentByCurrentUser: Bool) throws -> ChatMessage {
        try .mock(
            id: .unique,
            cid: .unique,
            text: text,
            type: .regular,
            author: .mock(id: "user", name: "User"),
            createdAt: Date(timeIntervalSince1970: 100),
            attachments: [
                .dummy(
                    type: .giphy,
                    payload: JSONEncoder().encode(GiphyAttachmentPayload(
                        title: "Test",
                        previewURL: URL(string: "Url")!
                    ))
                )
            ],
            localState: nil,
            isSentByCurrentUser: isSentByCurrentUser
        )
    }
    
    private func mockPollMessage(isSentByCurrentUser: Bool, latestVotes: [PollVote] = []) throws -> ChatMessage {
        .mock(
            id: .unique,
            cid: .unique,
            text: "",
            type: .regular,
            author: .mock(id: "user", name: "User"),
            createdAt: Date(timeIntervalSince1970: 100),
            localState: nil,
            isSentByCurrentUser: isSentByCurrentUser,
            poll: .mock(
                name: "Test poll",
                createdBy: .mock(id: isSentByCurrentUser ? Self.currentUserId : "test", name: "test"),
                latestVotes: latestVotes
            )
        )
    }
    
    private func mockTranslatedMessage(
        text: String,
        translations: [TranslationLanguage: String]?,
        isSentByCurrentUser: Bool
    ) throws -> ChatMessage {
        .mock(
            id: .unique,
            cid: .unique,
            text: text,
            type: .regular,
            author: .mock(id: "user", name: "User"),
            createdAt: Date(timeIntervalSince1970: 100),
            translations: translations,
            localState: nil,
            isSentByCurrentUser: isSentByCurrentUser
        )
    }
}
