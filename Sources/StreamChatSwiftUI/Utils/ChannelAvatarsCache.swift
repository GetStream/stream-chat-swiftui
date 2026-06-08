//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat

/// Caches the users used to render a channel's avatar so it stays stable
/// while the channel list is shown.
///
/// A group channel's avatar is composed from its last active members. While
/// the channel list is on screen, member activity can reorder
/// `lastActiveMembers`, which would otherwise cause the avatar to change
/// dynamically. To keep the avatar consistent, the users are computed once
/// per channel and reused from this cache afterwards. The cache is cleared
/// when the channel list is loaded.
final class ChannelAvatarsCache {
    /// The maximum number of users that combine to form a single avatar.
    private let maxNumberOfUsers = 4

    private let cache = Cache<ChannelId, [ChatUser]>()

    /// Returns the users used to render the given channel's avatar.
    ///
    /// The first time it is called for a channel, the users are computed from
    /// the channel's last active members and cached. Subsequent calls return
    /// the cached users, so the avatar does not change when the channel's last
    /// active members are reordered.
    ///
    /// - Parameters:
    ///   - channel: The channel whose avatar users to resolve.
    ///   - currentUserId: The id of the current user, who is always placed last.
    /// - Returns: The users to display in the channel avatar.
    func avatarUsers(for channel: ChatChannel, currentUserId: UserId?) -> [ChatUser] {
        if let cached = cache[channel.cid] {
            return cached
        }
        let users: [ChatUser] = Array(
            channel.lastActiveMembers
                .sorted {
                    // Current user always last, others sorted by creation date.
                    if $0.id == currentUserId { return false }
                    if $1.id == currentUserId { return true }
                    return $0.memberCreatedAt < $1.memberCreatedAt
                }
                .prefix(maxNumberOfUsers)
        )
        // Avoid caching before members are loaded, otherwise the avatar would
        // remain empty for the channel's lifetime.
        if !users.isEmpty {
            cache[channel.cid] = users
        }
        return users
    }

    /// Removes all cached avatar users.
    func clear() {
        cache.removeAllObjects()
    }
}
