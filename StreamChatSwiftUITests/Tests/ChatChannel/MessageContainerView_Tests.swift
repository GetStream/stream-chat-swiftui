//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class MessageContainerView_Tests: StreamChatTestCase {
    
    override func setUp() {
        super.setUp()
        let utils = Utils(dateFormatter: EmptyDateFormatter())
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
    }
    
    func test_messageContainerViewSentThisUser_snapshot() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Message sent by current user",
            author: .mock(id: Self.currentUserId, name: "Martin"),
            isSentByCurrentUser: true
        )
        
        // Then
        testMessageViewContainerSnapshot(message: message)
    }
    
    func test_messageContainerViewSentOtherUser_snapshot() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Message sent by other user",
            author: .mock(id: .unique, name: "Martin")
        )
        
        // Then
        testMessageViewContainerSnapshot(message: message)
    }

    func test_messageContainerViewPinned_snapshot() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "This is a pinned message",
            author: .mock(id: .unique, name: "Martin"),
            pinDetails: MessagePinDetails(
                pinnedAt: Date(),
                pinnedBy: .mock(id: .unique, name: "Martin"),
                expiresAt: nil
            )
        )
        
        // Then
        testMessageViewContainerSnapshot(message: message)
    }
    
    // MARK: - private
    
    func testMessageViewContainerSnapshot(message: ChatMessage) {
        // When
        let view = MessageContainerView(
            factory: DefaultViewFactory.shared,
            channel: .mockDMChannel(),
            message: message,
            width: defaultScreenSize.width,
            showsAllInfo: true,
            isInThread: false,
            isLast: false,
            scrolledId: .constant(nil),
            quotedMessage: .constant(nil),
            onLongPress: { _ in }
        )
        .frame(width: 375, height: 200)
        
        // Then
        assertSnapshot(matching: view, as: .image)
    }
}
