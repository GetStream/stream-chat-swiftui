//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import SwiftUI
import XCTest

class GalleryView_Tests: XCTestCase {

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
    
    func test_galleryView_snapshotLoading() {
        // Given
        let imageMessage = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "test message",
            author: .mock(id: .unique),
            attachments: ChatChannelTestHelpers.imageAttachments
        )
        
        // When
        let view = GalleryView(
            message: imageMessage,
            isShown: .constant(true),
            selected: 0
        )
        .frame(width: defaultScreenSize.width, height: defaultScreenSize.height)
        
        // Then
        assertSnapshot(matching: view, as: .image)
    }
    
    func test_galleryHeader_snapshot() {
        // Given
        let header = GalleryHeaderView(
            title: "Test",
            subtitle: "Subtitle",
            isShown: .constant(true)
        )
        .frame(width: defaultScreenSize.width, height: 44)
        
        // Then
        assertSnapshot(matching: header, as: .image)
    }
    
    func test_gridView_snapshotLoading() {
        // Given
        let view = GridPhotosView(
            imageURLs: [ChatChannelTestHelpers.testURL],
            isShown: .constant(true)
        )
        .frame(width: defaultScreenSize.width, height: defaultScreenSize.height)
        
        // Then
        assertSnapshot(matching: view, as: .image)
    }
}
