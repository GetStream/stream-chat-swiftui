//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import XCTest

class MoreChannelActionsView_Tests: StreamChatTestCase {

    func test_moreChannelActionsView_snapshot() {
        // Given
        let channel: ChatChannel = .mockDMChannel(name: "test")
        let actions = ChannelAction.defaultActions(
            for: channel,
            chatClient: chatClient,
            onDismiss: {},
            onError: { _ in }
        )

        // When
        let view = MoreChannelActionsView(
            channel: channel,
            channelActions: actions,
            swipedChannelId: .constant(nil),
            onDismiss: {}
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
}
