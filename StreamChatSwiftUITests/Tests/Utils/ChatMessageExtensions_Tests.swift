//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
@testable import StreamChatSwiftUI
import XCTest

final class ChatMessageExtensions_Tests: StreamChatTestCase {
    func test_chatMessage_translatedTextContent_forParticipantReturnsTranslatedText() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hello",
            author: .mock(id: .unique),
            translations: [
                .spanish: "Hola"
            ]
        )
        
        // When
        let text = message.textContent(for: .spanish)

        // Then
        XCTAssertEqual("Hola", text)
    }
    
    func test_chatMessage_translatedTextContent_forMeDoesNotReturnTranslatedText() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hello",
            author: .mock(id: .unique),
            translations: [
                .spanish: "Hola"
            ],
            isSentByCurrentUser: true
        )
        
        // When
        let text = message.textContent(for: .spanish)

        // Then
        XCTAssertEqual(nil, text)
    }
}
