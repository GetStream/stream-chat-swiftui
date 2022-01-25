//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import SwiftUI
import XCTest

class ReactionsOverlayView_Tests: StreamChatTestCase {
    
    private let testMessage = ChatMessage.mock(
        id: "test",
        cid: .unique,
        text: "This is a test message 1",
        author: .mock(id: "test", name: "martin")
    )
    
    private let messageDisplayInfo = MessageDisplayInfo(
        message: .mock(id: .unique, cid: .unique, text: "test", author: .mock(id: .unique)),
        frame: CGRect(x: 44, y: 20, width: 80, height: 50),
        contentWidth: 200,
        isFirst: true
    )
        
    private let overlayImage = UIColor
        .black
        .withAlphaComponent(0.2)
        .image(defaultScreenSize)
    
    func test_reactionsOverlayView_snapshot() {
        // Given
        let view = VerticallyCenteredView {
            ReactionsOverlayView(
                factory: DefaultViewFactory.shared,
                channel: .mockDMChannel(),
                currentSnapshot: self.overlayImage,
                messageDisplayInfo: self.messageDisplayInfo,
                onBackgroundTap: {},
                onActionExecuted: { _ in }
            )
            .frame(width: defaultScreenSize.width, height: defaultScreenSize.height)
        }
                
        // Then
        assertSnapshot(matching: view, as: .image)
    }
    
    func test_reactionsOverlayView_noReactions() {
        // Given
        let config = ChannelConfig(reactionsEnabled: false)
        let channel = ChatChannel.mockDMChannel(config: config)
        let view = VerticallyCenteredView {
            ReactionsOverlayView(
                factory: DefaultViewFactory.shared,
                channel: channel,
                currentSnapshot: self.overlayImage,
                messageDisplayInfo: self.messageDisplayInfo,
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
