//
// Copyright © 2022 Stream.io Inc. All rights reserved.
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
        let members = setupMockMembers(count: 2)
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
    
    // MARK: - private
    
    private func mockGroup(with memberCount: Int) -> ChatChannel {
        let cid: ChannelId = .unique
        let activeMembers = setupMockMembers(count: memberCount)
        let channel = ChatChannel.mock(
            cid: cid,
            lastActiveMembers: activeMembers,
            memberCount: activeMembers.count
        )
        return channel
    }
    
    private func setupMockMembers(count: Int) -> [ChatChannelMember] {
        var activeMembers = [ChatChannelMember]()
        for i in 0..<count {
            var id: String = .unique
            if i == 0 {
                id = chatClient.currentUserId!
            }
            let member: ChatChannelMember = .mock(id: id)
            activeMembers.append(member)
        }
        return activeMembers
    }
}
