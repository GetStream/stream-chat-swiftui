//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import SwiftUI
import XCTest

final class ChatMessageBubbles_Tests: StreamChatTestCase {

    @Injected(\.colors) var colors

    func test_messageBubbleCorners_notFirst() {
        // Given
        let message = ChatMessage.mock()
        let expected: UIRectCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]

        // When
        let corners = message.bubbleCorners(isFirst: false, forceLeftToRight: false)

        // Then
        XCTAssert(corners == expected)
    }

    func test_messageBubbleCorners_firstCurrentUser() {
        // Given
        let message = ChatMessage.mock(isSentByCurrentUser: true)
        let expected: UIRectCorner = [.topLeft, .topRight, .bottomLeft]

        // When
        let corners = message.bubbleCorners(isFirst: true, forceLeftToRight: false)

        // Then
        XCTAssert(corners == expected)
    }

    func test_messageBubbleCorners_firstOtherUser() {
        // Given
        let message = ChatMessage.mock(isSentByCurrentUser: false)
        let expected: UIRectCorner = [.topLeft, .topRight, .bottomRight]

        // When
        let corners = message.bubbleCorners(isFirst: true, forceLeftToRight: false)

        // Then
        XCTAssert(corners == expected)
    }

    func test_messageBubbleCorners_firstCurrentUserForceLeft() {
        // Given
        let message = ChatMessage.mock(isSentByCurrentUser: true)
        let expected: UIRectCorner = [.topLeft, .topRight, .bottomRight]

        // When
        let corners = message.bubbleCorners(isFirst: true, forceLeftToRight: true)

        // Then
        XCTAssert(corners == expected)
    }

    func test_bubbleBackgrounds_injected() {
        // Given
        let message = ChatMessage.mock()
        let injectedBackground = UIColor.red

        // When
        let background = message.bubbleBackground(colors: colors, injectedBackgroundColor: injectedBackground)

        // Then
        XCTAssert(background == [Color(injectedBackground)])
    }

    func test_bubbleBackgrounds_currentUserRegular() {
        // Given
        let message = ChatMessage.mock(isSentByCurrentUser: true)
        let expected = colors.messageCurrentUserBackground.map { Color($0) }

        // When
        let background = message.bubbleBackground(colors: colors)

        // Then
        XCTAssert(background == expected)
    }

    func test_bubbleBackgrounds_currentUserEphemeral() {
        // Given
        let message = ChatMessage.mock(type: MessageType.ephemeral, isSentByCurrentUser: true)
        let expected = colors.messageCurrentUserEmphemeralBackground.map { Color($0) }

        // When
        let background = message.bubbleBackground(colors: colors)

        // Then
        XCTAssert(background == expected)
    }

    func test_bubbleBackgrounds_otherUser() {
        // Given
        let message = ChatMessage.mock(isSentByCurrentUser: false)
        let expected = colors.messageOtherUserBackground.map { Color($0) }

        // When
        let background = message.bubbleBackground(colors: colors)

        // Then
        XCTAssert(background == expected)
    }
}
