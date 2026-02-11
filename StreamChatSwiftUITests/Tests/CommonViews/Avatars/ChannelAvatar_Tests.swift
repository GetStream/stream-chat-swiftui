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
        // Given
        let size = CGSize(width: 320, height: 320)
        let view = HStack(spacing: 2) {
            VStack(spacing: 2) {
                ForEach(AvatarSize.standardSizes, id: \.self) { size in
                    ChannelAvatar(
                        url: nil,
                        size: size,
                        stackedPlaceholders: [],
                        memberCount: 0
                    )
                }
            }
            VStack(spacing: 2) {
                ForEach(AvatarSize.standardSizes, id: \.self) { size in
                    ChannelAvatar(
                        url: nil,
                        size: size,
                        stackedPlaceholders: [],
                        memberCount: 0
                    )
                }
            }
            VStack(spacing: 2) {
                ForEach(AvatarSize.standardSizes, id: \.self) { size in
                    ChannelAvatar(
                        url: nil,
                        size: size,
                        stackedPlaceholders: [],
                        memberCount: 0,
                        indicator: .online
                    )
                }
            }
            VStack(spacing: 2) {
                ForEach(AvatarSize.standardSizes, id: \.self) { size in
                    ChannelAvatar(
                        url: nil,
                        size: size,
                        stackedPlaceholders: [],
                        memberCount: 0,
                        indicator: .online
                    )
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
        let size = CGSize(width: 240, height: 100)
        let view = stackedRow(placeholderCount: 1, memberCount: 1)
            .frame(width: size.width, height: size.height)
        
        // Then
        AssertSnapshot(view, size: size)
    }
    
    func test_channelAvatar_stackedPlaceholders_twoMembers() {
        // Given — 2 members shows diagonal layout
        let size = CGSize(width: 240, height: 100)
        let view = stackedRow(placeholderCount: 2, memberCount: 2)
            .frame(width: size.width, height: size.height)
        
        // Then
        AssertSnapshot(view, size: size)
    }
    
    func test_channelAvatar_stackedPlaceholders_threeMembers() {
        // Given — 3 members shows triangle layout
        let size = CGSize(width: 240, height: 100)
        let view = stackedRow(placeholderCount: 3, memberCount: 3)
            .frame(width: size.width, height: size.height)
        
        // Then
        AssertSnapshot(view, size: size)
    }
    
    func test_channelAvatar_stackedPlaceholders_fourMembers() {
        // Given — 4 members shows 2×2 grid
        let size = CGSize(width: 240, height: 100)
        let view = stackedRow(placeholderCount: 4, memberCount: 4)
            .frame(width: size.width, height: size.height)
        
        // Then
        AssertSnapshot(view, size: size)
    }
    
    func test_channelAvatar_stackedPlaceholders_overflow() {
        // Given — 5+ members shows two avatars + count badge
        let size = CGSize(width: 240, height: 100)
        let view = stackedRow(placeholderCount: 4, memberCount: 7)
            .frame(width: size.width, height: size.height)
        
        // Then
        AssertSnapshot(view, size: size)
    }
    
    func test_channelAvatar_stackedPlaceholders_overflowClamped() {
        // Given — overflow badge clamps at +99
        let size = CGSize(width: 240, height: 100)
        let view = stackedRow(placeholderCount: 4, memberCount: 200)
            .frame(width: size.width, height: size.height)
        
        // Then
        AssertSnapshot(view, size: size)
    }
    
    func test_channelAvatar_stackedPlaceholders_withOnlineIndicator() {
        // Given — stacked layout with presence indicator
        let size = CGSize(width: 240, height: 100)
        let view = stackedRow(placeholderCount: 2, memberCount: 2, indicator: .online)
            .frame(width: size.width, height: size.height)
        
        // Then
        AssertSnapshot(view, size: size)
    }
    
    // MARK: - Helpers
    
    /// Creates a horizontal row of stacked channel avatars at lg, xl, and 2xl sizes.
    private func stackedRow(
        placeholderCount: Int,
        memberCount: Int,
        indicator: AvatarIndicator = .none
    ) -> some View {
        let initials = ["AB", "CD", "EF", "GH"]
        let placeholders: [(url: URL?, initials: String)] = (0..<placeholderCount).map { i in
            (nil, initials[i % initials.count])
        }
        let sizes: [CGFloat] = [AvatarSize.large, AvatarSize.extraLarge, AvatarSize.extraExtraLarge]
        return HStack(spacing: 8) {
            ForEach(sizes, id: \.self) { size in
                ChannelAvatar(
                    url: nil,
                    size: size,
                    stackedPlaceholders: placeholders,
                    memberCount: memberCount,
                    indicator: indicator
                )
            }
        }
    }
}
