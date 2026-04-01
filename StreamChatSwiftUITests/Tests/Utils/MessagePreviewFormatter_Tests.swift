//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import XCTest

@MainActor final class MessagePreviewFormatter_Tests: StreamChatTestCase {
    private lazy var formatter = MessagePreviewFormatter()

    // MARK: - format(_:in:)

    func test_format_dmChannel_noAuthorPrefix() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hello!",
            author: .mock(id: "other-user", name: "John"),
            isSentByCurrentUser: false
        )
        let channel = ChatChannel.mockDMChannel(
            memberCount: 2,
            latestMessages: [message]
        )

        // When
        let result = formatter.format(message, in: channel)

        // Then
        XCTAssertEqual(result, "Hello!")
    }

    func test_format_groupChannel_currentUser_youPrefix() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hey everyone!",
            author: .mock(id: Self.currentUserId, name: "Me"),
            isSentByCurrentUser: true
        )
        let channel = ChatChannel.mockNonDMChannel(
            latestMessages: [message]
        )

        // When
        let result = formatter.format(message, in: channel)

        // Then
        XCTAssertEqual(result, "You: Hey everyone!")
    }

    func test_format_groupChannel_otherUser_authorNamePrefix() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hello there",
            author: .mock(id: "other-user", name: "John"),
            isSentByCurrentUser: false
        )
        let channel = ChatChannel.mockNonDMChannel(
            latestMessages: [message]
        )

        // When
        let result = formatter.format(message, in: channel)

        // Then
        XCTAssertEqual(result, "John: Hello there")
    }

    func test_format_groupChannel_otherUser_noName_usesId() {
        // Given
        let userId = "other-user-id"
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hello",
            author: .mock(id: userId, name: nil),
            isSentByCurrentUser: false
        )
        let channel = ChatChannel.mockNonDMChannel(
            latestMessages: [message]
        )

        // When
        let result = formatter.format(message, in: channel)

        // Then
        XCTAssertEqual(result, "\(userId): Hello")
    }

    // MARK: - Deleted Messages

    func test_format_deletedMessage_noAuthorPrefix() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "This was the original message",
            author: .mock(id: "other-user", name: "John"),
            deletedAt: Date(),
            isSentByCurrentUser: false
        )
        let channel = ChatChannel.mockNonDMChannel(
            latestMessages: [message]
        )

        // When
        let result = formatter.format(message, in: channel)

        // Then
        XCTAssertEqual(result, L10n.Message.deletedMessagePlaceholder)
    }

    func test_format_deletedMessage_dmChannel() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "This was the original message",
            author: .mock(id: "other-user", name: "John"),
            deletedAt: Date(),
            isSentByCurrentUser: false
        )
        let channel = ChatChannel.mockDMChannel(
            memberCount: 2,
            latestMessages: [message]
        )

        // When
        let result = formatter.format(message, in: channel)

        // Then
        XCTAssertEqual(result, L10n.Message.deletedMessagePlaceholder)
    }

    func test_formatContent_deletedMessage_returnsPlaceholder() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Original text",
            author: .mock(id: "other-user", name: "John"),
            deletedAt: Date(),
            isSentByCurrentUser: false
        )
        let channel = ChatChannel.mock(cid: .unique)

        // When
        let result = formatter.formatContent(for: message, in: channel)

        // Then
        XCTAssertEqual(result, L10n.Message.deletedMessagePlaceholder)
    }

    func test_formatAttachmentContent_deletedMessage_returnsNil() throws {
        // Given
        let message = try ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: .mock(id: "other-user"),
            deletedAt: Date(),
            attachments: [
                .dummy(
                    type: .image,
                    payload: JSONEncoder().encode(ImageAttachmentPayload(
                        title: "Test",
                        imageRemoteURL: URL(string: "https://example.com/image.png")!,
                        file: .init(type: .png, size: 123, mimeType: nil)
                    ))
                )
            ],
            isSentByCurrentUser: false
        )
        let channel = ChatChannel.mock(cid: .unique)

        // When
        let result = formatter.formatAttachmentContent(for: message, in: channel)

        // Then
        XCTAssertNil(result)
    }

    // MARK: - formatAttachmentContent(for:in:)

    func test_formatAttachmentContent_poll_noEmoji() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            poll: .mock(name: "Best programming language?")
        )
        let channel = ChatChannel.mock(cid: .unique)

        // When
        let result = formatter.formatAttachmentContent(for: message, in: channel)

        // Then
        XCTAssertEqual(result, "Best programming language?")
    }

    func test_formatAttachmentContent_audio_withText() throws {
        // Given
        let message = try ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "My audio",
            attachments: [
                .dummy(
                    type: .audio,
                    payload: JSONEncoder().encode(AudioAttachmentPayload(
                        title: "Audio",
                        audioRemoteURL: URL(string: "https://example.com/audio.mp3")!,
                        file: .init(type: .mp3, size: 123, mimeType: nil),
                        extraData: nil
                    ))
                )
            ]
        )
        let channel = ChatChannel.mock(cid: .unique)

        // When
        let result = formatter.formatAttachmentContent(for: message, in: channel)

        // Then
        XCTAssertEqual(result, "My audio")
    }

    func test_formatAttachmentContent_audio_emptyText() throws {
        // Given
        let message = try ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            attachments: [
                .dummy(
                    type: .audio,
                    payload: JSONEncoder().encode(AudioAttachmentPayload(
                        title: "Audio",
                        audioRemoteURL: URL(string: "https://example.com/audio.mp3")!,
                        file: .init(type: .mp3, size: 123, mimeType: nil),
                        extraData: nil
                    ))
                )
            ]
        )
        let channel = ChatChannel.mock(cid: .unique)

        // When
        let result = formatter.formatAttachmentContent(for: message, in: channel)

        // Then
        XCTAssertEqual(result, L10n.Channel.Item.audio)
    }

    func test_formatAttachmentContent_image_noEmoji() throws {
        // Given
        let message = try ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            attachments: [
                .dummy(
                    type: .image,
                    payload: JSONEncoder().encode(ImageAttachmentPayload(
                        title: "Test",
                        imageRemoteURL: URL(string: "https://example.com/image.png")!,
                        file: .init(type: .png, size: 123, mimeType: nil)
                    ))
                )
            ]
        )
        let channel = ChatChannel.mock(cid: .unique)

        // When
        let result = formatter.formatAttachmentContent(for: message, in: channel)

        // Then
        XCTAssertEqual(result, L10n.Channel.Item.photo)
    }

    func test_formatAttachmentContent_video_noEmoji() throws {
        // Given
        let message = try ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            attachments: [
                .dummy(
                    type: .video,
                    payload: JSONEncoder().encode(VideoAttachmentPayload(
                        title: "Test",
                        videoRemoteURL: URL(string: "https://example.com/video.mp4")!,
                        file: .init(type: .mp4, size: 123, mimeType: nil),
                        extraData: nil
                    ))
                )
            ]
        )
        let channel = ChatChannel.mock(cid: .unique)

        // When
        let result = formatter.formatAttachmentContent(for: message, in: channel)

        // Then
        XCTAssertEqual(result, L10n.Channel.Item.video)
    }

    func test_formatAttachmentContent_voiceRecording_noEmoji() throws {
        // Given
        let message = try ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            attachments: [
                .dummy(
                    type: .voiceRecording,
                    payload: JSONEncoder().encode(VoiceRecordingAttachmentPayload(
                        title: "Recording",
                        voiceRecordingRemoteURL: URL(string: "https://example.com/voice.m4a")!,
                        file: .init(type: .aac, size: 123, mimeType: nil),
                        duration: 12,
                        waveformData: nil,
                        extraData: nil
                    ))
                )
            ]
        )
        let channel = ChatChannel.mock(cid: .unique)

        // When
        let result = formatter.formatAttachmentContent(for: message, in: channel)

        // Then
        XCTAssertEqual(result, L10n.Channel.Item.voiceMessage)
    }

    func test_formatAttachmentContent_file_usesTitle() throws {
        // Given
        let message = try ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Some text",
            attachments: [
                .dummy(
                    type: .file,
                    payload: JSONEncoder().encode(FileAttachmentPayload(
                        title: "Report.pdf",
                        assetRemoteURL: URL(string: "https://example.com/report.pdf")!,
                        file: .init(type: .pdf, size: 123, mimeType: nil),
                        extraData: nil
                    ))
                )
            ]
        )
        let channel = ChatChannel.mock(cid: .unique)

        // When
        let result = formatter.formatAttachmentContent(for: message, in: channel)

        // Then
        XCTAssertEqual(result, "Report.pdf")
    }

    func test_formatAttachmentContent_linkPreview() throws {
        // Given
        let url = URL(string: "https://example.com/article")!
        let message = try ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Check this out",
            attachments: [
                .dummy(
                    type: .linkPreview,
                    payload: JSONEncoder().encode(LinkAttachmentPayload(
                        originalURL: url,
                        title: "Example Article",
                        text: "An article",
                        author: nil,
                        titleLink: nil,
                        assetURL: url,
                        previewURL: url
                    ))
                )
            ]
        )
        let channel = ChatChannel.mock(cid: .unique)

        // When
        let result = formatter.formatAttachmentContent(for: message, in: channel)

        // Then
        XCTAssertEqual(result, "https://example.com/article")
    }

    // MARK: - formatPoll (via format)

    func test_format_poll_noEmoji() {
        // Given
        let currentUserId = Self.currentUserId
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            isSentByCurrentUser: true,
            poll: .mock(
                name: "Favorite color?",
                createdBy: .mock(id: currentUserId, name: "Me"),
                latestVotes: []
            )
        )
        let channel = ChatChannel.mock(cid: .unique)

        // When
        let result = formatter.format(message, in: channel)

        // Then
        XCTAssertFalse(result.contains("📊"))
        XCTAssertTrue(result.contains("Favorite color?"))
    }
}
