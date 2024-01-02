//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class MessageTypeResolver_Tests: XCTestCase {

    private let standardMessage = ChatMessage.mock(
        id: .unique,
        cid: .unique,
        text: "Standard",
        author: .mock(id: .unique)
    )

    func test_messageTypeResolver_standardMessage() {
        // Given
        let message = standardMessage
        let messageTypeResolver = MessageTypeResolver()

        // When
        let isDeleted = messageTypeResolver.isDeleted(message: message)
        let hasImageAttachments = messageTypeResolver.hasImageAttachment(message: message)
        let hasGiphyAttachment = messageTypeResolver.hasGiphyAttachment(message: message)
        let hasVideoAttachment = messageTypeResolver.hasVideoAttachment(message: message)
        let hasLinkAttachment = messageTypeResolver.hasLinkAttachment(message: message)
        let hasFileAttachment = messageTypeResolver.hasFileAttachment(message: message)
        let hasCustomAttachment = messageTypeResolver.hasCustomAttachment(message: message)

        // Then
        XCTAssert(isDeleted == false)
        XCTAssert(hasImageAttachments == false)
        XCTAssert(hasGiphyAttachment == false)
        XCTAssert(hasVideoAttachment == false)
        XCTAssert(hasLinkAttachment == false)
        XCTAssert(hasFileAttachment == false)
        XCTAssert(hasCustomAttachment == false)
    }

    func test_messageTypeResolver_isDeleted() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Deleted",
            author: .mock(id: .unique),
            deletedAt: Date()
        )
        let messageTypeResolver = MessageTypeResolver()

        // When
        let isDeleted = messageTypeResolver.isDeleted(message: message)

        // Then
        XCTAssert(isDeleted == true)
    }

    func test_messageTypeResolver_hasImageAttachment() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Image attachment",
            author: .mock(id: .unique),
            attachments: ChatChannelTestHelpers.imageAttachments
        )
        let messageTypeResolver = MessageTypeResolver()

        // When
        let hasImageAttachments = messageTypeResolver.hasImageAttachment(message: message)

        // Then
        XCTAssert(hasImageAttachments == true)
    }

    func test_messageTypeResolver_hasGiphyAttachment() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Giphy attachment",
            author: .mock(id: .unique),
            attachments: ChatChannelTestHelpers.giphyAttachments
        )
        let messageTypeResolver = MessageTypeResolver()

        // When
        let hasGiphyAttachments = messageTypeResolver.hasGiphyAttachment(message: message)

        // Then
        XCTAssert(hasGiphyAttachments == true)
    }

    func test_messageTypeResolver_hasVideoAttachment() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Video attachment",
            author: .mock(id: .unique),
            attachments: ChatChannelTestHelpers.videoAttachments
        )
        let messageTypeResolver = MessageTypeResolver()

        // When
        let hasVideoAttachments = messageTypeResolver.hasVideoAttachment(message: message)

        // Then
        XCTAssert(hasVideoAttachments == true)
    }

    func test_messageTypeResolver_hasLinkAttachment() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Link attachment",
            author: .mock(id: .unique),
            attachments: ChatChannelTestHelpers.linkAttachments
        )
        let messageTypeResolver = MessageTypeResolver()

        // When
        let hasLinkAttachments = messageTypeResolver.hasLinkAttachment(message: message)

        // Then
        XCTAssert(hasLinkAttachments == true)
    }

    func test_messageTypeResolver_hasFileAttachment() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "File attachment",
            author: .mock(id: .unique),
            attachments: ChatChannelTestHelpers.fileAttachments
        )
        let messageTypeResolver = MessageTypeResolver()

        // When
        let hasFileAttachments = messageTypeResolver.hasFileAttachment(message: message)

        // Then
        XCTAssert(hasFileAttachments == true)
    }
    
    func test_messageTypeResolver_hasVoiceRecordingAttachment() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Voice attachment",
            author: .mock(id: .unique),
            attachments: ChatChannelTestHelpers.voiceRecordingAttachments
        )
        let messageTypeResolver = MessageTypeResolver()

        // When
        let hasVoiceRecording = messageTypeResolver.hasVoiceRecording(message: message)

        // Then
        XCTAssert(hasVoiceRecording == true)
    }
}
