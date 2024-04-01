//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class ChannelControllerFactory_Tests: StreamChatTestCase {

    func test_channelControllerFactory_creation() {
        // Given
        let factory = ChatCache()
        let channelId = ChannelId.unique

        // When
        let chat1 = factory.chat(for: channelId)
        let chat2 = factory.chat(for: channelId)

        // Then
        XCTAssert(chat1 === chat2)
    }

    func test_channelControllerFactory_removal() {
        // Given
        let factory = ChatCache()
        let channelId = ChannelId.unique

        // When
        let chat1 = factory.chat(for: channelId)
        factory.clearCurrentChat()
        let chat2 = factory.chat(for: channelId)

        // Then
        XCTAssert(chat1 !== chat2)
    }
}
