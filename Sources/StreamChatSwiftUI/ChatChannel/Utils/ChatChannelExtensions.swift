//
// Copyright © 2021 Stream.io Inc. All rights reserved.
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
