//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import SwiftUI
import XCTest

class ReactionsOverlayView_Tests: XCTestCase {
    
    private var chatClient: ChatClient = {
        let client = ChatClient.mock()
        client.currentUserId = .unique
        return client
    }()
    
    private let testMessage = ChatMessage.mock(
        id: "test",
        cid: .unique,
        text: "This is a test message 1",
        author: .mock(id: "test", name: "martin")
    )
    
    private var streamChat: StreamChat?
    
    override func setUp() {
        super.setUp()
        streamChat = StreamChat(chatClient: chatClient)
    }

    func test_reactionsOverlayView_snapshot() {
        // Given
        let view = VerticallyCenteredView {
            ReactionsOverlayView(
                factory: DefaultViewFactory.shared,
                channel: .mockDMChannel(),
                currentSnapshot: UIImage(systemName: "checkmark")!,
                messageDisplayInfo: MessageDisplayInfo(
                    message: .mock(id: .unique, cid: .unique, text: "test", author: .mock(id: .unique)),
                    frame: CGRect(x: 20, y: 20, width: 200, height: 100),
                    contentWidth: 200,
                    isFirst: true
                ),
                onBackgroundTap: {},
                onActionExecuted: { _ in }
            )
            .frame(width: defaultScreenSize.width, height: defaultScreenSize.height)
        }
                
        // Then
        assertSnapshot(matching: view, as: .image)
    }
}

struct VerticallyCenteredView<Content: View>: View {
    
    var content: () -> Content
    
    var body: some View {
        VStack {
            Spacer()
            content()
            Spacer()
        }
    }
}
