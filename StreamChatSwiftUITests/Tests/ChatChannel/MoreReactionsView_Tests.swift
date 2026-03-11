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

@MainActor final class MoreReactionsView_Tests: StreamChatTestCase {
    private let snapshotSize = CGSize(width: 360, height: 400)

    func test_moreReactionsView_defaultEmojis_snapshot() {
        // Given / When
        let view = MoreReactionsView(onEmojiTap: { _ in })
            .frame(width: snapshotSize.width, height: snapshotSize.height)

        // Then
        AssertSnapshot(view, size: snapshotSize)
    }

    func test_moreReactionsView_fewEmojis_snapshot() {
        // Given
        adjustAppearance { appearance in
            appearance.images.availableEmojis = [
                ["key": "like", "value": "👍"],
                ["key": "love", "value": "❤️"],
                ["key": "haha", "value": "😂"],
                ["key": "wow", "value": "😮"],
                ["key": "sad", "value": "😢"],
                ["key": "angry", "value": "😠"],
                ["key": "fire", "value": "🔥"],
                ["key": "rocket", "value": "🚀"]
            ]
        }

        // When
        let view = MoreReactionsView(onEmojiTap: { _ in })
            .frame(width: snapshotSize.width, height: snapshotSize.height)

        // Then
        AssertSnapshot(view, size: snapshotSize)
    }
}
