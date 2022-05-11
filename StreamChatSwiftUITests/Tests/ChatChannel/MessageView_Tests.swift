//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import SwiftUI
import XCTest

class MessageView_Tests: StreamChatTestCase {

    func test_messageViewText_snapshot() {
        // Given
        let textMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "test message",
            author: .mock(id: .unique)
        )
        
        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: textMessage,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image)
    }
    
    func test_messageViewImage_snapshot() {
        // Given
        let imageMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "test message",
            author: .mock(id: .unique),
            attachments: ChatChannelTestHelpers.imageAttachments
        )
        
        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: imageMessage,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image)
    }
    
    func test_messageViewImage_snapshot2Images() {
        // Given
        let imageMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "test message",
            author: .mock(id: .unique),
            attachments: [
                ChatChannelTestHelpers.imageAttachments[0],
                ChatChannelTestHelpers.imageAttachments[0]
            ]
        )
        
        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: imageMessage,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image)
    }

    func test_messageViewImage_snapshot3Images() {
        // Given
        let imageMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "test message",
            author: .mock(id: .unique),
            attachments: [
                ChatChannelTestHelpers.imageAttachments[0],
                ChatChannelTestHelpers.imageAttachments[0],
                ChatChannelTestHelpers.imageAttachments[0]
            ]
        )
        
        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: imageMessage,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image)
    }
    
    func test_messageViewImage_snapshotQuoted() {
        // Given
        let quoted = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "This is a quoted message",
            author: .mock(id: .unique)
        )
        let imageMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "test message",
            author: .mock(id: .unique),
            quotedMessage: quoted,
            attachments: ChatChannelTestHelpers.imageAttachments
        )
        
        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: imageMessage,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image)
    }
    
    func test_messageViewGiphy_snapshot() {
        // Given
        let giphyMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: .mock(id: .unique),
            attachments: ChatChannelTestHelpers.giphyAttachments
        )
        
        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: giphyMessage,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image)
    }
    
    func test_messageViewVideo_snapshot() {
        // Given
        let videoMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: .mock(id: .unique),
            attachments: ChatChannelTestHelpers.videoAttachments
        )
        
        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: videoMessage,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image)
    }
    
    func test_messageViewFile_snapshot() {
        // Given
        let fileMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: .mock(id: .unique),
            attachments: ChatChannelTestHelpers.fileAttachments
        )
        
        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: fileMessage,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image)
    }
    
    func test_messageViewJumboEmoji_snapshot() {
        // Given
        let emojiMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "😀",
            author: .mock(id: .unique)
        )
        
        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: emojiMessage,
            contentWidth: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image)
    }
    
    func test_linkAttachmentView_snapshot() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "https://getstream.io",
            author: .mock(id: .unique)
        )
        
        // When
        let view = LinkAttachmentContainer(
            factory: DefaultViewFactory.shared,
            message: message,
            width: defaultScreenSize.width,
            isFirst: true,
            scrolledId: .constant(nil)
        )
        .applyDefaultSize()
        
        // Then
        assertSnapshot(matching: view, as: .image)
    }
}
