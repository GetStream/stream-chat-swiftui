//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

/// Base class that sets up the `StreamChat` object.
open class StreamChatTestCase: XCTestCase {
    
    public static var currentUserId: String = .unique

    public var chatClient: ChatClient = {
        let client = ChatClient.mock()
        client.currentUserId = currentUserId
        return client
    }()
    
    public var streamChat: StreamChat?
    
    override open func setUp() {
        super.setUp()
        streamChat = StreamChat(chatClient: chatClient)
    }
}
