//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

@testable import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

class ChatChannelInfoView_Tests: StreamChatTestCase {

    func test_chatChannelInfoView_directChannelOfflineSnapshot() {
        // Given
        let members = ChannelInfoMockUtils.setupMockMembers(
            count: 2,
            currentUserId: chatClient.currentUserId!
        )
        let channel = ChatChannel.mockDMChannel(
            name: "Direct channel",
            lastActiveMembers: members
        )

        // When
        let view = ChatChannelInfoView(channel: channel)
            .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_chatChannelInfoView_directChannelOnlineSnapshot() {
        // Given
        let members = ChannelInfoMockUtils.setupMockMembers(
            count: 2,
            currentUserId: chatClient.currentUserId!,
            onlineUserIndexes: [0, 1]
        )
        let channel = ChatChannel.mockDMChannel(
            name: "Direct channel",
            lastActiveMembers: members
        )

        // When
        let view = ChatChannelInfoView(channel: channel)
            .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_chatChannelInfoView_directChannelMutedSnapshot() {
        // Given
        let members = ChannelInfoMockUtils.setupMockMembers(
            count: 2,
            currentUserId: chatClient.currentUserId!
        )
        let channel = ChatChannel.mockDMChannel(
            name: "Direct channel",
            lastActiveMembers: members,
            muteDetails: MuteDetails(createdAt: Date(), updatedAt: Date())
        )

        // When
        let view = ChatChannelInfoView(channel: channel)
            .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_chatChannelInfoView_groupCollapsedSnapshot() {
        // Given
        let members = ChannelInfoMockUtils.setupMockMembers(
            count: 8,
            currentUserId: chatClient.currentUserId!,
            onlineUserIndexes: [0, 1]
        )
        let group = ChatChannel.mock(
            cid: .unique,
            name: "Test Group",
            ownCapabilities: [.deleteChannel, .updateChannel],
            lastActiveMembers: members,
            memberCount: members.count
        )

        // When
        let view = ChatChannelInfoView(channel: group)
            .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_chatChannelInfoView_smallGroupSnapshot() {
        // Given
        let members = ChannelInfoMockUtils.setupMockMembers(
            count: 2,
            currentUserId: chatClient.currentUserId!,
            onlineUserIndexes: [0, 1]
        )
        let group = ChatChannel.mock(
            cid: .unique,
            name: "Test Group",
            ownCapabilities: [.deleteChannel, .updateChannel],
            lastActiveMembers: members,
            memberCount: members.count
        )

        // When
        let view = ChatChannelInfoView(channel: group)
            .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_chatChannelInfoView_groupExpandedSnapshot() {
        // Given
        let members = ChannelInfoMockUtils.setupMockMembers(
            count: 8,
            currentUserId: chatClient.currentUserId!,
            onlineUserIndexes: [0, 1]
        )
        let group = ChatChannel.mock(
            cid: .unique,
            name: "Test Group",
            ownCapabilities: [.deleteChannel, .updateChannel],
            lastActiveMembers: members,
            memberCount: members.count
        )
        let viewModel = ChatChannelInfoViewModel(channel: group)
        viewModel.memberListCollapsed = false

        // When
        let view = ChatChannelInfoView(viewModel: viewModel)
            .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_chatChannelInfoView_navBarSnapshot() {
        // Given
        let members = ChannelInfoMockUtils.setupMockMembers(
            count: 2,
            currentUserId: chatClient.currentUserId!,
            onlineUserIndexes: [0, 1]
        )
        let group = ChatChannel.mock(
            cid: .unique,
            name: "Test Group",
            ownCapabilities: [.deleteChannel, .updateChannel],
            lastActiveMembers: members,
            memberCount: members.count
        )
        let viewModel = ChatChannelInfoViewModel(channel: group)

        // When
        let view = ChatChannelInfoView(viewModel: viewModel)
            .applyDefaultSize()

        let navigationView = NavigationView {
            view
        }
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: navigationView, as: .image(perceptualPrecision: precision))
    }

    func test_chatChannelInfoView_addUsersShownSnapshot() {
        // Given
        let members = ChannelInfoMockUtils.setupMockMembers(
            count: 8,
            currentUserId: chatClient.currentUserId!,
            onlineUserIndexes: [0, 1]
        )
        let group = ChatChannel.mock(
            cid: .unique,
            name: "Test Group",
            ownCapabilities: [.deleteChannel, .updateChannel],
            lastActiveMembers: members,
            memberCount: members.count
        )
        let viewModel = ChatChannelInfoViewModel(channel: group)
        viewModel.addUsersShown = true

        // When
        let view = ChatChannelInfoView(viewModel: viewModel)
            .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
}
