//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class ChannelControllerFactory_Tests: StreamChatTestCase {

    func test_channelControllerFactory_creation() {
        // Given
        let factory = ChannelControllerFactory()
        let channelId = ChannelId.unique

        // When
        let controller1 = factory.makeChannelController(for: channelId)
        let controller2 = factory.makeChannelController(for: channelId)

        // Then
        XCTAssert(controller1 === controller2)
    }

    func test_channelControllerFactory_removal() {
        // Given
        let factory = ChannelControllerFactory()
        let channelId = ChannelId.unique

        // When
        let controller1 = factory.makeChannelController(for: channelId)
        factory.clearCurrentController()
        let controller2 = factory.makeChannelController(for: channelId)

        // Then
        XCTAssert(controller1 !== controller2)
    }
}
