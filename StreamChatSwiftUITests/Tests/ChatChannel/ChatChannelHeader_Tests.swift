//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

class ChatChannelHeader_Tests: StreamChatTestCase {
    func test_chatChannelHeaderModifier_snapshot() {
        // Given
        let channel = ChatChannel.mockDMChannel(name: "Test channel")

        // When
        let view = NavigationView {
            Text("Test")
                .applyDefaultSize()
                .modifier(DefaultChannelHeaderModifier(channel: channel))
        }
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_chatChannelHeaderModifier_channelAvatarUpdated() {
        // Given
        let channel = ChatChannel.mockDMChannel(name: "Test channel")

        // When
        let view = NavigationView {
            Text("Test")
                .applyDefaultSize()
                .modifier(
                    DefaultChannelHeaderModifier(
                        factory: ChannelAvatarViewFactory(),
                        channel: channel
                    )
                )
        }
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_chatChannelHeader_snapshot() {
        // Given
        let channel = ChatChannel.mockDMChannel(name: "Test channel")

        // When
        let view = NavigationView {
            Text("Test")
                .applyDefaultSize()
                .toolbar {
                    DefaultChatChannelHeader(channel: channel, headerImage: .circleImage, isActive: .constant(false))
                }
        }
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_channelTitleView_snapshot() {
        // Given
        let channel = ChatChannel.mockDMChannel(name: "Test channel")

        // When
        let view = ChannelTitleView(channel: channel, shouldShowTypingIndicator: true)
            .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_channelTitleView_theme_snapshot() {
        // Given
        let channel = ChatChannel.mockDMChannel(name: "Test channel")

        // When
        adjustAppearance { appearance in
            appearance.colors.text = .red
            appearance.colors.subtitleText = .blue
        }
        let size = CGSize(width: 300, height: 100)
        let view = ChannelTitleView(channel: channel, shouldShowTypingIndicator: true)
            .applySize(size)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
}
