//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class ChannelControllerFactory_Tests: StreamChatTestCase {

    func test_channelControllerFactory_creation() async {
        // Given
        let factory = ChatCache()
        let channelId = ChannelId.unique

        // When
        let chat1 = await factory.chat(for: channelId)
        let chat2 = await factory.chat(for: channelId)

        // Then
        XCTAssert(chat1 === chat2)
    }

    func test_channelControllerFactory_removal() async {
        // Given
        let factory = ChatCache()
        let channelId = ChannelId.unique

        // When
        let chat1 = await factory.chat(for: channelId)
        factory.clearCurrentChat()
        let chat2 = await factory.chat(for: channelId)

        // Then
        XCTAssert(chat1 !== chat2)
    }
}
