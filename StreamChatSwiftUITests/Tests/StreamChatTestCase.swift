//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
@_exported import StreamChatTestHelpers
@_exported import StreamChatTestTools
import XCTest

/// Base class that sets up the `StreamChat` object.
open class StreamChatTestCase: XCTestCase {

    public static var currentUserId: String = .unique
    public let snapshotPrecision: Float = 0.97

    public var chatClient: ChatClient = {
        let client = ChatClient.mock(isLocalStorageEnabled: false)
        let tokenValue =
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoibHVrZV9za3l3YWxrZXIifQ.b6EiC8dq2AHk0JPfI-6PN-AM9TVzt8JV-qB1N9kchlI"
        let token = try! Token(rawValue: tokenValue)
        client.connectUser(userInfo: .init(id: currentUserId), token: token)
        return client
    }()

    public var streamChat: StreamChat?

    override open func setUp() {
        super.setUp()
        streamChat = StreamChat(chatClient: chatClient)
    }
}
