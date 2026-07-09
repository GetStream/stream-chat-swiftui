//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import SwiftUI
import XCTest

@MainActor
final class ChatChannelList_Tests: StreamChatTestCase {
    func test_channelListIndexLookup_resolvesIndexInO1() {
        let channels = (0..<5).map {
            ChatChannel.mock(cid: ChannelId(type: .messaging, id: "\($0)"))
        }

        let lookup = channelListIndexLookup(for: channels)

        XCTAssertEqual(lookup.count, channels.count)
        for (index, channel) in channels.enumerated() {
            XCTAssertEqual(lookup[channel.id], index)
        }
    }

    func test_channelListIndexLookup_ignoresDuplicateIds() {
        let sharedId = ChannelId(type: .messaging, id: "shared")
        let first = ChatChannel.mock(cid: sharedId)
        let duplicate = ChatChannel.mock(cid: sharedId)
        let trailing = ChatChannel.mock(cid: ChannelId(type: .messaging, id: "trailing"))

        let lookup = channelListIndexLookup(for: [first, duplicate, trailing])

        XCTAssertEqual(lookup.count, 2)
        XCTAssertEqual(lookup[first.id], 0)
        XCTAssertEqual(lookup[trailing.id], 2)
    }

    func test_channelsLazyVStack_rendersProvidedChannels() {
        let channels = (0..<3).map {
            ChatChannel.mock(cid: ChannelId(type: .messaging, id: "\($0)"))
        }
        let view = ChannelsLazyVStack(
            factory: DefaultViewFactory.shared,
            channels: channels,
            selectedChannel: .constant(nil),
            swipedChannelId: .constant(nil),
            onItemTap: { _ in },
            onItemAppear: { _ in },
            trailingSwipeRightButtonTapped: { _ in },
            trailingSwipeLeftButtonTapped: { _ in },
            leadingSwipeButtonTapped: { _ in }
        )

        // Evaluating `body` exercises the shared channel list container used by
        // the compatibility wrapper and the default LazyVStack path.
        _ = view.body

        // Hosting the view verifies the LazyVStack rendering path does not crash.
        let hostingController = UIHostingController(rootView: view)
        XCTAssertNotNil(hostingController.view)
    }
}
