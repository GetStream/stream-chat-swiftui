//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class ChatChannelExtensions_Tests: StreamChatTestCase {

    func test_typingIndicatorString_unknownValue() {
        // Given
        let channel = ChatChannel.mockDMChannel()

        // When
        let typingIndicatorString = channel.typingIndicatorString(currentUserId: nil)

        // Then
        XCTAssert(typingIndicatorString == "Someone is typing")
    }

    func test_typingIndicatorString_singularValue() {
        // Given
        let typingUser: ChatChannelMember = ChatChannelMember.mock(
            id: .unique, name: "Martin"
        )
        let channel = ChatChannel.mockDMChannel(
            currentlyTypingUsers: Set(arrayLiteral: typingUser)
        )

        // When
        let typingIndicatorString = channel.typingIndicatorString(currentUserId: nil)

        // Then
        XCTAssert(typingIndicatorString == "Martin is typing")
    }

    func test_typingIndicatorString_pluralValue() {
        // Given
        let typingUser1: ChatChannelMember = ChatChannelMember.mock(
            id: .unique, name: "Stefan"
        )
        let typingUser2: ChatChannelMember = ChatChannelMember.mock(
            id: .unique, name: "Martin"
        )
        let channel = ChatChannel.mockDMChannel(
            currentlyTypingUsers: Set(arrayLiteral: typingUser1, typingUser2)
        )

        // When
        let typingIndicatorString = channel.typingIndicatorString(currentUserId: nil)

        // Then
        XCTAssert(
            typingIndicatorString == "Stefan and 1 more are typing"
                || typingIndicatorString == "Martin and 1 more are typing"
        ) // Any of the names can appear first.
    }

    func test_readUsers_availableUsers() {
        // Given
        let user = ChatUser.mock(id: .unique)
        let messages = [ChatMessage.mock(id: .unique, cid: .unique, text: "Test", author: ChatUser.mock(id: .unique))]
        let read = ChatChannelRead(lastReadAt: Date(), lastReadMessageId: nil, unreadMessagesCount: 0, user: user)
        let channel = ChatChannel.mockDMChannel(reads: [read], latestMessages: messages)

        // When
        let readUsers = channel.readUsers(currentUserId: nil, message: messages[0])

        // Then
        XCTAssert(readUsers.count == 1)
        XCTAssert(readUsers[0] == user)
    }

    func test_readUsers_empty() {
        // Given
        let channel = ChatChannel.mockDMChannel(reads: [])

        // When
        let readUsers = channel.readUsers(currentUserId: nil, message: nil)

        // Then
        XCTAssert(readUsers.isEmpty)
    }
}
