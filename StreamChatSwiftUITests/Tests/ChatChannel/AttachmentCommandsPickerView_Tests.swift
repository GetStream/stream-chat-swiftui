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

        let imageLoader = TestImagesLoader_Mock()
        let utils = Utils(
            imageLoader: imageLoader,
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
        let view = AttachmentCommandsPickerView(onCommandSelected: { _ in })
            .frame(width: defaultScreenSize.width, height: 220)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_attachmentSourcePickerView_commands_snapshot() {
        // Given
        let view = AttachmentSourcePickerView(
            selected: .commands,
            canSendPoll: true,
            onTap: { _ in }
        )
        .frame(width: defaultScreenSize.width, height: 56)

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
}
