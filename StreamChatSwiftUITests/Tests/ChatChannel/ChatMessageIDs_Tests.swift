//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class ChatMessageIDs_Tests: StreamChatTestCase {
    func test_chatMessage_messageBuilder() {
        // Given
        let id: String = .unique
        let reaction = "like"
        let expectedId = id
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
        XCTAssertEqual(expectedId, messageId)
    }
}
