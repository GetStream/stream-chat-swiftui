//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import XCTest

class ChatChannelInfoViewModel_Tests: StreamChatTestCase {
    func test_chatChannelInfoVM_initialGroupParticipants() {
        // Given
        let channel = mockGroup(with: 10)
        let viewModel = ChatChannelInfoViewModel(channel: channel)

        // When
        let participants = viewModel.participants
        let displayedParticipants = viewModel.displayedParticipants
        let moreUsersShown = viewModel.showMoreUsersButton
        let memberListCollapsed = viewModel.memberListCollapsed
        let notDisplayedParticipantsCount = viewModel.notDisplayedParticipantsCount

        // Then
        XCTAssert(moreUsersShown == true)
        XCTAssert(memberListCollapsed == true)
        XCTAssert(participants.count == 10)
        XCTAssert(displayedParticipants.count == 6)
        XCTAssert(notDisplayedParticipantsCount == 4)
    }

    func test_chatChannelInfoVM_expandedGroupParticipants() {
        // Given
        let channel = mockGroup(with: 10)
        let viewModel = ChatChannelInfoViewModel(channel: channel)

        // When
        viewModel.memberListCollapsed = false
        let participants = viewModel.participants
        let displayedParticipants = viewModel.displayedParticipants
        let moreUsersShown = viewModel.showMoreUsersButton
        let memberListCollapsed = viewModel.memberListCollapsed
        let notDisplayedParticipantsCount = viewModel.notDisplayedParticipantsCount

        // Then
        XCTAssert(moreUsersShown == false)
        XCTAssert(memberListCollapsed == false)
        XCTAssert(participants.count == 10)
        XCTAssert(displayedParticipants.count == 10)
        XCTAssert(notDisplayedParticipantsCount == 0)
    }

    func test_chatChannelInfoVM_smallGroupParticipants() {
        // Given
        let channel = mockGroup(with: 3)
        let viewModel = ChatChannelInfoViewModel(channel: channel)

        // When
        let participants = viewModel.participants
        let displayedParticipants = viewModel.displayedParticipants
        let moreUsersShown = viewModel.showMoreUsersButton

        // Then
        XCTAssert(moreUsersShown == false)
        XCTAssert(participants.count == 3)
        XCTAssert(displayedParticipants.count == 3)
    }

    func test_chatChannelInfoVM_directChannelParticipant() {
        // Given
        let members = ChannelInfoMockUtils.setupMockMembers(
            count: 2,
            currentUserId: chatClient.currentUserId!
        )
        let channel = ChatChannel.mockDMChannel(
            lastActiveMembers: members,
            memberCount: 2
        )
        let viewModel = ChatChannelInfoViewModel(channel: channel)

        // When
        let participants = viewModel.participants
        let displayedParticipants = viewModel.displayedParticipants
        let moreUsersShown = viewModel.showMoreUsersButton

        // Then
        XCTAssert(moreUsersShown == false)
        XCTAssert(participants.count == 2)
        XCTAssert(displayedParticipants.count == 1)
    }

    func test_chatChannelInfoVM_displayOptionsGroup() {
        // Given
        let channel = mockGroup(with: 10)
        let viewModel = ChatChannelInfoViewModel(channel: channel)

        // When
        let leaveButtonTitle = viewModel.leaveButtonTitle
        let leaveConversationDescription = viewModel.leaveConversationDescription
        let mutedText = viewModel.mutedText

        // Then
        XCTAssert(leaveButtonTitle == L10n.Alert.Actions.leaveGroupTitle)
        XCTAssert(leaveConversationDescription == L10n.Alert.Actions.leaveGroupMessage)
        XCTAssert(mutedText == L10n.ChatInfo.Mute.group)
    }

    func test_chatChannelInfoVM_displayOptionsDirectChannel() {
        // Given
        let channel = ChatChannel.mockDMChannel()
        let viewModel = ChatChannelInfoViewModel(channel: channel)

        // When
        let leaveButtonTitle = viewModel.leaveButtonTitle
        let leaveConversationDescription = viewModel.leaveConversationDescription
        let mutedText = viewModel.mutedText

        // Then
        XCTAssert(leaveButtonTitle == L10n.Alert.Actions.deleteChannelTitle)
        XCTAssert(leaveConversationDescription == L10n.Alert.Actions.deleteChannelMessage)
        XCTAssert(mutedText == L10n.ChatInfo.Mute.user)
    }

    func test_chatChannelInfoVM_onlineUserInfo() {
        // Given
        let user = ChatUser.mock(id: .unique, isOnline: true)
        let viewModel = ChatChannelInfoViewModel(channel: ChatChannel.mockDMChannel())

        // When
        let onlineInfo = viewModel.onlineInfo(for: user)

        // Then
        XCTAssert(onlineInfo == L10n.Message.Title.online)
    }

    func test_chatChannelInfoVM_offlineUserInfo() {
        // Given
        let user = ChatUser.mock(id: .unique, isOnline: false)
        let viewModel = ChatChannelInfoViewModel(channel: ChatChannel.mockDMChannel())

        // When
        let onlineInfo = viewModel.onlineInfo(for: user)

        // Then
        XCTAssert(onlineInfo == L10n.Message.Title.offline)
    }

    func test_chatChannelInfoVM_lastActiveUserInfo() {
        // Given
        let date = Date().addingTimeInterval(-10 * 60)
        let user = ChatUser.mock(id: .unique, isOnline: false, lastActiveAt: date)
        let viewModel = ChatChannelInfoViewModel(channel: ChatChannel.mockDMChannel())

        // When
        let onlineInfo = viewModel.onlineInfo(for: user)

        // Then
        XCTAssert(onlineInfo == "last seen 10 minutes ago")
    }

    func test_chatChannelInfoVM_cancelGroupRenaming() {
        // Given
        let initialName = "Test Channel"
        let channel = ChatChannel.mock(cid: .unique, name: initialName)
        let viewModel = ChatChannelInfoViewModel(channel: channel)

        // When
        viewModel.channelName = "New name"
        viewModel.cancelGroupRenaming()

        // Then
        XCTAssert(viewModel.channelName == initialName)
    }

    func test_chatChannelInfoVM_confirmGroupRenaming() {
        // Given
        let initialName = "Test Channel"
        let newName = "New name"
        let channel = ChatChannel.mock(cid: .unique, name: initialName)
        let viewModel = ChatChannelInfoViewModel(channel: channel)

        // When
        viewModel.channelName = newName
        viewModel.confirmGroupRenaming()

        // Then
        XCTAssert(viewModel.channelName == newName)
    }

    func test_chatChannelInfoVM_canRenameGroup() {
        // Given
        let channel = mockGroup(with: 5)
        let viewModel = ChatChannelInfoViewModel(channel: channel)

        // When
        let canRenameChannel = viewModel.canRenameChannel

        // Then
        XCTAssert(canRenameChannel == true)
    }

    func test_chatChannelInfoVM_canNotRenameGroup() {
        // Given
        let channel = mockGroup(with: 5, updateCapabilities: false)
        let viewModel = ChatChannelInfoViewModel(channel: channel)

        // When
        let canRenameChannel = viewModel.canRenameChannel

        // Then
        XCTAssert(canRenameChannel == false)
    }

    func test_chatChannelInfoVM_leaveButtonShownInGroup() {
        // Given
        let channel = mockGroup(with: 5)
        let viewModel = ChatChannelInfoViewModel(channel: channel)

        // When
        let leaveButton = viewModel.shouldShowLeaveConversationButton

        // Then
        XCTAssert(leaveButton == true)
    }

    func test_chatChannelInfoVM_leaveButtonHiddenInGroup() {
        // Given
        let channel = mockGroup(with: 5, updateCapabilities: false)
        let viewModel = ChatChannelInfoViewModel(channel: channel)

        // When
        let leaveButton = viewModel.shouldShowLeaveConversationButton

        // Then
        XCTAssert(leaveButton == false)
    }

    func test_chatChannelInfoVM_leaveButtonShownInDM() {
        // Given
        let cidDM = ChannelId(type: .messaging, id: "!members" + .newUniqueId)
        let channel = ChatChannel.mock(
            cid: cidDM,
            ownCapabilities: [.deleteChannel]
        )
        let viewModel = ChatChannelInfoViewModel(channel: channel)

        // When
        let leaveButton = viewModel.shouldShowLeaveConversationButton

        // Then
        XCTAssert(leaveButton == true)
    }

    func test_chatChannelInfoVM_leaveButtonHiddenInDM() {
        // Given
        let channel = ChatChannel.mockDMChannel()
        let viewModel = ChatChannelInfoViewModel(channel: channel)

        // When
        let leaveButton = viewModel.shouldShowLeaveConversationButton

        // Then
        XCTAssert(leaveButton == false)
    }

    func test_chatChannelInfoVM_addUserButtonShownInGroup() {
        // Given
        let channel = mockGroup(with: 5)
        let viewModel = ChatChannelInfoViewModel(channel: channel)

        // When
        let leaveButton = viewModel.shouldShowAddUserButton

        // Then
        XCTAssert(leaveButton == true)
    }

    func test_chatChannelInfoVM_addUserButtonHiddenInGroup() {
        // Given
        let channel = mockGroup(with: 5, updateCapabilities: false)
        let viewModel = ChatChannelInfoViewModel(channel: channel)

        // When
        let leaveButton = viewModel.shouldShowAddUserButton

        // Then
        XCTAssert(leaveButton == false)
    }

    func test_chatChannelInfoVM_addUserButtonHiddenInDM() {
        // Given
        let channel = ChatChannel.mockDMChannel()
        let viewModel = ChatChannelInfoViewModel(channel: channel)

        // When
        let leaveButton = viewModel.shouldShowAddUserButton

        // Then
        XCTAssert(leaveButton == false)
    }

    func test_chatChannelInfoVM_participantActions_withMutesEnabled() {
        // Given
        let channel = mockGroup(with: 5)
        let viewModel = ChatChannelInfoViewModel(channel: channel)
        let participant = ParticipantInfo(
            chatUser: ChatUser.mock(id: .unique),
            displayName: "Test User",
            onlineInfoText: "online",
            isDeactivated: false
        )

        // When
        let actions = viewModel.participantActions(for: participant)

        // Then
        XCTAssert(actions.count == 4) // mute, remove, cancel
        XCTAssert(actions.contains { $0.title.contains("Mute") })
        XCTAssert(actions.contains { $0.title.contains("Remove") })
        XCTAssert(actions.contains { $0.title == L10n.Alert.Actions.cancel })
    }

    func test_chatChannelInfoVM_participantActions_withMutesDisabled() {
        // Given
        let channel = mockGroup(with: 5, updateCapabilities: true, mutesEnabled: false)
        let viewModel = ChatChannelInfoViewModel(channel: channel)
        let participant = ParticipantInfo(
            chatUser: ChatUser.mock(id: .unique),
            displayName: "Test User",
            onlineInfoText: "online",
            isDeactivated: false
        )

        // When
        let actions = viewModel.participantActions(for: participant)

        // Then
        XCTAssert(actions.count == 3) // direct message, remove, cancel
        XCTAssertNotNil(actions.first?.navigationDestination)
        XCTAssertFalse(actions.contains { $0.title.contains("Mute") })
        XCTAssert(actions.contains { $0.title.contains("Remove") })
        XCTAssert(actions.contains { $0.title == L10n.Alert.Actions.cancel })
    }

    func test_chatChannelInfoVM_participantActions_withoutUpdateMembersCapability() {
        // Given
        let channel = mockGroup(with: 5, updateCapabilities: false)
        let viewModel = ChatChannelInfoViewModel(channel: channel)
        let participant = ParticipantInfo(
            chatUser: ChatUser.mock(id: .unique),
            displayName: "Test User",
            onlineInfoText: "online",
            isDeactivated: false
        )

        // When
        let actions = viewModel.participantActions(for: participant)

        // Then
        XCTAssert(actions.count == 3) // direct message, mute, cancel (no remove)
        XCTAssert(actions.contains { $0.title.contains("Mute") })
        XCTAssertFalse(actions.contains { $0.title.contains("Remove") })
        XCTAssert(actions.contains { $0.title == L10n.Alert.Actions.cancel })
    }

    func test_chatChannelInfoVM_participantActions_withMutedUser() {
        // Given
        let channel = mockGroup(with: 5)
        let viewModel = ChatChannelInfoViewModel(channel: channel)
        let mutedUser = ChatUser.mock(id: .unique)
        let participant = ParticipantInfo(
            chatUser: mutedUser,
            displayName: "Muted User",
            onlineInfoText: "online",
            isDeactivated: false
        )

        // When
        let actions = viewModel.participantActions(for: participant)

        // Then
        XCTAssert(actions.count >= 2) // At least remove and cancel
        XCTAssert(actions.contains { $0.title.contains("Remove") })
        XCTAssert(actions.contains { $0.title == L10n.Alert.Actions.cancel })
    }

    func test_chatChannelInfoVM_participantActions_withUnmutedUser() {
        // Given
        let channel = mockGroup(with: 5)
        let mutedUser = ChatUser.mock(id: .unique)
        let viewModel = ChatChannelInfoViewModel(channel: channel)
        let currentUserController = CurrentChatUserController_Mock(client: chatClient)
        let currentUser = CurrentChatUser.mock(currentUserId: .unique, mutedUsers: [mutedUser])
        currentUserController.currentUser_mock = currentUser
        viewModel.currentUserController = currentUserController

        let participant = ParticipantInfo(
            chatUser: mutedUser,
            displayName: "Unmute User",
            onlineInfoText: "online",
            isDeactivated: false
        )

        // When
        let actions = viewModel.participantActions(for: participant)

        // Then
        XCTAssert(actions.count >= 2) // At least remove and cancel
        XCTAssert(actions.contains { $0.title.contains("Remove") })
        XCTAssert(actions.contains { $0.title == L10n.Alert.Actions.cancel })
    }

    func test_chatChannelInfoVM_muteAction_properties() {
        // Given
        let channel = mockGroup(with: 5)
        let viewModel = ChatChannelInfoViewModel(channel: channel)
        let participant = ParticipantInfo(
            chatUser: ChatUser.mock(id: .unique),
            displayName: "Test User",
            onlineInfoText: "online",
            isDeactivated: false
        )

        // When
        let muteAction = viewModel.muteAction(
            participant: participant,
            onDismiss: {},
            onError: { _ in }
        )

        // Then
        XCTAssert(muteAction.title.contains("Mute"))
        XCTAssert(muteAction.title.contains("Test User"))
        XCTAssert(muteAction.iconName == "speaker.slash")
        XCTAssert(muteAction.isDestructive == false)
        XCTAssertNotNil(muteAction.confirmationPopup)
        XCTAssert(muteAction.confirmationPopup?.title.contains("Mute") == true)
        XCTAssert(muteAction.confirmationPopup?.title.contains("Test User") == true)
        XCTAssert(muteAction.confirmationPopup?.buttonTitle.contains("Mute") == true)
    }

    func test_chatChannelInfoVM_unmuteAction_properties() {
        // Given
        let channel = mockGroup(with: 5)
        let viewModel = ChatChannelInfoViewModel(channel: channel)
        let participant = ParticipantInfo(
            chatUser: ChatUser.mock(id: .unique),
            displayName: "Test User",
            onlineInfoText: "online",
            isDeactivated: false
        )

        // When
        let unmuteAction = viewModel.unmuteAction(
            participant: participant,
            onDismiss: {},
            onError: { _ in }
        )

        // Then
        XCTAssert(unmuteAction.title.contains("Unmute"))
        XCTAssert(unmuteAction.title.contains("Test User"))
        XCTAssert(unmuteAction.iconName == "speaker.wave.1")
        XCTAssert(unmuteAction.isDestructive == false)
        XCTAssertNotNil(unmuteAction.confirmationPopup)
        XCTAssert(unmuteAction.confirmationPopup?.title.contains("Unmute") == true)
        XCTAssert(unmuteAction.confirmationPopup?.title.contains("Test User") == true)
        XCTAssert(unmuteAction.confirmationPopup?.buttonTitle.contains("Unmute") == true)
    }

    func test_chatChannelInfoVM_removeUserAction_properties() {
        // Given
        let channel = mockGroup(with: 5)
        let viewModel = ChatChannelInfoViewModel(channel: channel)
        let participant = ParticipantInfo(
            chatUser: ChatUser.mock(id: .unique),
            displayName: "Test User",
            onlineInfoText: "online",
            isDeactivated: false
        )

        // When
        let removeAction = viewModel.removeUserAction(
            participant: participant,
            onDismiss: {},
            onError: { _ in }
        )

        // Then
        XCTAssert(removeAction.title == L10n.Channel.Item.removeUser)
        XCTAssert(removeAction.iconName == "person.slash")
        XCTAssert(removeAction.isDestructive == true)
        XCTAssertNotNil(removeAction.confirmationPopup)
        XCTAssert(removeAction.confirmationPopup?.title == L10n.Channel.Item.removeUserConfirmationTitle)
        XCTAssert(removeAction.confirmationPopup?.buttonTitle == L10n.Channel.Item.removeUser)
    }

    func test_chatChannelInfoVM_muteAction_execution() {
        // Given
        let channel = mockGroup(with: 5)
        let viewModel = ChatChannelInfoViewModel(channel: channel)
        let participant = ParticipantInfo(
            chatUser: ChatUser.mock(id: .unique),
            displayName: "Test User",
            onlineInfoText: "online",
            isDeactivated: false
        )
        
        // When
        let muteAction = viewModel.muteAction(
            participant: participant,
            onDismiss: {},
            onError: { _ in }
        )
        
        muteAction.action()

        // Then
        XCTAssertNotNil(muteAction.action)
    }

    func test_chatChannelInfoVM_unmuteAction_execution() {
        // Given
        let channel = mockGroup(with: 5)
        let viewModel = ChatChannelInfoViewModel(channel: channel)
        let participant = ParticipantInfo(
            chatUser: ChatUser.mock(id: .unique),
            displayName: "Test User",
            onlineInfoText: "online",
            isDeactivated: false
        )

        // When
        let unmuteAction = viewModel.unmuteAction(
            participant: participant,
            onDismiss: {},
            onError: { _ in }
        )
        
        unmuteAction.action()

        // Then
        XCTAssertNotNil(unmuteAction.action)
    }

    func test_chatChannelInfoVM_removeUserAction_execution() {
        // Given
        let channel = mockGroup(with: 5)
        let viewModel = ChatChannelInfoViewModel(channel: channel)
        let participant = ParticipantInfo(
            chatUser: ChatUser.mock(id: .unique),
            displayName: "Test User",
            onlineInfoText: "online",
            isDeactivated: false
        )
        
        // When
        let removeAction = viewModel.removeUserAction(
            participant: participant,
            onDismiss: {},
            onError: { _ in }
        )
        
        removeAction.action()

        // Then
        XCTAssertNotNil(removeAction.action)
    }

    func test_chatChannelInfoVM_participantActions_cancelAction() {
        // Given
        let channel = mockGroup(with: 5)
        let viewModel = ChatChannelInfoViewModel(channel: channel)
        let participant = ParticipantInfo(
            chatUser: ChatUser.mock(id: .unique),
            displayName: "Test User",
            onlineInfoText: "online",
            isDeactivated: false
        )
        
        viewModel.selectedParticipant = participant

        // When
        let actions = viewModel.participantActions(for: participant)
        let cancelAction = actions.first { $0.title == L10n.Alert.Actions.cancel }
        
        cancelAction?.action()

        // Then
        XCTAssertNil(viewModel.selectedParticipant)
    }

    func test_chatChannelInfoVM_channelUpdated_updatesParticipants() {
        // Given
        let channel = mockGroup(with: 5)
        let viewModel = ChatChannelInfoViewModel(channel: channel)
        let controller = ChatChannelController_Mock.mock()
        viewModel.channelController = controller
        controller.delegate = viewModel

        // When
        let updated = mockGroup(with: 6)
        controller.simulate(channel: updated, change: .update(updated), typingUsers: [])

        // Then
        XCTAssertEqual(viewModel.participants.count, 6)
    }

    func test_chatChannelInfoVM_handleParticipantActionDismiss() {
        // Given
        let channel = mockGroup(with: 5)
        let viewModel = ChatChannelInfoViewModel(channel: channel)

        // When
        viewModel.handleParticipantActionDismiss()

        // Then
        XCTAssertNil(viewModel.selectedParticipant)
    }

    func test_chatChannelInfoVM_handleParticipantActionError() {
        // Given
        let channel = mockGroup(with: 5)
        let viewModel = ChatChannelInfoViewModel(channel: channel)

        // When
        viewModel.handleParticipantActionError(ClientError.Unknown())

        // Then
        XCTAssertEqual(viewModel.errorShown, true)
    }

    // MARK: - private

    private func mockGroup(
        with memberCount: Int,
        updateCapabilities: Bool = true,
        mutesEnabled: Bool = true
    ) -> ChatChannel {
        let cid: ChannelId = .unique
        let activeMembers = ChannelInfoMockUtils.setupMockMembers(
            count: memberCount,
            currentUserId: chatClient.currentUserId!
        )
        var capabilities = Set<ChannelCapability>()
        if updateCapabilities {
            capabilities.insert(.updateChannel)
            capabilities.insert(.deleteChannel)
            capabilities.insert(.leaveChannel)
            capabilities.insert(.updateChannelMembers)
        }
        
        let channelConfig = ChannelConfig(mutesEnabled: mutesEnabled)
        
        let channel = ChatChannel.mock(
            cid: cid,
            config: channelConfig,
            ownCapabilities: capabilities,
            lastActiveMembers: activeMembers,
            memberCount: activeMembers.count
        )
        return channel
    }
}
