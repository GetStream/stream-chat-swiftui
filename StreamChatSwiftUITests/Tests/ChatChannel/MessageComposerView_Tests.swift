//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class MessageComposerView_Tests: StreamChatTestCase {

    func test_messageComposerView_snapshot() {
        // Given
        let factory = DefaultViewFactory.shared
        let channelController = ChatChannelTestHelpers.makeChannelController(chatClient: chatClient)
                
        // When
        let view = MessageComposerView(
            viewFactory: factory,
            channelController: channelController,
            messageController: nil,
            quotedMessage: .constant(nil),
            editedMessage: .constant(nil),
            onMessageSent: {}
        )
        .frame(width: defaultScreenSize.width, height: 100)

        // Then
        assertSnapshot(matching: view, as: .image)
    }
    
    func test_composerInputView_slowMode() {
        // Given
        let factory = DefaultViewFactory.shared

        // When
        let view = ComposerInputView(
            factory: factory,
            text: .constant(""),
            selectedRangeLocation: .constant(0),
            command: .constant(nil),
            addedAssets: [],
            addedFileURLs: [],
            addedCustomAttachments: [],
            quotedMessage: .constant(nil),
            cooldownDuration: 15,
            onCustomAttachmentTap: { _ in },
            removeAttachmentWithId: { _ in }
        )
        .frame(width: defaultScreenSize.width, height: 100)
        
        // Then
        assertSnapshot(matching: view, as: .image)
    }
    
    func test_trailingComposerView_snapshot() {
        // Given
        let factory = DefaultViewFactory.shared
        
        // When
        let view = factory.makeTrailingComposerView(
            enabled: true,
            cooldownDuration: 0,
            onTap: {}
        )
        .frame(width: 40, height: 40)
        
        // Then
        assertSnapshot(matching: view, as: .image)
    }
    
    func test_trailingComposerView_slowMode() {
        // Given
        let factory = DefaultViewFactory.shared
        
        // When
        let view = factory.makeTrailingComposerView(
            enabled: true,
            cooldownDuration: 15,
            onTap: {}
        )
        .frame(width: 40, height: 40)
        
        // Then
        assertSnapshot(matching: view, as: .image)
    }
}
