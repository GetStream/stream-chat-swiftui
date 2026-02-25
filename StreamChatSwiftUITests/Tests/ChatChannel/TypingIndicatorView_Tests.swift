//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

@MainActor final class TypingIndicatorView_Tests: StreamChatTestCase {
    // MARK: - Group message (small avatars)

    func test_typingIndicatorView_singleUser() {
        let view = makeTypingIndicatorView(userCount: 1, size: AvatarSize.small)
        AssertSnapshot(view, size: CGSize(width: 120, height: 60))
    }

    func test_typingIndicatorView_twoUsers() {
        let view = makeTypingIndicatorView(userCount: 2, size: AvatarSize.small)
        AssertSnapshot(view, size: CGSize(width: 150, height: 60))
    }

    func test_typingIndicatorView_threeUsers() {
        let view = makeTypingIndicatorView(userCount: 3, size: AvatarSize.small)
        AssertSnapshot(view, size: CGSize(width: 180, height: 60))
    }

    func test_typingIndicatorView_overflow() {
        let view = makeTypingIndicatorView(userCount: 6, size: AvatarSize.small)
        AssertSnapshot(view, size: CGSize(width: 200, height: 60))
    }

    // MARK: - Direct message (medium avatar)

    func test_typingIndicatorView_directMessage() {
        let view = makeTypingIndicatorView(userCount: 1, size: AvatarSize.medium)
        AssertSnapshot(view, size: CGSize(width: 130, height: 60))
    }

    // MARK: - TypingIndicatorDotsView (dots only)

    func test_typingIndicatorDotsView_snapshot() {
        let view = TypingIndicatorDotsView(isTyping: true)
            .frame(width: 20, height: 16)
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles, size: CGSize(width: 20, height: 16))
    }

    // MARK: - Helpers

    private let allInitials = ["AB", "CD", "EF", "GH", "IJ", "KL"]

    private func makeTypingIndicatorView(userCount: Int, size: CGFloat) -> some View {
        let avatars: [(url: URL?, initials: String)] = (0..<userCount).map { i in
            (nil, allInitials[i % allInitials.count])
        }
        return TypingIndicatorView(typingUsers: avatars, avatarSize: size)
    }
}
