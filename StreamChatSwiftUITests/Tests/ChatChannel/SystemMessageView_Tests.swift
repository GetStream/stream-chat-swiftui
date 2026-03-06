//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

@MainActor class SystemMessageView_Tests: StreamChatTestCase {
    private let containerSize = CGSize(width: 360, height: 80)

    // MARK: - Short Message

    func test_systemMessageView_shortMessage() {
        // Given
        let message = "Channel created"

        // When
        let view = containerView {
            SystemMessageView(message: message)
        }

        // Then
        AssertSnapshot(view, variants: [.defaultLight, .defaultDark], size: containerSize)
    }

    // MARK: - Long Message

    func test_systemMessageView_longMessage() {
        // Given
        let message = "Martin added John Doe and Jane Smith to the channel"

        // When
        let view = containerView {
            SystemMessageView(message: message)
        }

        // Then
        AssertSnapshot(view, variants: [.defaultLight, .defaultDark], size: containerSize)
    }

    // MARK: - Very Long Message (Wraps)

    func test_systemMessageView_veryLongMessage() {
        // Given
        let message = "This is a very long system message that should wrap across multiple lines when displayed in the chat message list view"

        // When
        let view = containerView(height: 120) {
            SystemMessageView(message: message)
        }

        // Then
        AssertSnapshot(view, variants: [.defaultLight, .defaultDark], size: CGSize(width: 360, height: 120))
    }

    // MARK: - Member Added

    func test_systemMessageView_memberAdded() {
        // Given
        let message = "Emma Chen was added to the channel"

        // When
        let view = containerView {
            SystemMessageView(message: message)
        }

        // Then
        AssertSnapshot(view, variants: [.defaultLight, .defaultDark], size: containerSize)
    }

    // MARK: - Member Removed

    func test_systemMessageView_memberRemoved() {
        // Given
        let message = "Emma Chen was removed from the channel"

        // When
        let view = containerView {
            SystemMessageView(message: message)
        }

        // Then
        AssertSnapshot(view, variants: [.defaultLight, .defaultDark], size: containerSize)
    }

    // MARK: - Helper

    private func containerView<Content: View>(
        height: CGFloat = 80,
        @ViewBuilder content: () -> Content
    ) -> some View {
        ZStack {
            Color(UIColor.systemBackground)
            content()
        }
        .frame(width: containerSize.width, height: height)
    }
}
