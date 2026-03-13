//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

@MainActor class ChatChannelInfoView_Tests: StreamChatTestCase {
    func test_chatChannelInfoView_navigationBarAppearance() {
        // Given
        setThemedNavigationBarAppearance()
        let members = ChannelInfoMockUtils.setupMockMembers(
            count: 8,
            currentUserId: chatClient.currentUserId!,
            onlineUserIndexes: [0, 1]
        )
        let channel = ChatChannel.mock(
            cid: .unique,
            name: "Test Group",
            ownCapabilities: [.deleteChannel, .updateChannel, .updateChannelMembers, .muteChannel],
            lastActiveMembers: members,
            memberCount: members.count
        )
        
        // When
        let view = NavigationContainerView(embedInNavigationView: true) {
            ChatChannelInfoView(channel: channel)
        }.applyDefaultSize()
        
        // Then
        AssertSnapshot(view)
    }

    func test_chatChannelInfoView_rtlSnapshot() {
        // Given
        let members = ChannelInfoMockUtils.setupMockMembers(
            count: 8,
            currentUserId: chatClient.currentUserId!,
            onlineUserIndexes: [0, 1]
        )
        let channel = ChatChannel.mock(
            cid: .unique,
            name: "Test Group",
            ownCapabilities: [.deleteChannel, .updateChannel, .updateChannelMembers, .muteChannel],
            lastActiveMembers: members,
            memberCount: members.count
        )

        // When – RTL layout (e.g. Arabic)
        let view = NavigationContainerView(embedInNavigationView: true) {
            ChatChannelInfoView(channel: channel)
        }
        .environment(\.layoutDirection, .rightToLeft)
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision), named: "rtl")
    }
    
    func test_chatChannelInfoView_directChannelOfflineSnapshot() {
        // Given
        let members = ChannelInfoMockUtils.setupMockMembers(
            count: 2,
            currentUserId: chatClient.currentUserId!
        )
        let channel = ChatChannel.mockDMChannel(
            name: "Direct channel",
            ownCapabilities: [.muteChannel],
            lastActiveMembers: members
        )

        // When
        let view = ChatChannelInfoView(channel: channel)
            .applyDefaultSize()

        // Then
        AssertSnapshot(view)
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
            ownCapabilities: [.muteChannel],
            lastActiveMembers: members
        )

        // When
        let view = ChatChannelInfoView(channel: channel)
            .applyDefaultSize()

        // Then
        AssertSnapshot(view)
    }
    
    func test_chatChannelInfoView_directChannelMoreMembersSnapshot() {
        // Given
        let members = ChannelInfoMockUtils.setupMockMembers(
            count: 3,
            currentUserId: chatClient.currentUserId!
        )
        let channel = ChatChannel.mockDMChannel(
            name: "Direct channel",
            ownCapabilities: [.muteChannel],
            lastActiveMembers: members
        )

        // When
        let view = ChatChannelInfoView(channel: channel)
            .applyDefaultSize()

        // Then
        AssertSnapshot(view)
    }

    func test_chatChannelInfoView_directChannelMutedSnapshot() {
        // Given
        let members = ChannelInfoMockUtils.setupMockMembers(
            count: 2,
            currentUserId: chatClient.currentUserId!
        )
        let channel = ChatChannel.mockDMChannel(
            name: "Direct channel",
            ownCapabilities: [.muteChannel],
            lastActiveMembers: members,
            muteDetails: MuteDetails(createdAt: Date(), updatedAt: Date(), expiresAt: nil)
        )

        // When
        let view = ChatChannelInfoView(channel: channel)
            .applyDefaultSize()

        // Then
        AssertSnapshot(view)
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
            ownCapabilities: [.deleteChannel, .updateChannel, .muteChannel],
            lastActiveMembers: members,
            memberCount: members.count
        )

        // When
        let view = ChatChannelInfoView(channel: group)
            .applyDefaultSize()

        // Then
        AssertSnapshot(view)
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
            ownCapabilities: [.leaveChannel, .updateChannel, .muteChannel],
            lastActiveMembers: members,
            memberCount: members.count
        )

        // When
        let view = ChatChannelInfoView(channel: group)
            .applyDefaultSize()

        // Then
        AssertSnapshot(view)
    }
    
    func test_chatChannelInfoView_smallGroupDeactivatedSnapshot() {
        // Given
        let members = ChannelInfoMockUtils.setupMockMembers(
            count: 3,
            currentUserId: chatClient.currentUserId!,
            onlineUserIndexes: [0, 1],
            deactivatedUserIndexes: [2]
        )
        let group = ChatChannel.mock(
            cid: .unique,
            name: "Test Group",
            ownCapabilities: [.leaveChannel, .updateChannel, .muteChannel],
            lastActiveMembers: members,
            memberCount: members.count
        )

        // When
        let view = ChatChannelInfoView(channel: group)
            .applyDefaultSize()

        // Then
        AssertSnapshot(view)
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
            ownCapabilities: [.deleteChannel, .updateChannel, .muteChannel],
            lastActiveMembers: members,
            memberCount: members.count
        )
        let viewModel = ChatChannelInfoViewModel(channel: group)
        viewModel.memberListCollapsed = false

        // When
        let view = ChatChannelInfoView(viewModel: viewModel)
            .applyDefaultSize()

        // Then
        AssertSnapshot(view)
    }
    
    func test_chatChannelInfoView_groupCollapsedDeactivatedSnapshot() {
        // Given
        let members = ChannelInfoMockUtils.setupMockMembers(
            count: 8,
            currentUserId: chatClient.currentUserId!,
            onlineUserIndexes: [0, 1],
            deactivatedUserIndexes: [2, 3]
        )
        let group = ChatChannel.mock(
            cid: .unique,
            name: "Test Group",
            ownCapabilities: [.deleteChannel, .updateChannel, .muteChannel],
            lastActiveMembers: members,
            memberCount: members.count
        )
        let viewModel = ChatChannelInfoViewModel(channel: group)

        // When
        let view = ChatChannelInfoView(viewModel: viewModel)
            .applyDefaultSize()

        // Then
        AssertSnapshot(view)
    }
    
    func test_chatChannelInfoView_groupCollapsedLargeDeactivatedSnapshot() {
        // Given
        let members = ChannelInfoMockUtils.setupMockMembers(
            count: 8,
            currentUserId: chatClient.currentUserId!,
            onlineUserIndexes: [0, 1],
            deactivatedUserIndexes: [5]
        )
        let group = ChatChannel.mock(
            cid: .unique,
            name: "Test Group",
            ownCapabilities: [.deleteChannel, .updateChannel, .muteChannel],
            lastActiveMembers: members,
            memberCount: members.count
        )
        let viewModel = ChatChannelInfoViewModel(channel: group)

        // When
        let view = ChatChannelInfoView(viewModel: viewModel)
            .applyDefaultSize()

        // Then
        AssertSnapshot(view)
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
            ownCapabilities: [.updateChannel, .leaveChannel, .updateChannelMembers, .muteChannel],
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
            ownCapabilities: [.deleteChannel, .muteChannel, .updateChannel],
            lastActiveMembers: members,
            memberCount: members.count
        )
        let viewModel = ChatChannelInfoViewModel(channel: group)
        viewModel.addUsersShown = true

        // When
        let view = ChatChannelInfoView(viewModel: viewModel)
            .applyDefaultSize()

        // Then
        AssertSnapshot(view)
    }
    
    func test_chatChannelInfoView_participantSelectedBasicActionsSnapshot() {
        // Given
        let members = ChannelInfoMockUtils.setupMockMembers(
            count: 3,
            currentUserId: chatClient.currentUserId!,
            onlineUserIndexes: [0, 1]
        )
        let group = ChatChannel.mock(
            cid: .unique,
            name: "Test Group",
            ownCapabilities: [.updateChannelMembers, .muteChannel],
            lastActiveMembers: members,
            memberCount: members.count
        )
        let viewModel = ChatChannelInfoViewModel(channel: group)
        // Select the second participant (index 1)
        viewModel.selectedParticipant = viewModel.displayedParticipants[1]

        // When
        let view = ChatChannelInfoView(viewModel: viewModel)
            .applyDefaultSize()

        // Then
        AssertSnapshot(view)
    }
    
    func test_chatChannelInfoView_participantSelectedWithMuteActionsSnapshot() {
        // Given
        let members = ChannelInfoMockUtils.setupMockMembers(
            count: 3,
            currentUserId: chatClient.currentUserId!,
            onlineUserIndexes: [0, 1]
        )
        let config = ChannelConfig(mutesEnabled: true)
        let group = ChatChannel.mock(
            cid: .unique,
            name: "Test Group",
            config: config,
            ownCapabilities: [.updateChannelMembers, .muteChannel],
            lastActiveMembers: members,
            memberCount: members.count
        )
        let viewModel = ChatChannelInfoViewModel(channel: group)
        // Select the second participant (index 1)
        viewModel.selectedParticipant = viewModel.displayedParticipants[1]

        // When
        let view = ChatChannelInfoView(viewModel: viewModel)
            .applyDefaultSize()

        // Then
        AssertSnapshot(view)
    }
    
    func test_chatChannelInfoView_participantSelectedWithRemoveActionSnapshot() {
        // Given
        let members = ChannelInfoMockUtils.setupMockMembers(
            count: 3,
            currentUserId: chatClient.currentUserId!,
            onlineUserIndexes: [0, 1]
        )
        let group = ChatChannel.mock(
            cid: .unique,
            name: "Test Group",
            ownCapabilities: [.updateChannelMembers, .muteChannel],
            lastActiveMembers: members,
            memberCount: members.count
        )
        let viewModel = ChatChannelInfoViewModel(channel: group)
        // Select the second participant (index 1)
        viewModel.selectedParticipant = viewModel.displayedParticipants[1]

        // When
        let view = ChatChannelInfoView(viewModel: viewModel)
            .applyDefaultSize()

        // Then
        AssertSnapshot(view)
    }
    
    func test_chatChannelInfoView_participantSelectedOfflineUserSnapshot() {
        // Given
        let members = ChannelInfoMockUtils.setupMockMembers(
            count: 3,
            currentUserId: chatClient.currentUserId!,
            onlineUserIndexes: [0] // Only current user is online
        )
        let group = ChatChannel.mock(
            cid: .unique,
            name: "Test Group",
            ownCapabilities: [.updateChannelMembers, .muteChannel],
            lastActiveMembers: members,
            memberCount: members.count
        )
        let viewModel = ChatChannelInfoViewModel(channel: group)
        // Select the second participant (index 1) who is offline
        viewModel.selectedParticipant = viewModel.displayedParticipants[1]

        // When
        let view = ChatChannelInfoView(viewModel: viewModel)
            .applyDefaultSize()

        // Then
        AssertSnapshot(view)
    }

    func test_chatChannelInfoView_smallGroupWithLeaveButtonSnapshot() {
        // Given - a small group (≤5 members) with leaveChannel capability shows the leave button
        let members = ChannelInfoMockUtils.setupMockMembers(
            count: 3,
            currentUserId: chatClient.currentUserId!,
            onlineUserIndexes: [0]
        )
        let group = ChatChannel.mock(
            cid: .unique,
            name: "Small Group",
            ownCapabilities: [.leaveChannel, .updateChannel, .muteChannel],
            lastActiveMembers: members,
            memberCount: members.count
        )

        // When
        let view = ChatChannelInfoView(channel: group)
            .applyDefaultSize()

        // Then
        AssertSnapshot(view)
    }

    func test_chatChannelInfoView_currentUserRowTappableSnapshot() {
        // Given - current user (shown as "You") is visible and tappable in the member list
        let members = ChannelInfoMockUtils.setupMockMembers(
            count: 3,
            currentUserId: chatClient.currentUserId!,
            onlineUserIndexes: [0]
        )
        let group = ChatChannel.mock(
            cid: .unique,
            name: "Test Group",
            ownCapabilities: [.leaveChannel, .updateChannelMembers, .muteChannel],
            lastActiveMembers: members,
            memberCount: members.count
        )
        let viewModel = ChatChannelInfoViewModel(channel: group)
        // Current user is at index 0
        viewModel.selectedParticipant = viewModel.displayedParticipants[0]

        // When
        let view = ChatChannelInfoView(viewModel: viewModel)
            .applyDefaultSize()

        // Then - current user row is tappable and shows leave group action
        AssertSnapshot(view)
    }

    func test_chatChannelInfoView_multiPersonDMSnapshot() {
        // Given - a DM channel with more than 2 members (multi-person DM)
        let members = ChannelInfoMockUtils.setupMockMembers(
            count: 3,
            currentUserId: chatClient.currentUserId!,
            onlineUserIndexes: [0, 1]
        )
        let channel = ChatChannel.mockDMChannel(
            name: "Group DM",
            lastActiveMembers: members,
            memberCount: members.count
        )

        // When
        let view = ChatChannelInfoView(channel: channel)
            .applyDefaultSize()

        // Then - shows group-style layout with member list, not single DM header
        AssertSnapshot(view)
    }
}
