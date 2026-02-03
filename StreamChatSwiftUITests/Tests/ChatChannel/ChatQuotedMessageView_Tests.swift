//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

@MainActor class ChatQuotedMessageView_Tests: StreamChatTestCase {
    private let containerSize = CGSize(width: 360, height: 120)
    private let author = ChatUser.mock(id: "emma", name: "Emma Chen")

    func test_chatQuotedMessageView_outgoing() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Sounds good!",
            author: author,
            isSentByCurrentUser: true
        )
        
        // When
        let view = containerView {
            ChatQuotedMessageView(
                factory: DefaultViewFactory.shared,
                quotedMessage: message,
                scrolledId: .constant(nil)
            )
        }
        
        // Then
        AssertSnapshot(view, size: containerSize)
    }
    
    func test_chatQuotedMessageView_incoming() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Sounds good!",
            author: author,
            isSentByCurrentUser: false
        )
        
        // When
        let view = containerView {
            ChatQuotedMessageView(
                factory: DefaultViewFactory.shared,
                quotedMessage: message,
                scrolledId: .constant(nil)
            )
        }
        
        // Then
        AssertSnapshot(view, size: containerSize)
    }
    
    func test_chatQuotedMessageView_withAttachment() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Check this out!",
            author: author,
            attachments: [
                ChatMessageImageAttachment.mock(
                    id: .unique,
                    imageURL: .localYodaImage
                ).asAnyAttachment
            ],
            isSentByCurrentUser: false
        )
        
        // When
        let view = containerView {
            ChatQuotedMessageView(
                factory: DefaultViewFactory.shared,
                quotedMessage: message,
                scrolledId: .constant(nil)
            )
        }
        
        // Then
        AssertSnapshot(view, size: containerSize)
    }

    // MARK: - Helper

    private func containerView<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ZStack {
            Color(UIColor.systemBackground)
            content()
        }
        .frame(width: containerSize.width, height: containerSize.height)
    }
}
