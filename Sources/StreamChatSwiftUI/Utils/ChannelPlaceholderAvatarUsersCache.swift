//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat

/// Caches the **selection of users** used to render a channel's placeholder
/// avatar, so the avatar stays stable while the channel list is shown.
///
/// A group channel's placeholder avatar (shown when the channel has no custom
/// image) is composed from its last active members. `ChatChannel.lastActiveMembers`
/// is a capped subset sorted by activity, so as members become more or less
/// active the subset changes and the members picked for the avatar would
/// otherwise keep changing while the list is on screen.
///
/// To keep it consistent, the selected users are computed once per channel and
/// reused afterwards. The selection is recomputed when the channel's membership
/// changes (`memberCount`), so members being added or removed are reflected.
///
/// - Note: This does **not** cache avatar images. Images are loaded and cached
///   separately by the media loader (keyed by URL). On every access the latest
///   data is resolved for members that are still loaded, so profile image/name
///   updates are reflected without changing which members appear.
@MainActor
final class ChannelPlaceholderAvatarUsersCache {
    /// The maximum number of users that compose a placeholder avatar.
    private let maxNumberOfUsers = 4

    private struct Entry {
        let users: [ChatUser]
        let memberCount: Int
    }

    private let cache = Cache<ChannelId, Entry>()

    /// Returns the users used to render the given channel's placeholder avatar.
    ///
    /// The first time it is called for a channel, the users are computed from
    /// the channel's last active members and cached. Subsequent calls keep the
    /// same members in the same order – resolving their latest data when still
    /// available – so the avatar does not change when the last active members
    /// are reordered. The selection is recomputed when the channel's member
    /// count changes.
    ///
    /// - Parameters:
    ///   - channel: The channel whose placeholder avatar users to resolve.
    ///   - currentUserId: The id of the current user, who is always placed last.
    /// - Returns: The users to display in the placeholder avatar.
    func placeholderUsers(for channel: ChatChannel, currentUserId: UserId?) -> [ChatUser] {
        if let entry = cache[channel.cid], entry.memberCount == channel.memberCount {
            // Keep the same members in the same order, but resolve their latest
            // data when still available so profile changes are reflected without
            // changing which members appear in the avatar.
            let latestUsersById = Dictionary(
                channel.lastActiveMembers.map { ($0.id, $0 as ChatUser) },
                uniquingKeysWith: { existing, _ in existing }
            )
            return entry.users.map { latestUsersById[$0.id] ?? $0 }
        }
        let users = computeUsers(for: channel, currentUserId: currentUserId)
        // Avoid caching before members are loaded, otherwise the avatar would
        // remain empty for the channel's lifetime.
        if !users.isEmpty {
            cache[channel.cid] = Entry(users: users, memberCount: channel.memberCount)
        }
        return users
    }

    /// Removes all cached selections.
    func clear() {
        cache.removeAllObjects()
    }

    private func computeUsers(for channel: ChatChannel, currentUserId: UserId?) -> [ChatUser] {
        Array(
            channel.lastActiveMembers
                .sorted {
                    // Current user always last, others sorted by creation date.
                    if $0.id == currentUserId { return false }
                    if $1.id == currentUserId { return true }
                    return $0.memberCreatedAt < $1.memberCreatedAt
                }
                .prefix(maxNumberOfUsers)
        )
    }
}
