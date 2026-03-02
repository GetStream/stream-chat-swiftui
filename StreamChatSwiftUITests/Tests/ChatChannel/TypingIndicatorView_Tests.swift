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

@MainActor final class TypingIndicatorView_Tests: StreamChatTestCase {
    func test_typingIndicatorView_singleUser() {
        let view = makeTypingIndicatorView(userCount: 1)
        AssertSnapshot(view, size: CGSize(width: 130, height: 60))
    }

    func test_typingIndicatorView_twoUsers() {
        let view = makeTypingIndicatorView(userCount: 2)
        AssertSnapshot(view, size: CGSize(width: 160, height: 60))
    }

    func test_typingIndicatorView_threeUsers() {
        let view = makeTypingIndicatorView(userCount: 3)
        AssertSnapshot(view, size: CGSize(width: 190, height: 60))
    }

    func test_typingIndicatorView_overflow() {
        let view = makeTypingIndicatorView(userCount: 6)
        AssertSnapshot(view, size: CGSize(width: 210, height: 60))
    }

    // MARK: - TypingIndicatorDotsView (dots only)

    func test_typingIndicatorDotsView_snapshot() {
        let view = TypingIndicatorDotsView(isTyping: true)
            .frame(width: 20, height: 16)
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles, size: CGSize(width: 20, height: 16))
    }

    // MARK: - Helpers

    private let allNames = ["AB", "CD", "EF", "GH", "IJ", "KL"]

    private func makeTypingIndicatorView(userCount: Int) -> some View {
        let users: [ChatUser] = (0..<userCount).map { i in
            ChatUser.mock(id: "user-\(i)", name: allNames[i % allNames.count])
        }
        return TypingIndicatorView(users: users, typingText: "Someone is typing")
    }
}
