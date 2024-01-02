//
// Copyright © 2024 Stream.io Inc. All rights reserved.
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

    static func generateMessagesWithAttachments(
        withImages: Int = 0,
        withVideos: Int = 0
    ) -> LazyCachedMapCollection<ChatMessage> {
        var result = [ChatMessage]()
        for i in 0..<withImages {
            let message = ChatMessage.mock(
                id: .unique,
                cid: .unique,
                text: "Image Attachment \(i)",
                author: .mock(id: .unique),
                attachments: ChatChannelTestHelpers.imageAttachments
            )
            result.append(message)
        }

        for i in 0..<withVideos {
            let message = ChatMessage.mock(
                id: .unique,
                cid: .unique,
                text: "Video Attachment \(i)",
                author: .mock(id: .unique),
                attachments: ChatChannelTestHelpers.videoAttachments
            )
            result.append(message)
        }

        return LazyCachedMapCollection(source: result) { $0 }
    }

    static func generateMessagesWithFileAttachments(
        count: Int
    ) -> LazyCachedMapCollection<ChatMessage> {
        var result = [ChatMessage]()
        for i in 0..<count {
            let message = ChatMessage.mock(
                id: .unique,
                cid: .unique,
                text: "File Attachment \(i)",
                author: .mock(id: .unique),
                attachments: ChatChannelTestHelpers.fileAttachments
            )
            result.append(message)
        }

        return LazyCachedMapCollection(source: result) { $0 }
    }

    static func generateMockUsers(count: Int) -> [ChatUser] {
        var result = [ChatUser]()
        for i in 0..<count {
            let user = ChatUser.mock(id: .unique, name: "Test User \(i)")
            result.append(user)
        }

        return result
    }
}
