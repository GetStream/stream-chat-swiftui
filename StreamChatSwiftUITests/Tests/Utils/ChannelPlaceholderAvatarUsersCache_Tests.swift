//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import XCTest

@MainActor
final class ChannelPlaceholderAvatarUsersCache_Tests: StreamChatTestCase {
    func test_placeholderUsers_computesAndReturnsLastActiveMembers() {
        // Given
        let cache = ChannelPlaceholderAvatarUsersCache()
        let channel = mockChannel(cid: .unique, memberIds: ["a", "b", "c", "d"])

        // When
        let result = cache.placeholderUsers(for: channel, currentUserId: nil)

        // Then
        XCTAssertEqual(result.map(\.id), ["a", "b", "c", "d"])
    }

    func test_placeholderUsers_limitsToFourUsers() {
        // Given
        let cache = ChannelPlaceholderAvatarUsersCache()
        let channel = mockChannel(cid: .unique, memberIds: ["a", "b", "c", "d", "e", "f"])

        // When
        let result = cache.placeholderUsers(for: channel, currentUserId: nil)

        // Then — at most four users compose the avatar
        XCTAssertEqual(result.map(\.id), ["a", "b", "c", "d"])
    }

    func test_placeholderUsers_placesCurrentUserLast() {
        // Given — the current user was created before the others
        let cache = ChannelPlaceholderAvatarUsersCache()
        let members: [ChatChannelMember] = [
            .mock(id: "current", memberCreatedAt: Date(timeIntervalSinceReferenceDate: 0)),
            .mock(id: "a", memberCreatedAt: Date(timeIntervalSinceReferenceDate: 1)),
            .mock(id: "b", memberCreatedAt: Date(timeIntervalSinceReferenceDate: 2))
        ]
        let channel = ChatChannel.mock(cid: .unique, lastActiveMembers: members, memberCount: 3)

        // When
        let result = cache.placeholderUsers(for: channel, currentUserId: "current")

        // Then — the current user is always placed last
        XCTAssertEqual(result.map(\.id), ["a", "b", "current"])
    }

    func test_placeholderUsers_keepsSelectionWhenSameMembersAreReordered() {
        // Given — a channel whose avatar has been computed and cached
        let cache = ChannelPlaceholderAvatarUsersCache()
        let cid = ChannelId.unique
        let initialResult = cache.placeholderUsers(
            for: mockChannel(cid: cid, memberIds: ["a", "b", "c", "d"], memberCount: 10),
            currentUserId: nil
        )

        // When — the same members are later reported in a different order
        // (e.g. activity changed which members are loaded first)
        let result = cache.placeholderUsers(
            for: mockChannel(cid: cid, memberIds: ["d", "c", "b", "a"], memberCount: 10),
            currentUserId: nil
        )

        // Then — the cached selection is kept, so the avatar stays consistent
        XCTAssertEqual(result.map(\.id), initialResult.map(\.id))
        XCTAssertEqual(result.map(\.id), ["a", "b", "c", "d"])
    }

    func test_placeholderUsers_recomputesWhenVisibleMemberSwapped() {
        // Given — a cached four-member selection in a larger channel
        let cache = ChannelPlaceholderAvatarUsersCache()
        let cid = ChannelId.unique
        _ = cache.placeholderUsers(
            for: mockChannel(cid: cid, memberIds: ["a", "b", "c", "d"], memberCount: 10),
            currentUserId: nil
        )

        // When — a member visible in the avatar is removed and another added,
        // keeping the total member count the same
        let result = cache.placeholderUsers(
            for: mockChannel(cid: cid, memberIds: ["a", "b", "c", "e"], memberCount: 10),
            currentUserId: nil
        )

        // Then — the selection is recomputed because a visible member is gone
        XCTAssertEqual(result.map(\.id), ["a", "b", "c", "e"])
    }

    func test_placeholderUsers_resolvesLatestUserDataForLoadedMembers() {
        // Given — a cached selection where member "a" had no image
        let cache = ChannelPlaceholderAvatarUsersCache()
        let cid = ChannelId.unique
        let initialMembers: [ChatChannelMember] = [
            .mock(id: "a", imageURL: nil, memberCreatedAt: Date(timeIntervalSinceReferenceDate: 0)),
            .mock(id: "b", memberCreatedAt: Date(timeIntervalSinceReferenceDate: 1))
        ]
        _ = cache.placeholderUsers(
            for: .mock(cid: cid, lastActiveMembers: initialMembers, memberCount: 2),
            currentUserId: nil
        )

        // When — member "a" updates the profile image (same membership)
        let updatedImage = URL(string: "https://example.com/a.png")!
        let updatedMembers: [ChatChannelMember] = [
            .mock(id: "a", imageURL: updatedImage, memberCreatedAt: Date(timeIntervalSinceReferenceDate: 0)),
            .mock(id: "b", memberCreatedAt: Date(timeIntervalSinceReferenceDate: 1))
        ]
        let result = cache.placeholderUsers(
            for: .mock(cid: cid, lastActiveMembers: updatedMembers, memberCount: 2),
            currentUserId: nil
        )

        // Then — the same members are returned, but with the latest data
        XCTAssertEqual(result.map(\.id), ["a", "b"])
        XCTAssertEqual(result.first(where: { $0.id == "a" })?.imageURL, updatedImage)
    }

    func test_placeholderUsers_recomputesWhenMemberAdded() {
        // Given — a cached three-member selection
        let cache = ChannelPlaceholderAvatarUsersCache()
        let cid = ChannelId.unique
        _ = cache.placeholderUsers(
            for: mockChannel(cid: cid, memberIds: ["a", "b", "c"], memberCount: 3),
            currentUserId: nil
        )

        // When — a member is added (member count increases)
        let result = cache.placeholderUsers(
            for: mockChannel(cid: cid, memberIds: ["a", "b", "c", "d"], memberCount: 4),
            currentUserId: nil
        )

        // Then — the selection is recomputed to reflect the added member
        XCTAssertEqual(result.map(\.id), ["a", "b", "c", "d"])
    }

    func test_placeholderUsers_recomputesWhenMemberRemoved() {
        // Given — a cached four-member selection
        let cache = ChannelPlaceholderAvatarUsersCache()
        let cid = ChannelId.unique
        _ = cache.placeholderUsers(
            for: mockChannel(cid: cid, memberIds: ["a", "b", "c", "d"], memberCount: 4),
            currentUserId: nil
        )

        // When — a member is removed (member count decreases)
        let result = cache.placeholderUsers(
            for: mockChannel(cid: cid, memberIds: ["a", "b", "c"], memberCount: 3),
            currentUserId: nil
        )

        // Then — the selection is recomputed to reflect the removed member
        XCTAssertEqual(result.map(\.id), ["a", "b", "c"])
    }

    func test_placeholderUsers_recomputesAfterClear() {
        // Given — a cached selection
        let cache = ChannelPlaceholderAvatarUsersCache()
        let cid = ChannelId.unique
        _ = cache.placeholderUsers(for: mockChannel(cid: cid, memberIds: ["a", "b"]), currentUserId: nil)

        // When — the cache is cleared and the members changed
        cache.clear()
        let result = cache.placeholderUsers(for: mockChannel(cid: cid, memberIds: ["x", "y"]), currentUserId: nil)

        // Then — the selection is recomputed from the latest members
        XCTAssertEqual(result.map(\.id), ["x", "y"])
    }

    func test_placeholderUsers_doesNotCacheEmptyResult() {
        // Given — a channel whose members are not loaded yet
        let cache = ChannelPlaceholderAvatarUsersCache()
        let cid = ChannelId.unique
        let emptyChannel = ChatChannel.mock(cid: cid, lastActiveMembers: [], memberCount: 3)

        // When — the avatar is requested before and after members are loaded
        let emptyResult = cache.placeholderUsers(for: emptyChannel, currentUserId: nil)
        let loadedResult = cache.placeholderUsers(
            for: mockChannel(cid: cid, memberIds: ["a", "b", "c"], memberCount: 3),
            currentUserId: nil
        )

        // Then — the empty result is not cached, so the loaded members are used
        XCTAssertTrue(emptyResult.isEmpty)
        XCTAssertEqual(loadedResult.map(\.id), ["a", "b", "c"])
    }

    func test_placeholderUsers_cachesPerChannel() {
        // Given
        let cache = ChannelPlaceholderAvatarUsersCache()
        let firstChannel = mockChannel(cid: .unique, memberIds: ["a", "b"])
        let secondChannel = mockChannel(cid: .unique, memberIds: ["c", "d"])

        // When
        let firstResult = cache.placeholderUsers(for: firstChannel, currentUserId: nil)
        let secondResult = cache.placeholderUsers(for: secondChannel, currentUserId: nil)

        // Then — each channel keeps its own cached users
        XCTAssertEqual(firstResult.map(\.id), ["a", "b"])
        XCTAssertEqual(secondResult.map(\.id), ["c", "d"])
    }

    // MARK: - Helpers

    private func mockChannel(cid: ChannelId, memberIds: [String], memberCount: Int? = nil) -> ChatChannel {
        let members: [ChatChannelMember] = memberIds.enumerated().map { index, id in
            .mock(id: id, memberCreatedAt: Date(timeIntervalSinceReferenceDate: TimeInterval(index)))
        }
        return .mock(cid: cid, lastActiveMembers: members, memberCount: memberCount ?? memberIds.count)
    }
}
