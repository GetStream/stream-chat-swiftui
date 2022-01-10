//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class ChatChannelExtensions_Tests: XCTestCase {

    private var chatClient: ChatClient = {
        let client = ChatClient.mock()
        client.currentUserId = .unique
        return client
    }()
    
    private var streamChat: StreamChat?
        
    override func setUp() {
        super.setUp()
        streamChat = StreamChat(chatClient: chatClient)
    }
    
    func test_typingIndicatorString_unknownValue() {
        // Given
        let channel = ChatChannel.mockDMChannel()
        
        // When
        let typingIndicatorString = channel.typingIndicatorString
        
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
        let typingIndicatorString = channel.typingIndicatorString
        
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
        let typingIndicatorString = channel.typingIndicatorString
        
        // Then
        XCTAssert(
            typingIndicatorString == "Stefan and 1 more is typing"
                || typingIndicatorString == "Martin and 1 more is typing"
        ) // Any of the names can appear first.
    }
}
