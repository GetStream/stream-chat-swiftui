//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import SwiftUI
import XCTest

class MessageView_Tests: XCTestCase {

    private var chatClient: ChatClient = {
        let client = ChatClient.mock()
        client.currentUserId = .unique
        return client
    }()
    
    private var streamChat: StreamChat?
    
    override func setUp() {
        super.setUp()
        streamChat = StreamChat(chatClient: chatClient)
    }
    
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
            isFirst: true
        )
        .frame(width: defaultScreenSize.width, height: defaultScreenSize.height)

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
            isFirst: true
        )
        .frame(width: defaultScreenSize.width, height: defaultScreenSize.height)

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
            isFirst: true
        )
        .frame(width: defaultScreenSize.width, height: defaultScreenSize.height)

        // Then
        assertSnapshot(matching: view, as: .image)
    }
    
    func test_messageViewLink_snapshot() {
        // Given
        let linkMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: .mock(id: .unique),
            attachments: ChatChannelTestHelpers.linkAttachments
        )
        
        // When
        let view = MessageView(
            factory: DefaultViewFactory.shared,
            message: linkMessage,
            contentWidth: defaultScreenSize.width,
            isFirst: true
        )
        .frame(width: defaultScreenSize.width, height: defaultScreenSize.height)

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
            isFirst: true
        )
        .frame(width: defaultScreenSize.width, height: defaultScreenSize.height)

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
            isFirst: true
        )
        .frame(width: defaultScreenSize.width, height: defaultScreenSize.height)

        // Then
        assertSnapshot(matching: view, as: .image)
    }
}
