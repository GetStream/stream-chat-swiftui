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

@MainActor final class MessageActionsView_Tests: StreamChatTestCase {
    private let snapshotSize = CGSize(width: 300, height: 400)

    func test_messageActionsView_destructiveActionsLast_snapshot() {
        // Given
        let actions = [
            makeAction(title: "Reply", iconName: "arrowshape.turn.up.left"),
            makeAction(title: "Thread Reply", iconName: "text.bubble"),
            makeAction(title: "Copy Message", iconName: "icn_copy"),
            makeAction(title: "Delete Message", iconName: "trash", isDestructive: true),
            makeAction(title: "Block User", iconName: "nosign", isDestructive: true)
        ]

        // When
        let view = MessageActionsView(messageActions: actions)
            .frame(width: snapshotSize.width)

        // Then
        AssertSnapshot(view, size: snapshotSize)
    }

    func test_messageActionsView_destructiveActionsSeparated_snapshot() {
        // Given
        let actions = [
            makeAction(title: "Reply", iconName: "arrowshape.turn.up.left"),
            makeAction(title: "Delete Message", iconName: "trash", isDestructive: true),
            makeAction(title: "Flag Message", iconName: "flag"),
            makeAction(title: "Mute User", iconName: "speaker.slash"),
            makeAction(title: "Block User", iconName: "nosign", isDestructive: true)
        ]

        // When
        let view = MessageActionsView(messageActions: actions)
            .frame(width: snapshotSize.width)

        // Then
        AssertSnapshot(view, size: snapshotSize)
    }

    func test_messageActionsView_onlyDestructiveActions_snapshot() {
        // Given
        let actions = [
            makeAction(title: "Delete Message", iconName: "trash", isDestructive: true),
            makeAction(title: "Block User", iconName: "nosign", isDestructive: true)
        ]

        // When
        let view = MessageActionsView(messageActions: actions)
            .frame(width: snapshotSize.width)

        // Then
        AssertSnapshot(view, size: snapshotSize)
    }

    func test_messageActionsView_noDestructiveActions_snapshot() {
        // Given
        let actions = [
            makeAction(title: "Reply", iconName: "arrowshape.turn.up.left"),
            makeAction(title: "Thread Reply", iconName: "text.bubble"),
            makeAction(title: "Copy Message", iconName: "icn_copy")
        ]

        // When
        let view = MessageActionsView(messageActions: actions)
            .frame(width: snapshotSize.width)

        // Then
        AssertSnapshot(view, size: snapshotSize)
    }

    private func makeAction(
        title: String,
        iconName: String,
        isDestructive: Bool = false
    ) -> MessageAction {
        MessageAction(
            id: title,
            title: title,
            iconName: iconName,
            action: {},
            confirmationPopup: nil,
            isDestructive: isDestructive
        )
    }
}
