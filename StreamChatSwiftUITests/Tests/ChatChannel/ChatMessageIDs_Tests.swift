//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class ChatMessageIDs_Tests: StreamChatTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        StreamRuntimeCheck._isDatabaseObserverItemReusingEnabled = false
    }
    
    override func tearDownWithError() throws {
        StreamRuntimeCheck._isDatabaseObserverItemReusingEnabled = true
        try super.tearDownWithError()
    }
    
    func test_chatMessage_reactionScoresId() {
        // Given
        let id: String = .unique
        let reaction = "like"
        let expectedId = id + "$empty" + "\(reaction)\(3)"
        let message = ChatMessage.mock(
            id: id,
            cid: .unique,
            text: "test",
            author: .mock(id: .unique),
            reactionScores: [
                MessageReactionType(rawValue: reaction): 3
            ]
        )

        // When
        let messageId = message.messageId

        // Then
        XCTAssert(messageId.starts(with: expectedId))
    }

    func test_chatMessage_DeletedId() {
        // Given
        let id: String = .unique
        let expectedId = "\(id)$deleted"
        let message = ChatMessage.mock(
            id: id,
            cid: .unique,
            text: "test",
            author: .mock(id: .unique),
            deletedAt: Date()
        )

        // When
        let messageId = message.messageId

        // Then
        XCTAssert(messageId.starts(with: expectedId))
    }

    func test_chatMessage_uploadingStatesId() {
        // Given
        let id: String = .unique
        let state = "pendingUpload"
        let expectedId = "\(id)$\(state)"
        let message = ChatMessage.mock(
            id: id,
            cid: .unique,
            text: "test",
            author: .mock(id: .unique),
            attachments: ChatChannelTestHelpers.imageAttachments,
            localState: .pendingSend
        )

        // When
        let uploadingStatesId = message.uploadingStatesId
        let messageId = message.messageId

        // Then
        XCTAssert(messageId.contains(expectedId))
        XCTAssert(uploadingStatesId == state)
    }

    func test_chatMessage_messageIdComplete() {
        // Given
        let id: String = .unique
        let reaction = "like"
        let expectedId = "\(id)$pendingUploadlike3"
        let message = ChatMessage.mock(
            id: id,
            cid: .unique,
            text: "test",
            author: .mock(id: .unique),
            reactionScores: [
                MessageReactionType(rawValue: reaction): 3
            ],
            attachments: ChatChannelTestHelpers.imageAttachments,
            localState: .pendingSend
        )

        // When
        let messageId = message.messageId

        // Then
        XCTAssert(messageId.contains(expectedId))
    }

    func test_chatMessage_sendingState() {
        // Given
        let id: String = .unique
        let expectedId = "\(id)$sending"
        let message = ChatMessage.mock(
            id: id,
            cid: .unique,
            text: "test",
            author: .mock(id: .unique),
            localState: .sending
        )

        // When
        let messageId = message.messageId

        // Then
        XCTAssert(messageId.contains(expectedId))
    }

    func test_chatMessage_messageBuilder() {
        // Given
        let id: String = .unique
        let reaction = "like"
        let expectedId = id + "$empty" + "\(reaction)\(3)"
        let message = ChatMessage.mock(
            id: id,
            cid: .unique,
            text: "test",
            author: .mock(id: .unique),
            reactionScores: [
                MessageReactionType(rawValue: reaction): 3
            ]
        )
        let defaultMessageBuilder = DefaultMessageIdBuilder()

        // When
        let messageId = defaultMessageBuilder.makeMessageId(for: message)

        // Then
        XCTAssert(messageId.starts(with: expectedId))
    }
}
