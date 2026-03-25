//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatCommonUI
import SwiftUI

/// A view that renders a horizontal row of overlapping user avatars.
///
/// When more than three avatars are provided, only the first three are shown
/// and a badge displays the remaining count.
public struct AvatarStack: View {
    @Injected(\.colors) var colors
    @Injected(\.tokens) var tokens
    
    let avatars: [(url: URL?, initials: String)]
    let totalCount: Int
    let size: CGFloat
    
    /// Creates an avatar stack.
    ///
    /// - Parameters:
    ///   - avatars: An array of avatar URLs and initials to display.
    ///     Only the first three are shown; any beyond that are represented
    ///     by the overflow badge.
    ///   - totalCount: The total number of avatars, used to compute
    ///     the overflow badge count.
    ///   - size: The size of each avatar in the stack.
    public init(
        avatars: [(url: URL?, initials: String)],
        totalCount: Int,
        size: CGFloat
    ) {
        self.avatars = Array(avatars.prefix(3))
        self.totalCount = totalCount
        self.size = size
    }
    
    private var overflowCount: Int { max(totalCount - avatars.count, 0) }
    private var showsBadge: Bool { overflowCount > 0 }
    
    // MARK: - Body
    
    public var body: some View {
        HStack(spacing: -size / 2 + tokens.spacingXxs) {
            ForEach(avatars.indices, id: \.self) { index in
                avatarView(
                    url: avatars[index].url,
                    initials: avatars[index].initials,
                    outerBorder: index > avatars.startIndex
                )
                .zIndex(Double(index))
            }
            if showsBadge {
                BadgeCountView(count: overflowCount, size: size)
                    .zIndex(Double(avatars.count))
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("AvatarStack")
    }
    
    // MARK: - Subviews
    
    private func avatarView(url: URL?, initials: String, outerBorder: Bool) -> some View {
        UserAvatar(url: url, initials: initials, size: size, indicator: .none, showsBorder: false)
            .overlay(outerBorder ? Circle().inset(by: -1).stroke(colors.borderCoreInverse.toColor, lineWidth: 2) : nil)
    }
}
