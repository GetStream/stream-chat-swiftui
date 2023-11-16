//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

@testable import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

class PinnedMessagesView_Tests: StreamChatTestCase {

    override func setUp() {
        super.setUp()
        let utils = Utils(dateFormatter: EmptyDateFormatter())
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
    }

    func test_pinnedMessagesView_notEmptySnapshot() {
        // Given
        let channel = ChatChannel.mockDMChannel(
            pinnedMessages: [ChannelInfoMockUtils.pinnedMessage]
        )

        // When
        let view = PinnedMessagesView(channel: channel)
            .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_pinnedMessagesView_emptySnapshot() {
        // Given
        let channel = ChatChannel.mockDMChannel()

        // When
        let view = PinnedMessagesView(channel: channel)
            .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
}

// Temp solution for failing tests.
class EmptyDateFormatter: DateFormatter {

    override func string(from date: Date) -> String {
        ""
    }
}
