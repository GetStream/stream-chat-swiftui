//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

extension ChatChannel {

    /// Returns the online info text for a channel.
    /// - Parameters:
    ///  - currentUserId: the id of the current user.
    /// - Returns: the online info text string.
    public func onlineInfoText(currentUserId: String) -> String {
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

    /// Returns the currently typing users, without the current user.
    /// - Parameters:
    ///  - currentUserId: the id of the current user.
    /// - Returns: Array of users that are currently typing.
    public func currentlyTypingUsersFiltered(currentUserId: UserId?) -> [ChatUser] {
        currentlyTypingUsers.filter { user in
            user.id != currentUserId
        }
    }

    /// Returns the typing indicator string.
    /// - Parameters:
    ///  - currentUserId: the id of the current user.
    /// - Returns: the typing indicator string.
    public func typingIndicatorString(currentUserId: UserId?) -> String {
        let chatUserNamer = InjectedValues[\.utils].chatUserNamer
        let typingUsers = currentlyTypingUsersFiltered(currentUserId: currentUserId)
        if let user = typingUsers.first(where: { user in user.name != nil }), let name = chatUserNamer.name(forUser: user) {
            return L10n.MessageList.TypingIndicator.users(name, typingUsers.count - 1)
        } else {
            // If we somehow cannot fetch any user name, we simply show that `Someone is typing`
            return L10n.MessageList.TypingIndicator.typingUnknown
        }
    }

    /// Returns users that have read the channel's latest message.
    /// - Parameters:
    ///  - currentUserId: the id of the current user.
    ///  - message: the current message.
    /// - Returns: The list of users that read the channel.
    public func readUsers(currentUserId: UserId?, message: ChatMessage?) -> [ChatUser] {
        guard let message = message else {
            return []
        }
        let readUsers = reads.filter {
            $0.lastReadAt > message.createdAt &&
                $0.user.id != currentUserId
        }.map(\.user)
        return readUsers
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
