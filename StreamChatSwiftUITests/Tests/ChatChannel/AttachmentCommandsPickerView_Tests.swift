//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatCommonUI
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

@MainActor class AttachmentCommandsPickerView_Tests: StreamChatTestCase {
    override func setUp() {
        super.setUp()

        let utils = Utils(
            mediaLoader: MediaLoader_Mock(),
            messageListConfig: MessageListConfig(
                becomesFirstResponderOnOpen: true,
                draftMessagesEnabled: true
            ),
            composerConfig: ComposerConfig(isVoiceRecordingEnabled: true)
        )
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
    }

    func test_attachmentCommandsPickerView_snapshot() {
        // Given
        let channelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        let commands: [CommandHandler] = [
            GiphyCommandHandler(commandSymbol: "/giphy"),
            MuteCommandHandler(channelController: channelController, commandSymbol: "/mute"),
            UnmuteCommandHandler(channelController: channelController, commandSymbol: "/unmute")
        ]

        let view = AttachmentCommandsPickerView(
            instantCommands: commands,
            onCommandSelected: { _ in }
        )
        .frame(width: defaultScreenSize.width, height: 220)

        // Then
        AssertSnapshot(view)
    }

    func test_attachmentCommandsPickerView_accessibilityExtraExtraExtraLarge() {
        // Given
        let channelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
        let commands: [CommandHandler] = [
            GiphyCommandHandler(commandSymbol: "/giphy"),
            MuteCommandHandler(channelController: channelController, commandSymbol: "/mute"),
            UnmuteCommandHandler(channelController: channelController, commandSymbol: "/unmute")
        ]

        let view = AttachmentCommandsPickerView(
            instantCommands: commands,
            onCommandSelected: { _ in }
        )
        .frame(width: defaultScreenSize.width, height: 700)

        // Then
        let traits = UITraitCollection(traitsFrom: [
            UITraitCollection(displayScale: 1),
            UITraitCollection(preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge),
            UITraitCollection(userInterfaceStyle: .light)
        ])
        assertSnapshot(
            matching: view,
            as: .image(perceptualPrecision: precision, layout: .sizeThatFits, traits: traits)
        )
    }
}
