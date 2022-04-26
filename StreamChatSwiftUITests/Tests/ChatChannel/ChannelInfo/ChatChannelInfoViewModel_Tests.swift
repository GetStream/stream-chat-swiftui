//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class ChatChannelInfoViewModel_Tests: StreamChatTestCase {
    
    func test_chatChannelInfoVM_initialGroupParticipants() {
        // Given
        let cid: ChannelId = .unique
        let activeMembers = setupMockMembers(count: 10)
        let channel = ChatChannel.mock(
            cid: cid,
            lastActiveMembers: activeMembers,
            memberCount: activeMembers.count
        )
        let viewModel = ChatChannelInfoViewModel(channel: channel)
        
        // When
        let participants = viewModel.participants
        let displayedParticipants = viewModel.displayedParticipants
        
        // Then
        XCTAssert(participants.count == 10)
        XCTAssert(displayedParticipants.count == 6)
    }
    
    // MARK: - private
    
    private func setupMockMembers(count: Int) -> [ChatChannelMember] {
        var activeMembers = [ChatChannelMember]()
        for _ in 0..<count {
            let member: ChatChannelMember = .mock(id: .unique)
            activeMembers.append(member)
        }
        return activeMembers
    }
}
