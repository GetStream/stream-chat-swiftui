//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
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

    // MARK: - private

    private func mockGroup(with memberCount: Int, updateCapabilities: Bool = true) -> ChatChannel {
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
        let channel = ChatChannel.mock(
            cid: cid,
            ownCapabilities: capabilities,
            lastActiveMembers: activeMembers,
            memberCount: activeMembers.count
        )
        return channel
    }
}
