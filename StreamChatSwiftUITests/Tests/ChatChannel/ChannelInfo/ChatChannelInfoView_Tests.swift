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

    func test_chatChannelInfoView_customActionsViewSnapshot() {
        // Given - a factory providing a custom actions section
        let members = ChannelInfoMockUtils.setupMockMembers(
            count: 3,
            currentUserId: chatClient.currentUserId!,
            onlineUserIndexes: [0]
        )
        let group = ChatChannel.mock(
            cid: .unique,
            name: "Test Group",
            ownCapabilities: [.leaveChannel, .updateChannel, .muteChannel],
            lastActiveMembers: members,
            memberCount: members.count
        )

        // When
        let view = ChatChannelInfoView(
            factory: ChannelInfoActionsViewFactory(),
            channel: group
        )
        .applyDefaultSize()

        // Then - the custom actions section replaces the default one
        AssertSnapshot(view)
    }

    func test_chatChannelInfoView_customActionsView_leaveConversationInvokesViewModel() throws {
        // Given
        let group = ChatChannel.mock(
            cid: .unique,
            name: "Test Group",
            ownCapabilities: [.leaveChannel],
            lastActiveMembers: ChannelInfoMockUtils.setupMockMembers(
                count: 3,
                currentUserId: chatClient.currentUserId!
            ),
            memberCount: 3
        )
        let viewModel = MockChatChannelInfoViewModel(channel: group)
        let factory = ChannelInfoActionsViewFactory()
        showView(ChatChannelInfoView(factory: factory, viewModel: viewModel))

        // When - the leave handler received by the factory is invoked
        let options = try XCTUnwrap(factory.capturedOptions)
        options.leaveConversation()

        // Then
        XCTAssertEqual(viewModel.leaveConversationTappedCallCount, 1)
    }

    func test_chatChannelInfoView_leaveConversation_whenShownFromMessageList_notifiesChannelDismiss() throws {
        // Given
        let factory = ChannelInfoActionsViewFactory()
        let viewModel = ImmediateLeaveChatChannelInfoViewModel(channel: mockGroup())
        showView(
            ChatChannelInfoView(
                factory: factory,
                viewModel: viewModel,
                channel: viewModel.channel,
                shownFromMessageList: true
            )
        )
        let dismissed = expectation(forNotification: NSNotification.Name(dismissChannel), object: nil)

        // When
        try XCTUnwrap(factory.capturedOptions).leaveConversation()

        // Then - the channel view behind the info screen is dismissed as well
        wait(for: [dismissed], timeout: defaultTimeout)
    }

    func test_chatChannelInfoView_leaveConversation_whenNotShownFromMessageList_doesNotNotifyChannelDismiss() throws {
        // Given
        let factory = ChannelInfoActionsViewFactory()
        let viewModel = ImmediateLeaveChatChannelInfoViewModel(channel: mockGroup())
        showView(
            ChatChannelInfoView(
                factory: factory,
                viewModel: viewModel,
                channel: viewModel.channel
            )
        )
        let dismissed = expectation(forNotification: NSNotification.Name(dismissChannel), object: nil)
        dismissed.isInverted = true

        // When
        try XCTUnwrap(factory.capturedOptions).leaveConversation()

        // Then - only the info screen is dismissed
        wait(for: [dismissed], timeout: defaultTimeoutForInversedExpecations)
    }

    // MARK: - ChannelInfoActionsView

    func test_channelInfoActionsView_groupSnapshot() {
        // Given
        let viewModel = ChatChannelInfoViewModel(
            channel: mockGroup(ownCapabilities: [.leaveChannel, .muteChannel])
        )

        // When
        let view = actionsView(for: viewModel)
            .applySize(CGSize(width: defaultScreenSize.width, height: 150))

        // Then - mute toggle and leave group button
        AssertSnapshot(view)
    }

    func test_channelInfoActionsView_directMessageSnapshot() {
        // Given
        let viewModel = ChatChannelInfoViewModel(
            channel: mockDirectMessage(ownCapabilities: [.deleteChannel, .muteChannel])
        )

        // When
        let view = actionsView(for: viewModel)
            .applySize(CGSize(width: defaultScreenSize.width, height: 200))

        // Then - mute toggle, block user and delete conversation button
        AssertSnapshot(view)
    }

    // MARK: - Helpers

    private func mockGroup(
        ownCapabilities: Set<ChannelCapability> = [.leaveChannel, .updateChannel, .muteChannel]
    ) -> ChatChannel {
        let members = ChannelInfoMockUtils.setupMockMembers(
            count: 3,
            currentUserId: chatClient.currentUserId!,
            onlineUserIndexes: [0]
        )
        return ChatChannel.mock(
            cid: .unique,
            name: "Test Group",
            ownCapabilities: ownCapabilities,
            lastActiveMembers: members,
            memberCount: members.count
        )
    }

    private func mockDirectMessage(
        ownCapabilities: Set<ChannelCapability> = [.deleteChannel]
    ) -> ChatChannel {
        let members = ChannelInfoMockUtils.setupMockMembers(
            count: 2,
            currentUserId: chatClient.currentUserId!
        )
        return ChatChannel.mockDMChannel(
            name: "Direct channel",
            ownCapabilities: ownCapabilities,
            lastActiveMembers: members,
            memberCount: members.count
        )
    }

    private func actionsView(for viewModel: ChatChannelInfoViewModel) -> ChannelInfoActionsView {
        ChannelInfoActionsView(
            options: ChannelInfoActionsViewOptions(
                viewModel: viewModel,
                leaveConversation: {}
            )
        )
    }
}

class ImmediateLeaveChatChannelInfoViewModel: ChatChannelInfoViewModel {
    override func leaveConversationTapped(completion: @escaping @MainActor () -> Void) {
        completion()
    }
}

class MockChatChannelInfoViewModel: ChatChannelInfoViewModel {
    var leaveConversationTappedCallCount = 0

    override func leaveConversationTapped(completion: @escaping @MainActor () -> Void) {
        leaveConversationTappedCallCount += 1
    }
}

class ChannelInfoActionsViewFactory: ViewFactory {
    @Injected(\.chatClient) var chatClient

    var styles = RegularStyles()

    var capturedOptions: ChannelInfoActionsViewOptions?

    func makeChannelInfoActionsView(options: ChannelInfoActionsViewOptions) -> some SwiftUI.View {
        capturedOptions = options
        return Text("Custom actions")
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red)
    }
}
