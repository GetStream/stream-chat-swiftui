//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import XCTest

@MainActor
final class ChannelAvatarsCache_Tests: StreamChatTestCase {
    func test_avatarUsers_computesAndReturnsLastActiveMembers() {
        // Given
        let cache = ChannelAvatarsCache()
        let channel = mockChannel(cid: .unique, memberIds: ["a", "b", "c", "d"])

        // When
        let result = cache.avatarUsers(for: channel, currentUserId: nil)

        // Then
        XCTAssertEqual(result.map(\.id), ["a", "b", "c", "d"])
    }

    func test_avatarUsers_limitsToFourUsers() {
        // Given
        let cache = ChannelAvatarsCache()
        let channel = mockChannel(cid: .unique, memberIds: ["a", "b", "c", "d", "e", "f"])

        // When
        let result = cache.avatarUsers(for: channel, currentUserId: nil)

        // Then — at most four users compose the avatar
        XCTAssertEqual(result.map(\.id), ["a", "b", "c", "d"])
    }

    func test_avatarUsers_placesCurrentUserLast() {
        // Given — the current user was created before the others
        let cache = ChannelAvatarsCache()
        let members: [ChatChannelMember] = [
            .mock(id: "current", memberCreatedAt: Date(timeIntervalSinceReferenceDate: 0)),
            .mock(id: "a", memberCreatedAt: Date(timeIntervalSinceReferenceDate: 1)),
            .mock(id: "b", memberCreatedAt: Date(timeIntervalSinceReferenceDate: 2))
        ]
        let channel = ChatChannel.mock(cid: .unique, lastActiveMembers: members, memberCount: 3)

        // When
        let result = cache.avatarUsers(for: channel, currentUserId: "current")

        // Then — the current user is always placed last
        XCTAssertEqual(result.map(\.id), ["a", "b", "current"])
    }

    func test_avatarUsers_doesNotChangeWhenLastActiveMembersChange() {
        // Given — a channel whose avatar has been computed and cached
        let cache = ChannelAvatarsCache()
        let cid = ChannelId.unique
        let initialResult = cache.avatarUsers(
            for: mockChannel(cid: cid, memberIds: ["a", "b", "c", "d"]),
            currentUserId: nil
        )

        // When — the same channel later reports a different set of last active members
        let result = cache.avatarUsers(
            for: mockChannel(cid: cid, memberIds: ["e", "f", "g", "h"]),
            currentUserId: nil
        )

        // Then — the cached users are returned, so the avatar stays consistent
        XCTAssertEqual(result.map(\.id), initialResult.map(\.id))
        XCTAssertEqual(result.map(\.id), ["a", "b", "c", "d"])
    }

    func test_avatarUsers_recomputesAfterClear() {
        // Given — a cached channel avatar
        let cache = ChannelAvatarsCache()
        let cid = ChannelId.unique
        _ = cache.avatarUsers(for: mockChannel(cid: cid, memberIds: ["a", "b"]), currentUserId: nil)

        // When — the cache is cleared and the members changed
        cache.clear()
        let result = cache.avatarUsers(for: mockChannel(cid: cid, memberIds: ["x", "y"]), currentUserId: nil)

        // Then — the avatar is recomputed from the latest members
        XCTAssertEqual(result.map(\.id), ["x", "y"])
    }

    func test_avatarUsers_doesNotCacheEmptyResult() {
        // Given — a channel whose members are not loaded yet
        let cache = ChannelAvatarsCache()
        let cid = ChannelId.unique
        let emptyChannel = ChatChannel.mock(cid: cid, lastActiveMembers: [], memberCount: 3)

        // When — the avatar is requested before and after members are loaded
        let emptyResult = cache.avatarUsers(for: emptyChannel, currentUserId: nil)
        let loadedResult = cache.avatarUsers(
            for: mockChannel(cid: cid, memberIds: ["a", "b", "c"]),
            currentUserId: nil
        )

        // Then — the empty result is not cached, so the loaded members are used
        XCTAssertTrue(emptyResult.isEmpty)
        XCTAssertEqual(loadedResult.map(\.id), ["a", "b", "c"])
    }

    func test_avatarUsers_cachesPerChannel() {
        // Given
        let cache = ChannelAvatarsCache()
        let firstChannel = mockChannel(cid: .unique, memberIds: ["a", "b"])
        let secondChannel = mockChannel(cid: .unique, memberIds: ["c", "d"])

        // When
        let firstResult = cache.avatarUsers(for: firstChannel, currentUserId: nil)
        let secondResult = cache.avatarUsers(for: secondChannel, currentUserId: nil)

        // Then — each channel keeps its own cached users
        XCTAssertEqual(firstResult.map(\.id), ["a", "b"])
        XCTAssertEqual(secondResult.map(\.id), ["c", "d"])
    }

    // MARK: - Helpers

    private func mockChannel(cid: ChannelId, memberIds: [String]) -> ChatChannel {
        let members: [ChatChannelMember] = memberIds.enumerated().map { index, id in
            .mock(id: id, memberCreatedAt: Date(timeIntervalSinceReferenceDate: TimeInterval(index)))
        }
        return .mock(cid: cid, lastActiveMembers: members, memberCount: memberIds.count)
    }
}
