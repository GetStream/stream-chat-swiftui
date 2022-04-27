//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI

struct ChannelInfoMockUtils {
    
    static func setupMockMembers(
        count: Int,
        currentUserId: String,
        onlineUserIndexes: [Int] = []
    ) -> [ChatChannelMember] {
        var activeMembers = [ChatChannelMember]()
        for i in 0..<count {
            var id: String = .unique
            if i == 0 {
                id = currentUserId
            }
            var isOnline = false
            if onlineUserIndexes.contains(i) {
                isOnline = true
            }
            let member: ChatChannelMember = .mock(
                id: id,
                name: "Test \(i)",
                isOnline: isOnline
            )
            activeMembers.append(member)
        }
        return activeMembers
    }
    
    static let pinnedMessage = ChatMessage.mock(
        id: .unique,
        cid: .unique,
        text: "Test",
        author: .mock(id: .unique, name: "Test User"),
        pinDetails: MessagePinDetails(
            pinnedAt: Date(),
            pinnedBy: .mock(id: .unique),
            expiresAt: nil
        )
    )
}
