//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class ChatMessageIDs_Tests: XCTestCase {
        
    func test_chatMessage_reactionScoresId() {
        // Given
        let id: String = .unique
        let reaction = "like"
        let expectedId = id + "\(reaction)\(3)"
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
        XCTAssert(messageId == expectedId)
    }
    
    func test_chatMessage_DeletedId() {
        // Given
        let id: String = .unique
        let expectedId = "\(id)-deleted"
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
        XCTAssert(messageId == expectedId)
    }
    
    func test_chatMessage_uploadingStatesId() {
        // Given
        let id: String = .unique
        let state = "pendingUpload"
        let expectedId = "\(id)\(state)"
        let message = ChatMessage.mock(
            id: id,
            cid: .unique,
            text: "test",
            author: .mock(id: .unique),
            attachments: ChatChannelTestHelpers.imageAttachments
        )
        
        // When
        let uploadingStatesId = message.uploadingStatesId
        let messageId = message.messageId
        
        // Then
        XCTAssert(messageId == expectedId)
        XCTAssert(uploadingStatesId == state)
    }

    func test_chatMessage_messageIdComplete() {
        // Given
        let id: String = .unique
        let reaction = "like"
        let expectedId = "\(id)pendingUploadlike3"
        let message = ChatMessage.mock(
            id: id,
            cid: .unique,
            text: "test",
            author: .mock(id: .unique),
            reactionScores: [
                MessageReactionType(rawValue: reaction): 3
            ],
            attachments: ChatChannelTestHelpers.imageAttachments
        )
        
        // When
        let messageId = message.messageId
        
        // Then
        XCTAssert(messageId == expectedId)
    }
}
