//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

final class ChannelAvatar_Tests: StreamChatTestCase {
    func test_channelAvatar_placeholders() async throws {
        // Given — group channel with no image and no members shows placeholder at every size
        let channel = ChatChannel.mock(
            cid: .unique,
            memberCount: 0
        )
        let size = CGSize(width: 320, height: 320)
        let view = HStack(spacing: 2) {
            VStack(spacing: 2) {
                ForEach(AvatarSize.standardSizes, id: \.self) { size in
                    ChannelAvatar(channel: channel, size: size)
                }
            }
            VStack(spacing: 2) {
                ForEach(AvatarSize.standardSizes, id: \.self) { size in
                    ChannelAvatar(channel: channel, size: size)
                }
            }
            VStack(spacing: 2) {
                ForEach(AvatarSize.standardSizes, id: \.self) { size in
                    ChannelAvatar(channel: channel, size: size, indicator: .online)
                }
            }
            VStack(spacing: 2) {
                ForEach(AvatarSize.standardSizes, id: \.self) { size in
                    ChannelAvatar(channel: channel, size: size, indicator: .online)
                        .redacted(reason: .placeholder)
                }
            }
        }
        .frame(width: size.width, height: size.height)

        // Then
        AssertSnapshot(view, size: size)
    }

    // MARK: - Stacked Placeholders

    func test_channelAvatar_stackedPlaceholders_singleMember() {
        // Given — 1 member shows diagonal layout (avatar + generic placeholder)
        let channel = mockGroupChannel(memberCount: 1, activeMembers: 1)
        let size = CGSize(width: 240, height: 100)
        let view = avatarRow(channel: channel)
            .frame(width: size.width, height: size.height)

        // Then
        AssertSnapshot(view, size: size)
    }

    func test_channelAvatar_stackedPlaceholders_twoMembers() {
        // Given — 2 members shows diagonal layout
        let channel = mockGroupChannel(memberCount: 2, activeMembers: 2)
        let size = CGSize(width: 240, height: 100)
        let view = avatarRow(channel: channel)
            .frame(width: size.width, height: size.height)

        // Then
        AssertSnapshot(view, size: size)
    }

    func test_channelAvatar_stackedPlaceholders_threeMembers() {
        // Given — 3 members shows triangle layout
        let channel = mockGroupChannel(memberCount: 3, activeMembers: 3)
        let size = CGSize(width: 240, height: 100)
        let view = avatarRow(channel: channel)
            .frame(width: size.width, height: size.height)

        // Then
        AssertSnapshot(view, size: size)
    }

    func test_channelAvatar_stackedPlaceholders_fourMembers() {
        // Given — 4 members shows 2×2 grid
        let channel = mockGroupChannel(memberCount: 4, activeMembers: 4)
        let size = CGSize(width: 240, height: 100)
        let view = avatarRow(channel: channel)
            .frame(width: size.width, height: size.height)

        // Then
        AssertSnapshot(view, size: size)
    }

    func test_channelAvatar_stackedPlaceholders_overflow() {
        // Given — 7 members (4 active) shows two avatars + count badge
        let channel = mockGroupChannel(memberCount: 7, activeMembers: 4)
        let size = CGSize(width: 240, height: 100)
        let view = avatarRow(channel: channel)
            .frame(width: size.width, height: size.height)

        // Then
        AssertSnapshot(view, size: size)
    }

    func test_channelAvatar_stackedPlaceholders_overflowClamped() {
        // Given — overflow badge clamps at +99
        let channel = mockGroupChannel(memberCount: 200, activeMembers: 4)
        let size = CGSize(width: 240, height: 100)
        let view = avatarRow(channel: channel)
            .frame(width: size.width, height: size.height)

        // Then
        AssertSnapshot(view, size: size)
    }

    func test_channelAvatar_stackedPlaceholders_withOnlineIndicator() {
        // Given — DM channel with online member shows indicator
        let channel = mockGroupChannel(memberCount: 2, activeMembers: 2)
        let size = CGSize(width: 240, height: 100)
        let view = avatarRow(channel: channel, indicator: .online)
            .frame(width: size.width, height: size.height)

        // Then
        AssertSnapshot(view, size: size)
    }

    func test_channelAvatar_stackedPlaceholders_brokenDataZeroMemberCount() {
        // Given — memberCount is 0 (broken data) but 2 active members are present
        let channel = mockGroupChannel(memberCount: 0, activeMembers: 2)
        let size = CGSize(width: 240, height: 100)
        let view = avatarRow(channel: channel)
            .frame(width: size.width, height: size.height)

        // Then
        AssertSnapshot(view, size: size)
    }

    func test_channelAvatar_stackedPlaceholders_overflowInsufficientUsers() {
        // Given — memberCount triggers overflow but too few active members to render it;
        // should fall back to generic PlaceholderView instead of crashing.
        let channelNoMembers = mockGroupChannel(memberCount: 5, activeMembers: 0)
        let channelOneMember = mockGroupChannel(memberCount: 5, activeMembers: 1)
        let size = CGSize(width: 240, height: 220)
        let view = VStack(spacing: 8) {
            // 0 active members
            avatarRow(channel: channelNoMembers)
            // 1 active member
            avatarRow(channel: channelOneMember)
        }
        .frame(width: size.width, height: size.height)

        // Then
        AssertSnapshot(view, size: size)
    }

    func test_channelAvatar_directMessageChannel_twoMembers() {
        // Given — DM channel with 2 members should show a single UserAvatar
        let channel = mockDMChannel(isOtherMemberOnline: true)
        let size = CGSize(width: 240, height: 100)
        let view = avatarRow(channel: channel)
            .frame(width: size.width, height: size.height)

        // Then
        AssertSnapshot(view, size: size)
    }

    // MARK: - Helpers

    private let memberNames = ["Alice Baker", "Carol Davis", "Eve Fox", "Grace Hill"]

    /// Creates a mock group channel with the given member count and number of active members.
    private func mockGroupChannel(memberCount: Int, activeMembers count: Int) -> ChatChannel {
        let members: [ChatChannelMember] = (0..<count).map { i in
            .mock(
                id: "member-\(i)",
                name: memberNames[i % memberNames.count],
                memberCreatedAt: Date(timeIntervalSinceReferenceDate: TimeInterval(i))
            )
        }
        return .mock(
            cid: .unique,
            lastActiveMembers: members,
            memberCount: memberCount
        )
    }

    /// Creates a mock DM channel with the current user and one other member.
    private func mockDMChannel(isOtherMemberOnline: Bool) -> ChatChannel {
        let otherMember = ChatChannelMember.mock(
            id: "other-user",
            name: "Alice Baker",
            isOnline: isOtherMemberOnline,
            memberCreatedAt: Date(timeIntervalSinceReferenceDate: 0)
        )
        let currentMember = ChatChannelMember.mock(
            id: Self.currentUserId,
            name: "Current User",
            isOnline: true,
            memberCreatedAt: Date(timeIntervalSinceReferenceDate: 1)
        )
        return .mockDMChannel(
            lastActiveMembers: [otherMember, currentMember],
            memberCount: 2
        )
    }

    /// Creates a horizontal row of channel avatars at lg, xl, and 2xl sizes.
    private func avatarRow(channel: ChatChannel, indicator: AvatarIndicator = .none) -> some View {
        let sizes: [CGFloat] = [AvatarSize.large, AvatarSize.extraLarge, AvatarSize.extraExtraLarge]
        return HStack(spacing: 8) {
            ForEach(sizes, id: \.self) { size in
                ChannelAvatar(channel: channel, size: size, indicator: indicator)
            }
        }
    }
}
