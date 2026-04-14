//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

@MainActor class MemberListView_Tests: StreamChatTestCase {
    func test_memberListView_withAddButtonSnapshot() {
        // Given
        let members = ChannelInfoMockUtils.setupMockMembers(
            count: 8,
            currentUserId: chatClient.currentUserId!,
            onlineUserIndexes: [0, 1]
        )
        let group = ChatChannel.mock(
            cid: .unique,
            name: "Test Group",
            ownCapabilities: [.updateChannelMembers],
            lastActiveMembers: members,
            memberCount: members.count
        )
        let viewModel = ChatChannelInfoViewModel(channel: group)

        // When
        let view = MemberListView(factory: DefaultTestViewFactory.shared, viewModel: viewModel)
            .applyDefaultSize()

        // Then
        AssertSnapshot(view)
    }

    func test_memberListView_withoutAddButtonSnapshot() {
        // Given
        let members = ChannelInfoMockUtils.setupMockMembers(
            count: 8,
            currentUserId: chatClient.currentUserId!,
            onlineUserIndexes: [0, 1]
        )
        let group = ChatChannel.mock(
            cid: .unique,
            name: "Test Group",
            ownCapabilities: [],
            lastActiveMembers: members,
            memberCount: members.count
        )
        let viewModel = ChatChannelInfoViewModel(channel: group)

        // When
        let view = MemberListView(factory: DefaultTestViewFactory.shared, viewModel: viewModel)
            .applyDefaultSize()

        // Then
        AssertSnapshot(view)
    }
}
