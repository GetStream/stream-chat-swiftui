//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

@MainActor class MoreChannelActionsViewModel_Tests: StreamChatTestCase {
    @Injected(\.images) var images

    func test_moreActionsVM_membersLoaded() throws {
        // Given
        let currentUserId = try XCTUnwrap(streamChat?.chatClient.currentUserId)
        let memberId: String = .unique
        let viewModel = makeMoreActionsViewModel(
            members: [
                .mock(id: memberId, isOnline: true),
                .mock(id: currentUserId, isOnline: true)
            ]
        )

        // When
        let members = viewModel.members

        // Then
        XCTAssert(members.count == 2)
        XCTAssert(members.map(\.id) == [memberId, currentUserId])
    }

    func test_moreActionsVM_chatHeaderInfo() {
        // Given
        let viewModel = makeMoreActionsViewModel()

        // When
        let title = viewModel.chatName
        let subtitle = viewModel.subtitleText

        // Then
        XCTAssert(title == "test")
        XCTAssert(subtitle == "Online")
    }

    // MARK: - DefaultChannelActions - DM channel tests

    func test_defaultActions_dmChannel_hasCorrectDefaultActions() {
        // Given - default ownCapabilities has no deleteChannel
        let channel = ChatChannel.mockDMChannel(name: "test")

        // When
        let actions = makeActions(for: channel)

        // Then - viewInfo, muteUser (mutesEnabled=true by default)
        XCTAssertEqual(actions.count, 2)
        XCTAssertEqual(actions[0].title, L10n.Alert.Actions.viewInfoTitle)
        XCTAssertEqual(actions[1].title, L10n.Alert.Actions.muteUser)
    }

    func test_defaultActions_dmChannel_withDeleteCapability_hasDeleteAction() {
        // Given
        let channel = ChatChannel.mockDMChannel(
            name: "test",
            ownCapabilities: [.sendMessage, .deleteChannel]
        )

        // When
        let actions = makeActions(for: channel)

        // Then
        XCTAssertTrue(actions.contains(where: { $0.title == L10n.Alert.Actions.deleteChannelTitle }))
        XCTAssertEqual(actions.last?.title, L10n.Alert.Actions.deleteChannelTitle)
    }

    func test_defaultActions_dmChannel_withOtherMember_hasBlockAction() {
        // Given
        let channel = ChatChannel.mockDMChannel(
            name: "test",
            lastActiveMembers: [.mock(id: .unique, isOnline: true)]
        )

        // When
        let actions = makeActions(for: channel)

        // Then
        XCTAssertTrue(actions.contains(where: { $0.title == L10n.Alert.Actions.blockUser }))
    }

    func test_defaultActions_mutedDMChannel_showsUnmuteUser() {
        // Given
        let muteDetails = MuteDetails(createdAt: .distantPast, updatedAt: nil, expiresAt: nil)
        let channel = ChatChannel.mockDMChannel(name: "test", muteDetails: muteDetails)

        // When
        let actions = makeActions(for: channel)

        // Then
        XCTAssertTrue(actions.contains(where: { $0.title == L10n.Alert.Actions.unmuteUser }))
        XCTAssertFalse(actions.contains(where: { $0.title == L10n.Alert.Actions.muteUser }))
    }

    func test_defaultActions_archivedDMChannel_showsUnarchiveConversation() {
        // Given
        let cid = ChannelId(type: .messaging, id: "!members-archived-unit-test")
        let membership = ChatChannelMember.mock(id: .unique, archivedAt: .distantPast)
        let channel = ChatChannel.mock(cid: cid, name: "test", membership: membership)

        // When
        let actions = makeActions(for: channel)

        // Then - archive action removed; neither archive nor unarchive should appear
        XCTAssertFalse(actions.contains(where: { $0.title == L10n.Alert.Actions.unarchiveConversation }))
        XCTAssertFalse(actions.contains(where: { $0.title == L10n.Alert.Actions.archiveConversation }))
    }

    // MARK: - DefaultChannelActions - Group channel tests

    func test_defaultActions_groupChannel_hasCorrectDefaultActions() {
        // Given - default ownCapabilities has no deleteChannel or leaveChannel
        let channel = ChatChannel.mockNonDMChannel(name: "Engineering Team")

        // When
        let actions = makeActions(for: channel)

        // Then - viewInfo, muteChannel (mutesEnabled=true by default)
        XCTAssertEqual(actions.count, 2)
        XCTAssertEqual(actions[0].title, L10n.Alert.Actions.viewInfoTitle)
        XCTAssertEqual(actions[1].title, L10n.Alert.Actions.muteChannel)
    }

    func test_defaultActions_groupChannel_withDeleteCapability_hasDeleteAction() {
        // Given
        let channel = ChatChannel.mockNonDMChannel(
            name: "Engineering Team",
            ownCapabilities: [.sendMessage, .deleteChannel]
        )

        // When
        let actions = makeActions(for: channel)

        // Then
        XCTAssertTrue(actions.contains(where: { $0.title == L10n.Alert.Actions.deleteChannelTitle }))
        XCTAssertFalse(actions.contains(where: { $0.title == L10n.Alert.Actions.leaveConversation }))
    }

    func test_defaultActions_groupChannel_withLeaveCapability_showsLeaveConversation() {
        // Given
        let channel = ChatChannel.mockNonDMChannel(
            name: "Engineering Team",
            ownCapabilities: [.sendMessage, .leaveChannel]
        )

        // When
        let actions = makeActions(for: channel)

        // Then
        XCTAssertTrue(actions.contains(where: { $0.title == L10n.Alert.Actions.leaveConversation }))
        XCTAssertFalse(actions.contains(where: { $0.title == L10n.Alert.Actions.deleteChannelTitle }))
    }

    func test_defaultActions_groupChannel_deletePreferredOverLeave() {
        // Given - both capabilities present, delete takes priority
        let channel = ChatChannel.mockNonDMChannel(
            name: "Engineering Team",
            ownCapabilities: [.sendMessage, .deleteChannel, .leaveChannel]
        )

        // When
        let actions = makeActions(for: channel)

        // Then
        XCTAssertTrue(actions.contains(where: { $0.title == L10n.Alert.Actions.deleteChannelTitle }))
        XCTAssertFalse(actions.contains(where: { $0.title == L10n.Alert.Actions.leaveConversation }))
    }

    // MARK: - DefaultChannelActions - Destructive flag tests

    func test_defaultActions_deleteAction_isDestructive() {
        // Given
        let channel = ChatChannel.mockNonDMChannel(
            name: "Engineering Team",
            ownCapabilities: [.sendMessage, .deleteChannel]
        )

        // When
        let actions = makeActions(for: channel)

        // Then
        let deleteAction = actions.first(where: { $0.title == L10n.Alert.Actions.deleteChannelTitle })
        XCTAssertNotNil(deleteAction)
        XCTAssertTrue(deleteAction?.isDestructive == true)
    }

    func test_defaultActions_leaveAction_isDestructive() {
        // Given
        let channel = ChatChannel.mockNonDMChannel(
            name: "Engineering Team",
            ownCapabilities: [.sendMessage, .leaveChannel]
        )

        // When
        let actions = makeActions(for: channel)

        // Then
        let leaveAction = actions.first(where: { $0.title == L10n.Alert.Actions.leaveConversation })
        XCTAssertNotNil(leaveAction)
        XCTAssertTrue(leaveAction?.isDestructive == true)
    }

    // MARK: - private

    private func makeActions(for channel: ChatChannel) -> [ChannelAction] {
        ChannelAction.defaultActions(
            for: SupportedMoreChannelActionsOptions(
                channel: channel,
                onDismiss: {},
                onError: { _ in }
            )
        )
    }

    private func makeMoreActionsViewModel(
        members: [ChatChannelMember] = []
    ) -> MoreChannelActionsViewModel {
        var channelMembers = [ChatChannelMember]()
        if !members.isEmpty {
            channelMembers = members
        } else {
            channelMembers = [.mock(id: .unique, isOnline: true)]
        }
        let channel = ChatChannel.mockDMChannel(
            name: "test",
            lastActiveMembers: channelMembers
        )

        let channelActions = ChannelAction.defaultActions(
            for: SupportedMoreChannelActionsOptions(
                channel: channel,
                onDismiss: {},
                onError: { _ in }
            )
        )

        let moreActionsVM = MoreChannelActionsViewModel(
            channel: channel,
            channelActions: channelActions
        )

        return moreActionsVM
    }
}
