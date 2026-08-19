//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import XCTest

@MainActor class ChatChannelInfoViewModel_Tests: StreamChatTestCase {
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
        XCTAssert(displayedParticipants.count == 5)
        XCTAssert(notDisplayedParticipantsCount == 5)
    }

    func test_chatChannelInfoVM_groupParticipantsCappedAtFive() {
        // Given - displayedParticipants is always capped at 5 for groups;
        // the full list is shown via the member list sheet (memberListSheetShown).
        let channel = mockGroup(with: 10)
        let viewModel = ChatChannelInfoViewModel(channel: channel)

        // When - memberListCollapsed toggle no longer affects displayedParticipants
        viewModel.memberListCollapsed = false
        let displayedParticipants = viewModel.displayedParticipants
        let moreUsersShown = viewModel.showMoreUsersButton

        // Then
        XCTAssert(displayedParticipants.count == 5)
        XCTAssert(moreUsersShown == true)
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
        let viewModel = ChatChannelInfoViewModel(channel: mockDirectMessage())

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
        let leaveButton = viewModel.shouldShowAddMemberButton

        // Then
        XCTAssert(leaveButton == true)
    }

    func test_chatChannelInfoVM_addUserButtonHiddenInGroup() {
        // Given
        let channel = mockGroup(with: 5, updateCapabilities: false)
        let viewModel = ChatChannelInfoViewModel(channel: channel)

        // When
        let leaveButton = viewModel.shouldShowAddMemberButton

        // Then
        XCTAssert(leaveButton == false)
    }

    func test_chatChannelInfoVM_addUserButtonHiddenInDM() {
        // Given
        let channel = ChatChannel.mockDMChannel()
        let viewModel = ChatChannelInfoViewModel(channel: channel)

        // When
        let leaveButton = viewModel.shouldShowAddMemberButton

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
        XCTAssert(actions.count == 4) // direct message, mute, block, remove
        XCTAssert(actions.contains { $0.title.contains("Mute") })
        XCTAssert(actions.contains { $0.title.contains("Remove") })
        XCTAssert(actions.contains { $0.title == L10n.Alert.Actions.blockUser })
        XCTAssertFalse(actions.contains { $0.title == L10n.Alert.Actions.cancel })
    }

    func test_chatChannelInfoVM_directMessageChannelController_passesTeam() {
        // Given
        let channel = mockGroup(with: 5, team: "red")
        let viewModel = ChatChannelInfoViewModel(channel: channel)
        let participant = ParticipantInfo(
            chatUser: ChatUser.mock(id: .unique),
            displayName: "Test User",
            onlineInfoText: "online",
            isDeactivated: false
        )

        // When
        let controller = viewModel.directMessageChannelController(for: participant)

        // Then
        XCTAssertEqual(controller?.channelQuery.channelPayload?.team, "red")
    }

    func test_chatChannelInfoVM_directMessageChannelController_withoutTeam() {
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
        let controller = viewModel.directMessageChannelController(for: participant)

        // Then
        XCTAssertNotNil(controller)
        XCTAssertNotNil(controller?.channelQuery.channelPayload)
        XCTAssertNil(controller?.channelQuery.channelPayload?.team)
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
        XCTAssert(actions.count == 3) // direct message, block, remove
        XCTAssertNotNil(actions.first?.navigationDestination)
        XCTAssertFalse(actions.contains { $0.title.contains("Mute") })
        XCTAssert(actions.contains { $0.title.contains("Remove") })
        XCTAssert(actions.contains { $0.title == L10n.Alert.Actions.blockUser })
        XCTAssertFalse(actions.contains { $0.title == L10n.Alert.Actions.cancel })
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
        XCTAssert(actions.count == 3) // direct message, mute, block (no remove)
        XCTAssert(actions.contains { $0.title.contains("Mute") })
        XCTAssertFalse(actions.contains { $0.title.contains("Remove") })
        XCTAssert(actions.contains { $0.title == L10n.Alert.Actions.blockUser })
        XCTAssertFalse(actions.contains { $0.title == L10n.Alert.Actions.cancel })
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
        XCTAssert(actions.count >= 2) // At least block and remove
        XCTAssert(actions.contains { $0.title.contains("Remove") })
        XCTAssert(actions.contains { $0.title == L10n.Alert.Actions.blockUser })
        XCTAssertFalse(actions.contains { $0.title == L10n.Alert.Actions.cancel })
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
        XCTAssert(actions.count >= 2) // At least block and remove
        XCTAssert(actions.contains { $0.title.contains("Remove") })
        XCTAssert(actions.contains { $0.title == L10n.Alert.Actions.blockUser })
        XCTAssertFalse(actions.contains { $0.title == L10n.Alert.Actions.cancel })
    }

    func test_chatChannelInfoVM_participantsMutedState_whenUserIsMuted() {
        // Given
        let members = ChannelInfoMockUtils.setupMockMembers(
            count: 3,
            currentUserId: chatClient.currentUserId!
        )
        let channel = ChatChannel.mock(
            cid: .unique,
            lastActiveMembers: members,
            memberCount: members.count
        )
        let viewModel = ChatChannelInfoViewModel(channel: channel)
        let mutedMember = members[1]
        XCTAssertFalse(viewModel.participants.contains { $0.isMuted })

        // When
        let currentUserController = mockCurrentUserController(mutedUserIds: [mutedMember.id])
        viewModel.currentUserController = currentUserController
        simulateCurrentUserChange(for: viewModel, controller: currentUserController)

        // Then
        XCTAssert(viewModel.participants.first { $0.id == mutedMember.id }?.isMuted == true)
        XCTAssert(viewModel.participants.filter(\.isMuted).count == 1)
    }

    func test_chatChannelInfoVM_participantsMutedState_whenUserIsUnmuted() {
        // Given
        let members = ChannelInfoMockUtils.setupMockMembers(
            count: 3,
            currentUserId: chatClient.currentUserId!
        )
        let channel = ChatChannel.mock(
            cid: .unique,
            lastActiveMembers: members,
            memberCount: members.count
        )
        let viewModel = ChatChannelInfoViewModel(channel: channel)
        let mutedMember = members[1]
        let currentUserController = mockCurrentUserController(mutedUserIds: [mutedMember.id])
        viewModel.currentUserController = currentUserController
        simulateCurrentUserChange(for: viewModel, controller: currentUserController)

        // When
        currentUserController.currentUser_mock = .mock(currentUserId: chatClient.currentUserId!)
        simulateCurrentUserChange(for: viewModel, controller: currentUserController)

        // Then
        XCTAssertFalse(viewModel.participants.contains { $0.isMuted })
    }

    func test_chatChannelInfoVM_participantActions_mutedParticipant_showsUnmuteAction() {
        // Given
        let channel = mockGroup(with: 5)
        let viewModel = ChatChannelInfoViewModel(channel: channel)
        let member = ChatChannelMember.mock(id: .unique, name: "Muted User")
        viewModel.currentUserController = mockCurrentUserController(mutedUserIds: [member.id])
        let participant = ParticipantInfo(
            chatUser: member,
            displayName: "Muted User",
            onlineInfoText: "online",
            isDeactivated: false,
            isMuted: true
        )

        // When
        let actions = viewModel.participantActions(for: participant)

        // Then
        XCTAssert(actions.contains { $0.title == "\(L10n.Channel.Item.unmute) Muted User" })
        XCTAssertFalse(actions.contains { $0.title == "\(L10n.Channel.Item.mute) Muted User" })
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

    func test_chatChannelInfoVM_participantActions_noCancelAction() {
        // The cancel action was removed; dismissal is handled by the sheet/popup UI.
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
        XCTAssertFalse(actions.contains { $0.title == L10n.Alert.Actions.cancel })
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

    // MARK: - allParticipants / displayedParticipants

    func test_chatChannelInfoVM_allParticipants_excludesDeactivated() {
        // Given - group of 5 members where member at index 2 is deactivated
        let cid: ChannelId = .unique
        let members = ChannelInfoMockUtils.setupMockMembers(
            count: 5,
            currentUserId: chatClient.currentUserId!,
            deactivatedUserIndexes: [2]
        )
        let channel = ChatChannel.mock(
            cid: cid,
            lastActiveMembers: members,
            memberCount: members.count
        )
        let viewModel = ChatChannelInfoViewModel(channel: channel)

        // When
        let all = viewModel.allParticipants

        // Then
        XCTAssertEqual(all.count, 4)
        XCTAssertFalse(all.contains { $0.isDeactivated })
    }

    func test_chatChannelInfoVM_displayedParticipants_groupCappedAtFive() {
        // Given
        let channel = mockGroup(with: 10)
        let viewModel = ChatChannelInfoViewModel(channel: channel)

        // When
        let displayed = viewModel.displayedParticipants

        // Then - always capped at 5 for groups; full list shown via member list sheet
        XCTAssertEqual(displayed.count, 5)
    }

    // MARK: - New @Published properties initial state

    func test_chatChannelInfoVM_newPublishedProperties_initialFalse() {
        // Given
        let channel = mockGroup(with: 3)
        let viewModel = ChatChannelInfoViewModel(channel: channel)

        // Then
        XCTAssertFalse(viewModel.memberListSheetShown)
        XCTAssertFalse(viewModel.editGroupShown)
        XCTAssertFalse(viewModel.isUploadingGroupAvatar)
    }

    // MARK: - Current user display name

    func test_chatChannelInfoVM_currentUserDisplayName_isYou() {
        // Given
        let channel = mockGroup(with: 3)
        let viewModel = ChatChannelInfoViewModel(channel: channel)

        // When - first member is always the current user (index 0 in setupMockMembers)
        let currentUserParticipant = viewModel.participants.first { $0.id == chatClient.currentUserId }

        // Then
        XCTAssertEqual(currentUserParticipant?.displayName, L10n.Channel.Item.you)
    }

    func test_chatChannelInfoVM_otherMemberDisplayName_isNotYou() {
        // Given
        let channel = mockGroup(with: 3)
        let viewModel = ChatChannelInfoViewModel(channel: channel)

        // When - other members should not have "You" as display name
        let otherParticipants = viewModel.participants.filter { $0.id != chatClient.currentUserId }

        // Then
        XCTAssertFalse(otherParticipants.contains { $0.displayName == L10n.Channel.Item.you })
    }

    // MARK: - shouldShowBlockUserButton

    func test_chatChannelInfoVM_shouldShowBlockUserButton_falseForGroup() {
        // Given
        let channel = mockGroup(with: 5)
        let viewModel = ChatChannelInfoViewModel(channel: channel)

        // Then - block button only shown in 1-on-1 DMs
        XCTAssertFalse(viewModel.shouldShowBlockUserButton)
    }

    func test_chatChannelInfoVM_shouldShowBlockUserButton_trueForSingleMemberDM() {
        // Given
        let viewModel = ChatChannelInfoViewModel(channel: mockDirectMessage())

        // Then - showSingleMemberDMView == true → block button shown
        XCTAssertTrue(viewModel.shouldShowBlockUserButton)
    }

    func test_chatChannelInfoVM_shouldShowBlockUserButton_falseForMultiPersonDM() {
        // Given - DM channel with 4 members (showSingleMemberDMView == false)
        let members = ChannelInfoMockUtils.setupMockMembers(
            count: 4,
            currentUserId: chatClient.currentUserId!
        )
        let channel = ChatChannel.mockDMChannel(
            lastActiveMembers: members,
            memberCount: 4
        )
        let viewModel = ChatChannelInfoViewModel(channel: channel)

        // Then - more than 2 members → showSingleMemberDMView false → block hidden
        XCTAssertFalse(viewModel.shouldShowBlockUserButton)
    }

    // MARK: - shouldShowLeaveConversationButton for multi-person DM

    func test_chatChannelInfoVM_leaveButtonShownInMultiPersonDM() {
        // Given - DM channel (cid with "!members" prefix) with 4 members and leaveChannel capability
        let cidDM = ChannelId(type: .messaging, id: "!members" + .newUniqueId)
        let members = ChannelInfoMockUtils.setupMockMembers(
            count: 4,
            currentUserId: chatClient.currentUserId!
        )
        let channel = ChatChannel.mock(
            cid: cidDM,
            ownCapabilities: [.leaveChannel],
            lastActiveMembers: members,
            memberCount: members.count
        )
        let viewModel = ChatChannelInfoViewModel(channel: channel)

        // Then - multi-person DM uses leaveChannel capability for leave button
        XCTAssertTrue(viewModel.shouldShowLeaveConversationButton)
    }

    // MARK: - leaveButtonTitle / leaveConversationDescription for multi-person DM

    func test_chatChannelInfoVM_displayOptions_multiPersonDM() {
        // Given - DM channel with 4 members (treated like a group for leave/title purposes)
        let members = ChannelInfoMockUtils.setupMockMembers(
            count: 4,
            currentUserId: chatClient.currentUserId!
        )
        let channel = ChatChannel.mockDMChannel(
            lastActiveMembers: members,
            memberCount: 4
        )
        let viewModel = ChatChannelInfoViewModel(channel: channel)

        // When
        let leaveButtonTitle = viewModel.leaveButtonTitle
        let leaveConversationDescription = viewModel.leaveConversationDescription

        // Then - multi-person DM uses group leave text (not delete channel text)
        XCTAssertEqual(leaveButtonTitle, L10n.Alert.Actions.leaveGroupTitle)
        XCTAssertEqual(leaveConversationDescription, L10n.Alert.Actions.leaveGroupMessage)
    }

    // MARK: - participantActions for current user

    func test_chatChannelInfoVM_participantActions_currentUserInGroup_returnsLeaveGroup() {
        // Given
        let channel = mockGroup(with: 5)
        let viewModel = ChatChannelInfoViewModel(channel: channel)
        let currentUserParticipant = viewModel.participants.first { $0.id == chatClient.currentUserId }!

        // When
        let actions = viewModel.participantActions(for: currentUserParticipant)

        // Then - current user in group gets only the leave group action
        XCTAssertEqual(actions.count, 1)
        XCTAssertEqual(actions.first?.title, L10n.Alert.Actions.leaveGroupTitle)
    }

    func test_chatChannelInfoVM_participantActions_currentUserInSingleDM_returnsEmpty() {
        // Given
        let viewModel = ChatChannelInfoViewModel(channel: mockDirectMessage())
        let currentUserParticipant = viewModel.participants.first { $0.id == chatClient.currentUserId }!

        // When
        let actions = viewModel.participantActions(for: currentUserParticipant)

        // Then - current user in 1-on-1 DM gets no actions
        XCTAssertTrue(actions.isEmpty)
    }

    // MARK: - participantActions includes correct block/leave for channel type

    func test_chatChannelInfoVM_participantActions_groupIncludesBlock() {
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

        // Then - tapping any participant shows Block, not Leave Group
        XCTAssertTrue(actions.contains { $0.title == L10n.Alert.Actions.blockUser })
        XCTAssertFalse(actions.contains { $0.title == L10n.Alert.Actions.leaveGroupTitle })
    }

    func test_chatChannelInfoVM_participantActions_singleDMIncludesBlock() {
        // Given
        let members = ChannelInfoMockUtils.setupMockMembers(
            count: 2,
            currentUserId: chatClient.currentUserId!
        )
        let channel = ChatChannel.mockDMChannel(
            config: ChannelConfig(mutesEnabled: false),
            lastActiveMembers: members,
            memberCount: 2
        )
        let viewModel = ChatChannelInfoViewModel(channel: channel)
        let otherParticipant = viewModel.participants.first { $0.id != chatClient.currentUserId }!

        // When
        let actions = viewModel.participantActions(for: otherParticipant)

        // Then - 1-on-1 DM shows Block, not Leave Group
        XCTAssertTrue(actions.contains { $0.title == L10n.Alert.Actions.blockUser })
        XCTAssertFalse(actions.contains { $0.title == L10n.Alert.Actions.leaveGroupTitle })
    }

    // MARK: - blockParticipantAction properties

    func test_chatChannelInfoVM_blockParticipantAction_properties() {
        // Given
        let viewModel = ChatChannelInfoViewModel(channel: mockDirectMessage())
        let otherParticipant = viewModel.participants.first { $0.id != chatClient.currentUserId }!

        // When
        let blockAction = viewModel.blockParticipantAction(
            participant: otherParticipant,
            onDismiss: {},
            onError: { _ in }
        )

        // Then
        XCTAssertEqual(blockAction.title, L10n.Alert.Actions.blockUser)
        XCTAssertEqual(blockAction.iconName, "nosign")
        XCTAssertFalse(blockAction.isDestructive)
        XCTAssertNotNil(blockAction.confirmationPopup)
        XCTAssertEqual(blockAction.confirmationPopup?.title, L10n.Alert.Actions.blockUser)
        XCTAssertEqual(blockAction.confirmationPopup?.buttonTitle, L10n.Alert.Actions.blockUser)
    }

    // MARK: - leaveGroupAction properties

    func test_chatChannelInfoVM_leaveGroupAction_properties() {
        // Given
        let channel = mockGroup(with: 5)
        let viewModel = ChatChannelInfoViewModel(channel: channel)

        // When
        let leaveAction = viewModel.leaveGroupAction(onDismiss: {}, onError: { _ in })

        // Then
        XCTAssertEqual(leaveAction.title, L10n.Alert.Actions.leaveGroupTitle)
        XCTAssertEqual(leaveAction.iconName, "rectangle.portrait.and.arrow.right")
        XCTAssertTrue(leaveAction.isDestructive)
        XCTAssertNotNil(leaveAction.confirmationPopup)
        XCTAssertEqual(leaveAction.confirmationPopup?.title, L10n.Alert.Actions.leaveGroupTitle)
        XCTAssertEqual(leaveAction.confirmationPopup?.buttonTitle, L10n.Alert.Actions.leaveGroupButton)
    }

    // MARK: - shouldShowActionsCard

    func test_chatChannelInfoVM_shouldShowActionsCard_whenAnyActionAvailable_returnsTrue() {
        // Given - only the leave capability
        let channel = mockGroup(with: 5, capabilities: [.leaveChannel])
        let viewModel = ChatChannelInfoViewModel(channel: channel)

        // Then
        XCTAssertTrue(viewModel.shouldShowActionsCard)
    }

    func test_chatChannelInfoVM_shouldShowActionsCard_whenNoActionAvailable_returnsFalse() {
        // Given - a group without mute, block or leave capabilities
        let channel = mockGroup(with: 5, capabilities: [.sendMessage])
        let viewModel = ChatChannelInfoViewModel(channel: channel)

        // Then
        XCTAssertFalse(viewModel.shouldShowActionsCard)
        XCTAssertFalse(viewModel.shouldShowMuteChannelButton)
        XCTAssertFalse(viewModel.shouldShowBlockUserButton)
        XCTAssertFalse(viewModel.shouldShowLeaveConversationButton)
    }

    // MARK: - leaveButtonIcon

    func test_chatChannelInfoVM_leaveButtonIcon_whenDirectMessage_isTrashIcon() {
        // Given
        let viewModel = ChatChannelInfoViewModel(channel: mockDirectMessage())

        // Then
        XCTAssertEqual(viewModel.leaveButtonIcon, InjectedValues[\.images].trash)
    }

    func test_chatChannelInfoVM_leaveButtonIcon_whenGroup_isNotTrashIcon() {
        // Given
        let viewModel = ChatChannelInfoViewModel(channel: mockGroup(with: 5))

        // Then
        XCTAssertNotEqual(viewModel.leaveButtonIcon, InjectedValues[\.images].trash)
    }

    // MARK: - leaveConversationTapped

    func test_chatChannelInfoVM_leaveConversationTapped_overrideRunsCustomLogic() {
        // Given - a subclass sending a system message before leaving the group
        let channel = mockGroup(with: 5)
        let viewModel = SystemMessageChannelInfoViewModel(channel: channel)
        let controller = ChatChannelController_Mock.mock()
        viewModel.channelController = controller

        // When
        viewModel.leaveConversationTapped {}

        // Then
        XCTAssertEqual(controller.createNewMessageCallCount, 1)
        XCTAssertTrue(viewModel.didCallSuper)
    }

    // MARK: - leaveConversationTapped

    func test_chatChannelInfoVM_leaveConversationTapped_whenGroup_removesCurrentUser() {
        // Given
        let viewModel = ChatChannelInfoViewModel(channel: mockGroup(with: 5))
        let controller = channelControllerSpy()
        viewModel.channelController = controller

        // When
        viewModel.leaveConversationTapped {}

        // Then
        XCTAssertEqual(controller.removeMembersUserIds, [chatClient.currentUserId!])
        XCTAssertEqual(controller.deleteChannelCallCount, 0)
    }

    func test_chatChannelInfoVM_leaveConversationTapped_whenGroupLeft_callsCompletion() {
        // Given
        let viewModel = ChatChannelInfoViewModel(channel: mockGroup(with: 5))
        let controller = channelControllerSpy()
        viewModel.channelController = controller
        var completionCallCount = 0

        // When
        viewModel.leaveConversationTapped { completionCallCount += 1 }
        controller.removeMembersCompletion?(nil)

        // Then
        XCTAssertEqual(completionCallCount, 1)
        XCTAssertFalse(viewModel.errorShown)
    }

    func test_chatChannelInfoVM_leaveConversationTapped_whenLeavingFails_showsError() {
        // Given
        let viewModel = ChatChannelInfoViewModel(channel: mockGroup(with: 5))
        let controller = channelControllerSpy()
        viewModel.channelController = controller
        var completionCallCount = 0

        // When
        viewModel.leaveConversationTapped { completionCallCount += 1 }
        controller.removeMembersCompletion?(ClientError.Unknown())

        // Then
        XCTAssertEqual(completionCallCount, 0)
        XCTAssertTrue(viewModel.errorShown)
    }

    func test_chatChannelInfoVM_leaveConversationTapped_whenDirectMessage_deletesChannel() {
        // Given
        let viewModel = ChatChannelInfoViewModel(channel: mockDirectMessage())
        let controller = channelControllerSpy()
        viewModel.channelController = controller
        var completionCallCount = 0

        // When
        viewModel.leaveConversationTapped { completionCallCount += 1 }
        controller.deleteChannelCompletion?(nil)

        // Then
        XCTAssertEqual(controller.deleteChannelCallCount, 1)
        XCTAssertNil(controller.removeMembersUserIds)
        XCTAssertEqual(completionCallCount, 1)
    }

    func test_chatChannelInfoVM_leaveConversationTapped_whenDeletingFails_showsError() {
        // Given
        let viewModel = ChatChannelInfoViewModel(channel: mockDirectMessage())
        let controller = channelControllerSpy()
        viewModel.channelController = controller
        var completionCallCount = 0

        // When
        viewModel.leaveConversationTapped { completionCallCount += 1 }
        controller.deleteChannelCompletion?(ClientError.Unknown())

        // Then
        XCTAssertEqual(completionCallCount, 0)
        XCTAssertTrue(viewModel.errorShown)
    }

    // MARK: - muted

    func test_chatChannelInfoVM_muted_whenSetToTrue_mutesChannel() {
        // Given
        let viewModel = ChatChannelInfoViewModel(channel: mockGroup(with: 5))
        let controller = channelControllerSpy()
        viewModel.channelController = controller

        // When
        viewModel.muted = true

        // Then
        XCTAssertEqual(controller.muteChannelCallCount, 1)
        XCTAssertEqual(controller.unmuteChannelCallCount, 0)
    }

    func test_chatChannelInfoVM_muted_whenSetToFalse_unmutesChannel() {
        // Given
        let channel = ChatChannel.mock(
            cid: .unique,
            lastActiveMembers: ChannelInfoMockUtils.setupMockMembers(
                count: 5,
                currentUserId: chatClient.currentUserId!
            ),
            memberCount: 5,
            muteDetails: MuteDetails(createdAt: Date(), updatedAt: Date(), expiresAt: nil)
        )
        let viewModel = ChatChannelInfoViewModel(channel: channel)
        let controller = channelControllerSpy()
        viewModel.channelController = controller
        XCTAssertTrue(viewModel.muted)

        // When
        viewModel.muted = false

        // Then
        XCTAssertEqual(controller.unmuteChannelCallCount, 1)
        XCTAssertEqual(controller.muteChannelCallCount, 0)
    }

    // MARK: - leaveGroupAction

    func test_chatChannelInfoVM_leaveGroupAction_whenPerformed_removesCurrentUser() {
        // Given
        let viewModel = ChatChannelInfoViewModel(channel: mockGroup(with: 5))
        let controller = channelControllerSpy()
        viewModel.channelController = controller
        var dismissCallCount = 0
        var errors = [Error]()
        let action = viewModel.leaveGroupAction(
            onDismiss: { dismissCallCount += 1 },
            onError: { errors.append($0) }
        )

        // When
        action.action()
        controller.removeMembersCompletion?(nil)

        // Then
        XCTAssertEqual(controller.removeMembersUserIds, [chatClient.currentUserId!])
        XCTAssertEqual(dismissCallCount, 1)
        XCTAssertTrue(errors.isEmpty)
    }

    func test_chatChannelInfoVM_leaveGroupAction_whenLeavingFails_callsOnError() {
        // Given
        let viewModel = ChatChannelInfoViewModel(channel: mockGroup(with: 5))
        let controller = channelControllerSpy()
        viewModel.channelController = controller
        var dismissCallCount = 0
        var errors = [Error]()
        let action = viewModel.leaveGroupAction(
            onDismiss: { dismissCallCount += 1 },
            onError: { errors.append($0) }
        )

        // When
        action.action()
        controller.removeMembersCompletion?(ClientError.Unknown())

        // Then
        XCTAssertEqual(dismissCallCount, 0)
        XCTAssertEqual(errors.count, 1)
    }

    // MARK: - Confirmations

    func test_chatChannelInfoVM_leaveConversationConfirmation_whenGroup_asksToLeaveGroup() {
        // Given
        let viewModel = ChatChannelInfoViewModel(channel: mockGroup(with: 5))

        // When
        let confirmation = viewModel.leaveConversationConfirmation

        // Then
        XCTAssertEqual(confirmation.title, L10n.Alert.Actions.leaveGroupTitle)
        XCTAssertEqual(confirmation.message, L10n.Alert.Actions.leaveGroupMessage)
        XCTAssertEqual(confirmation.buttonTitle, L10n.Alert.Actions.leaveGroupTitle)
    }

    func test_chatChannelInfoVM_leaveConversationConfirmation_whenDirectMessage_asksToDeleteConversation() {
        // Given
        let viewModel = ChatChannelInfoViewModel(channel: mockDirectMessage())

        // When
        let confirmation = viewModel.leaveConversationConfirmation

        // Then
        XCTAssertEqual(confirmation.title, L10n.Alert.Actions.deleteChannelTitle)
        XCTAssertEqual(confirmation.message, L10n.Alert.Actions.deleteChannelMessage)
    }

    func test_chatChannelInfoVM_blockUserConfirmation_whenUserNotBlocked_asksToBlock() {
        // Given
        let viewModel = ChatChannelInfoViewModel(channel: mockDirectMessage())

        // When
        let confirmation = viewModel.blockUserConfirmation

        // Then
        XCTAssertEqual(confirmation.title, L10n.Alert.Actions.blockUser)
        XCTAssertEqual(confirmation.message, L10n.Message.Actions.UserBlock.confirmationMessage)
        XCTAssertEqual(confirmation.buttonTitle, L10n.Alert.Actions.blockUser)
    }

    func test_chatChannelInfoVM_blockUserConfirmation_whenUserBlocked_asksToUnblock() throws {
        // Given
        let viewModel = ChatChannelInfoViewModel(channel: mockDirectMessage())
        let otherParticipant = try XCTUnwrap(
            viewModel.participants.first { $0.id != chatClient.currentUserId }
        )
        viewModel.currentUserController = mockCurrentUserController(blockedUserIds: [otherParticipant.id])

        // When
        let confirmation = viewModel.blockUserConfirmation

        // Then
        XCTAssertEqual(confirmation.title, L10n.Alert.Actions.unblockUser)
        XCTAssertEqual(confirmation.message, L10n.Message.Actions.UserUnblock.confirmationMessage)
    }

    // MARK: - blockUserTapped

    func test_chatChannelInfoVM_blockUserTapped_whenUserNotBlocked_blocksWithoutError() {
        // Given
        let viewModel = ChatChannelInfoViewModel(channel: mockDirectMessage())

        // When
        viewModel.blockUserTapped()

        // Then
        XCTAssertFalse(viewModel.errorShown)
    }

    func test_chatChannelInfoVM_blockUserTapped_whenUserBlocked_unblocksWithoutError() throws {
        // Given
        let viewModel = ChatChannelInfoViewModel(channel: mockDirectMessage())
        let otherParticipant = try XCTUnwrap(
            viewModel.participants.first { $0.id != chatClient.currentUserId }
        )
        viewModel.currentUserController = mockCurrentUserController(blockedUserIds: [otherParticipant.id])

        // When
        viewModel.blockUserTapped()

        // Then
        XCTAssertTrue(viewModel.isDMUserBlocked)
        XCTAssertFalse(viewModel.errorShown)
    }

    func test_chatChannelInfoVM_blockUserTapped_whenNoParticipants_doesNothing() {
        // Given
        let channel = ChatChannel.mockDMChannel(lastActiveMembers: [], memberCount: 0)
        let viewModel = ChatChannelInfoViewModel(channel: channel)

        // When
        viewModel.blockUserTapped()

        // Then
        XCTAssertFalse(viewModel.errorShown)
    }

    // MARK: - addUsersTapped

    func test_chatChannelInfoVM_addUsersTapped_withUsers_closesSheet() {
        // Given
        let channel = mockGroup(with: 5)
        let viewModel = ChatChannelInfoViewModel(channel: channel)
        viewModel.addUsersShown = true
        let usersToAdd = ChannelInfoMockUtils.generateMockUsers(count: 2)

        // When
        viewModel.addUsersTapped(usersToAdd)

        // Then
        XCTAssertFalse(viewModel.addUsersShown)
    }

    func test_chatChannelInfoVM_addUsersTapped_withEmptyArray_closesSheet() {
        // Given
        let channel = mockGroup(with: 5)
        let viewModel = ChatChannelInfoViewModel(channel: channel)
        viewModel.addUsersShown = true

        // When
        viewModel.addUsersTapped([])

        // Then
        XCTAssertFalse(viewModel.addUsersShown)
    }

    // MARK: - allMemberIds

    func test_chatChannelInfoVM_allMemberIds_includesParticipantIds() {
        // Given
        let channel = mockGroup(with: 5)
        let viewModel = ChatChannelInfoViewModel(channel: channel)

        // When
        let allIds = viewModel.allMemberIds

        // Then
        for participant in viewModel.participants {
            XCTAssertTrue(allIds.contains(participant.id))
        }
    }

    func test_chatChannelInfoVM_allMemberIds_noDuplicates() {
        // Given
        let channel = mockGroup(with: 5)
        let viewModel = ChatChannelInfoViewModel(channel: channel)

        // When
        let allIds = viewModel.allMemberIds

        // Then
        XCTAssertEqual(allIds.count, Set(allIds).count)
    }

    // MARK: - isDMUserBlocked / blockUserTitle

    func test_chatChannelInfoVM_isDMUserBlocked_returnsFalse_whenNotBlocked() {
        // Given
        let viewModel = ChatChannelInfoViewModel(channel: mockDirectMessage())

        // Then - no blocked users by default
        XCTAssertFalse(viewModel.isDMUserBlocked)
    }

    func test_chatChannelInfoVM_blockUserTitle_returnsBlockUser_whenNotBlocked() {
        // Given
        let viewModel = ChatChannelInfoViewModel(channel: mockDirectMessage())

        // Then
        XCTAssertEqual(viewModel.blockUserTitle, L10n.Alert.Actions.blockUser)
    }

    func test_chatChannelInfoVM_blockUserTitle_returnsUnblockUser_whenBlocked() {
        // Given
        let viewModel = ChatChannelInfoViewModel(channel: mockDirectMessage())
        let otherParticipant = viewModel.participants.first { $0.id != chatClient.currentUserId }!

        let currentUserController = CurrentChatUserController_Mock(client: chatClient)
        let currentUser = CurrentChatUser.mock(
            currentUserId: chatClient.currentUserId!,
            blockedUserIds: [otherParticipant.id]
        )
        currentUserController.currentUser_mock = currentUser
        viewModel.currentUserController = currentUserController

        // Then
        XCTAssertTrue(viewModel.isDMUserBlocked)
        XCTAssertEqual(viewModel.blockUserTitle, L10n.Alert.Actions.unblockUser)
    }

    // MARK: - saveGroupEdit

    func test_chatChannelInfoVM_saveGroupEdit_withoutImage_closesSheet() {
        // Given
        let channel = mockGroup(with: 3)
        let viewModel = ChatChannelInfoViewModel(channel: channel)
        viewModel.editGroupShown = true

        // When
        viewModel.saveGroupEdit(name: "New Group Name", image: nil)

        // Then
        XCTAssertFalse(viewModel.isUploadingGroupAvatar)
        XCTAssertFalse(viewModel.editGroupShown)
        XCTAssertEqual(viewModel.channelName, "New Group Name")
    }

    func test_chatChannelInfoVM_saveGroupEdit_withImage_setsUploadingFlag() {
        // Given
        let channel = mockGroup(with: 3)
        let viewModel = ChatChannelInfoViewModel(channel: channel)
        viewModel.editGroupShown = true
        let image = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { ctx in
            UIColor.red.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        }

        // When
        viewModel.saveGroupEdit(name: "New Group Name", image: image)

        // Then - uploading flag is set synchronously before the async upload begins
        XCTAssertTrue(viewModel.isUploadingGroupAvatar)
    }

    // MARK: - private

    private func mockGroup(
        with memberCount: Int,
        updateCapabilities: Bool = true,
        mutesEnabled: Bool = true,
        team: TeamId? = nil,
        capabilities: Set<ChannelCapability>? = nil
    ) -> ChatChannel {
        let cid: ChannelId = .unique
        let activeMembers = ChannelInfoMockUtils.setupMockMembers(
            count: memberCount,
            currentUserId: chatClient.currentUserId!
        )
        var defaultCapabilities = Set<ChannelCapability>()
        if updateCapabilities {
            defaultCapabilities.insert(.updateChannel)
            defaultCapabilities.insert(.deleteChannel)
            defaultCapabilities.insert(.leaveChannel)
            defaultCapabilities.insert(.updateChannelMembers)
        }

        let channelConfig = ChannelConfig(mutesEnabled: mutesEnabled)

        let channel = ChatChannel.mock(
            cid: cid,
            config: channelConfig,
            ownCapabilities: capabilities ?? defaultCapabilities,
            lastActiveMembers: activeMembers,
            team: team,
            memberCount: activeMembers.count
        )
        return channel
    }

    private func channelControllerSpy() -> ChannelControllerSpy {
        ChannelControllerSpy(
            channelQuery: .init(cid: .unique),
            channelListQuery: nil,
            client: chatClient
        )
    }

    private func mockDirectMessage() -> ChatChannel {
        let members = ChannelInfoMockUtils.setupMockMembers(
            count: 2,
            currentUserId: chatClient.currentUserId!
        )
        return ChatChannel.mockDMChannel(lastActiveMembers: members, memberCount: 2)
    }

    private func mockCurrentUserController(
        mutedUserIds: [UserId] = [],
        blockedUserIds: [UserId] = []
    ) -> CurrentChatUserController_Mock {
        let currentUserController = CurrentChatUserController_Mock(client: chatClient)
        currentUserController.currentUser_mock = .mock(
            currentUserId: chatClient.currentUserId!,
            blockedUserIds: Set(blockedUserIds),
            mutedUsers: Set(mutedUserIds.map { ChatUser.mock(id: $0) })
        )
        return currentUserController
    }

    private func simulateCurrentUserChange(
        for viewModel: ChatChannelInfoViewModel,
        controller: CurrentChatUserController_Mock
    ) {
        viewModel.currentUserController(
            controller,
            didChangeCurrentUser: .update(controller.currentUser!)
        )
    }
}

private class ChannelControllerSpy: ChatChannelController_Mock {
    var removeMembersUserIds: Set<UserId>?
    var removeMembersCompletion: (@MainActor (Error?) -> Void)?
    var deleteChannelCallCount = 0
    var deleteChannelCompletion: (@MainActor (Error?) -> Void)?
    var muteChannelCallCount = 0
    var unmuteChannelCallCount = 0

    override func removeMembers(
        userIds: Set<UserId>,
        message: String? = nil,
        completion: (@MainActor (Error?) -> Void)? = nil
    ) {
        removeMembersUserIds = userIds
        removeMembersCompletion = completion
    }

    override func deleteChannel(completion: (@MainActor (Error?) -> Void)? = nil) {
        deleteChannelCallCount += 1
        deleteChannelCompletion = completion
    }

    override func muteChannel(expiration: Int? = nil, completion: (@MainActor (Error?) -> Void)? = nil) {
        muteChannelCallCount += 1
    }

    override func unmuteChannel(completion: (@MainActor (Error?) -> Void)? = nil) {
        unmuteChannelCallCount += 1
    }
}

private class SystemMessageChannelInfoViewModel: ChatChannelInfoViewModel {
    var didCallSuper = false

    override func leaveConversationTapped(completion: @escaping @MainActor () -> Void) {
        channelController.createNewMessage(text: "Left the group")
        didCallSuper = true
        super.leaveConversationTapped(completion: completion)
    }
}
