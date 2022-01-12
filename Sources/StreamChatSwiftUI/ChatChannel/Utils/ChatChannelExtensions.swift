//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

extension ChatChannel {
    
    func onlineInfoText(currentUserId: String) -> String {
        if isDirectMessageChannel {
            guard let member = lastActiveMembers
                .first(where: { $0.id != currentUserId })
            else {
                return ""
            }

            if member.isOnline {
                return L10n.Message.Title.online
            } else if let lastActiveAt = member.lastActiveAt,
                      let timeAgo = lastSeenDateFormatter(lastActiveAt) {
                return timeAgo
            } else {
                return L10n.Message.Title.offline
            }
        }

        return L10n.Message.Title.group(memberCount, watcherCount)
    }
    
    func currentlyTypingUsersFiltered(currentUserId: UserId?) -> [ChatUser] {
        currentlyTypingUsers.filter { user in
            user.id != currentUserId
        }
    }
    
    func typingIndicatorString(currentUserId: UserId?) -> String {
        let typingUsers = currentlyTypingUsersFiltered(currentUserId: currentUserId)
        if let user = typingUsers.first(where: { user in user.name != nil }), let name = user.name {
            return L10n.MessageList.TypingIndicator.users(name, typingUsers.count - 1)
        } else {
            // If we somehow cannot fetch any user name, we simply show that `Someone is typing`
            return L10n.MessageList.TypingIndicator.typingUnknown
        }
    }
    
    private var lastSeenDateFormatter: (Date) -> String? {
        DateUtils.timeAgo
    }
}

extension ChatUser {
    
    var mentionText: String {
        if let name = self.name, !name.isEmpty {
            return name
        } else {
            return id
        }
    }
}
