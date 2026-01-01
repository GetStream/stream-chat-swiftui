//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

class MessageAvatarView_Tests: StreamChatTestCase {
    func test_messageAvatarView_defaultPlaceholder_empty() {
        // Given
        let view = MessageAvatarView(
            avatarURL: nil,
            size: CGSize(width: 36, height: 36),
            showOnlineIndicator: false
        )
        .frame(width: 50, height: 50)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_messageAvatarView_defaultPlaceholder_withURL() {
        // Given
        let view = MessageAvatarView(
            avatarURL: URL(string: "https://example.com/avatar.jpg"),
            size: CGSize(width: 36, height: 36),
            showOnlineIndicator: false
        )
        .frame(width: 50, height: 50)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_messageAvatarView_defaultPlaceholder_withOnlineIndicator() {
        // Given
        let view = MessageAvatarView(
            avatarURL: URL(string: "https://example.com/avatar.jpg"),
            size: CGSize(width: 36, height: 36),
            showOnlineIndicator: true
        )
        .frame(width: 50, height: 50)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    // MARK: - Custom Placeholder Tests

    func test_messageAvatarView_customPlaceholder_empty() {
        // Given
        let view = MessageAvatarView(
            avatarURL: nil,
            size: CGSize(width: 36, height: 36),
            showOnlineIndicator: false
        ) { state in
            CustomPlaceholderView(state: state, size: CGSize(width: 36, height: 36))
        }
        .frame(width: 50, height: 50)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_messageAvatarView_customPlaceholder_loading() {
        // Given
        let view = MessageAvatarView(
            avatarURL: URL(string: "https://example.com/avatar.jpg"),
            size: CGSize(width: 36, height: 36),
            showOnlineIndicator: false
        ) { state in
            CustomPlaceholderView(state: state, size: CGSize(width: 36, height: 36))
        }
        .frame(width: 50, height: 50)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_messageAvatarView_customPlaceholder_error() {
        // Given
        struct FakeError: Error {}
        let view = MessageAvatarView(
            avatarURL: URL(string: "https://example.com/avatar.jpg"),
            size: CGSize(width: 36, height: 36),
            showOnlineIndicator: false
        ) { _ in
            CustomPlaceholderView(
                state: .error(FakeError()),
                size: CGSize(width: 36, height: 36)
            )
        }
        .frame(width: 50, height: 50)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
}

// MARK: - Custom Placeholder Views

struct CustomPlaceholderView: View {
    let state: AvatarPlaceholderState
    let size: CGSize
    
    var body: some View {
        Circle()
            .fill(backgroundColor)
            .frame(width: size.width, height: size.height)
            .overlay(
                Image(systemName: iconName)
                    .foregroundColor(.white)
                    .font(.system(size: size.width * 0.4))
            )
    }
    
    private var backgroundColor: Color {
        switch state {
        case .empty:
            return .blue
        case .loading:
            return .orange
        case .error:
            return .red
        }
    }
    
    private var iconName: String {
        switch state {
        case .empty:
            return "person.fill"
        case .loading:
            return "hourglass"
        case .error:
            return "exclamationmark.triangle.fill"
        }
    }
}
