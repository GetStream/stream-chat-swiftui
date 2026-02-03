//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

@MainActor class ComposerQuotedMessageView_Tests: StreamChatTestCase {
    private let containerSize = CGSize(width: 360, height: 120)
    private let author = ChatUser.mock(id: "emma", name: "Emma Chen")
    
    func test_composerQuotedMessageView_withDismissButton() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "This is a message being quoted",
            author: author,
            isSentByCurrentUser: false
        )
        
        // When
        let view = containerView {
            ComposerQuotedMessageView(
                factory: DefaultViewFactory.shared,
                quotedMessage: message,
                onDismiss: {}
            )
        }

        // Then
        AssertSnapshot(view, size: containerSize)
    }
    
    func test_composerQuotedMessageView_withAttachmentAndDismissButton() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Check out this photo!",
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
            ComposerQuotedMessageView(
                factory: DefaultViewFactory.shared,
                quotedMessage: message,
                onDismiss: {}
            )
        }
        
        // Then
        AssertSnapshot(view, size: containerSize)
    }
    
    func test_composerQuotedMessageView_outgoing() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "My own message",
            author: author,
            isSentByCurrentUser: true
        )
        
        // When
        let view = containerView {
            ComposerQuotedMessageView(
                factory: DefaultViewFactory.shared,
                quotedMessage: message,
                onDismiss: {}
            )
        }
        
        // Then
        AssertSnapshot(view, size: containerSize)
    }
    
    func test_composerQuotedMessageView_longText() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "I'm thinking we could grab brunch at that new café downtown and then head to the park for a walk.",
            author: author,
            isSentByCurrentUser: false
        )
        
        // When
        let view = containerView {
            ComposerQuotedMessageView(
                factory: DefaultViewFactory.shared,
                quotedMessage: message,
                onDismiss: {}
            )
        }
        
        // Then
        AssertSnapshot(view, size: containerSize)
    }
    
    func test_composerQuotedMessageView_withFileAttachment() {
        // Given
        let fileAttachment = ChatMessageFileAttachment(
            id: .unique,
            type: .file,
            payload: FileAttachmentPayload(
                title: "Q4-Report.pdf",
                assetRemoteURL: .localYodaImage,
                file: .init(type: .pdf, size: 1024, mimeType: "application/pdf"),
                extraData: nil
            ),
            downloadingState: nil,
            uploadingState: nil
        )
        
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Here is the Q4 report",
            author: author,
            attachments: [fileAttachment.asAnyAttachment],
            isSentByCurrentUser: false
        )
        
        // When
        let view = containerView {
            ComposerQuotedMessageView(
                factory: DefaultViewFactory.shared,
                quotedMessage: message,
                onDismiss: {}
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
