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

@MainActor class EditGroupView_Tests: StreamChatTestCase {
    func test_editGroupView_snapshot() {
        // Given
        let members = ChannelInfoMockUtils.setupMockMembers(
            count: 4,
            currentUserId: chatClient.currentUserId!
        )
        let group = ChatChannel.mock(
            cid: .unique,
            name: "Test Group",
            ownCapabilities: [.updateChannel],
            lastActiveMembers: members,
            memberCount: members.count
        )
        let viewModel = ChatChannelInfoViewModel(channel: group)

        // When
        let view = EditGroupView(viewModel: viewModel)
            .applyDefaultSize()

        // Then
        AssertSnapshot(view)
    }

    func test_editGroupView_uploadingSnapshot() {
        // Given
        let members = ChannelInfoMockUtils.setupMockMembers(
            count: 4,
            currentUserId: chatClient.currentUserId!
        )
        let group = ChatChannel.mock(
            cid: .unique,
            name: "Test Group",
            ownCapabilities: [.updateChannel],
            lastActiveMembers: members,
            memberCount: members.count
        )
        let viewModel = ChatChannelInfoViewModel(channel: group)
        viewModel.isUploadingGroupAvatar = true

        // When
        let view = EditGroupView(viewModel: viewModel)
            .applyDefaultSize()

        // Then
        AssertSnapshot(view)
    }
}
