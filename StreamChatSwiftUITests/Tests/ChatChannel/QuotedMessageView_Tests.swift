//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import SwiftUI
import XCTest

class QuotedMessageView_Tests: XCTestCase {

    private var chatClient: ChatClient = {
        let client = ChatClient.mock()
        client.currentUserId = .unique
        return client
    }()
    
    private let testMessage = ChatMessage.mock(
        id: "test",
        cid: .unique,
        text: "This is a test message 1",
        author: .mock(id: "test", name: "martin")
    )
    
    private var streamChat: StreamChat?
    
    override func setUp() {
        super.setUp()
        streamChat = StreamChat(chatClient: chatClient)
    }
    
    func test_quotedMessageViewContainer_snapshot() {
        // Given
        let view = QuotedMessageViewContainer(
            quotedMessage: testMessage,
            fillAvailableSpace: true,
            scrolledId: .constant(nil)
        )
        .frame(width: defaultScreenSize.width, height: defaultScreenSize.height)

        // Then
        assertSnapshot(matching: view, as: .image)
    }
    
    func test_quotedMessageView_snapshot() {
        // Given
        let view = QuotedMessageView(
            quotedMessage: testMessage,
            fillAvailableSpace: true,
            forceLeftToRight: true
        )
        .frame(width: defaultScreenSize.width, height: defaultScreenSize.height)

        // Then
        assertSnapshot(matching: view, as: .image)
    }
}
