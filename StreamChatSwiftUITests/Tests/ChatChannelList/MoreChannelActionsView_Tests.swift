//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import XCTest

@MainActor class MoreChannelActionsView_Tests: StreamChatTestCase {
    func test_moreChannelActionsView_snapshot() {
        // Given
        let channel: ChatChannel = .mockDMChannel(name: "test")
        let actions = ChannelAction.defaultActions(
            for: .init(
                channel: channel,
                onDismiss: {},
                onError: { _ in }
            )
        )

        // When
        let view = MoreChannelActionsView(
            factory: DefaultViewFactory.shared,
            channel: channel,
            channelActions: actions,
            swipedChannelId: .constant(nil),
            onDismiss: {}
        )
        .applyDefaultSize()

        // Then
        AssertSnapshot(view)
    }

    func test_moreChannelActionsView_groupChannel_snapshot() {
        // Given
        let channel: ChatChannel = .mockNonDMChannel(name: "Engineering Team")
        let actions = ChannelAction.defaultActions(
            for: .init(
                channel: channel,
                onDismiss: {},
                onError: { _ in }
            )
        )

        // When
        let view = MoreChannelActionsView(
            factory: DefaultViewFactory.shared,
            channel: channel,
            channelActions: actions,
            swipedChannelId: .constant(nil),
            onDismiss: {}
        )
        .applyDefaultSize()

        // Then
        AssertSnapshot(view)
    }

    func test_moreChannelActionsView_mutedDMChannel_snapshot() {
        // Given
        let muteDetails = MuteDetails(createdAt: .distantPast, updatedAt: nil, expiresAt: nil)
        let channel: ChatChannel = .mockDMChannel(name: "test", muteDetails: muteDetails)
        let actions = ChannelAction.defaultActions(
            for: .init(
                channel: channel,
                onDismiss: {},
                onError: { _ in }
            )
        )

        // When
        let view = MoreChannelActionsView(
            factory: DefaultViewFactory.shared,
            channel: channel,
            channelActions: actions,
            swipedChannelId: .constant(nil),
            onDismiss: {}
        )
        .applyDefaultSize()

        // Then
        AssertSnapshot(view)
    }

    func test_moreChannelActionsView_archivedDMChannel_snapshot() {
        // Given
        let cid = ChannelId(type: .messaging, id: "!members-archived-test")
        let membership = ChatChannelMember.mock(id: .unique, archivedAt: .distantPast)
        let channel: ChatChannel = .mock(cid: cid, name: "test", membership: membership)
        let actions = ChannelAction.defaultActions(
            for: .init(
                channel: channel,
                onDismiss: {},
                onError: { _ in }
            )
        )

        // When
        let view = MoreChannelActionsView(
            factory: DefaultViewFactory.shared,
            channel: channel,
            channelActions: actions,
            swipedChannelId: .constant(nil),
            onDismiss: {}
        )
        .applyDefaultSize()

        // Then
        AssertSnapshot(view)
    }

    func test_moreChannelActionsView_groupWithLeaveConversation_snapshot() {
        // Given
        let channel: ChatChannel = .mockNonDMChannel(
            name: "Engineering Team",
            ownCapabilities: [.leaveChannel]
        )
        let actions = ChannelAction.defaultActions(
            for: .init(
                channel: channel,
                onDismiss: {},
                onError: { _ in }
            )
        )

        // When
        let view = MoreChannelActionsView(
            factory: DefaultViewFactory.shared,
            channel: channel,
            channelActions: actions,
            swipedChannelId: .constant(nil),
            onDismiss: {}
        )
        .applyDefaultSize()

        // Then
        AssertSnapshot(view)
    }
}
