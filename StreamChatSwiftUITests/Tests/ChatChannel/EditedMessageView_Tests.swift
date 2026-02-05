//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

@MainActor class EditedMessageView_Tests: StreamChatTestCase {
    private let containerSize = CGSize(width: 360, height: 120)
    private let author = ChatUser.mock(id: "emma", name: "Emma Chen")

    // MARK: - Edit - Text (Short)
    
    func test_editedMessageView_textShort() {
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
            EditedMessageView(message: message)
        }
        
        // Then
        AssertSnapshot(view, variants: [.defaultLight], size: containerSize)
    }
    
    // MARK: - Edit - Text (Long)
    
    func test_editedMessageView_textLong() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "I'm thinking we could grab brunch at that new café downtown and then head to the park for a walk.",
            author: author,
            isSentByCurrentUser: true
        )
        
        // When
        let view = containerView {
            EditedMessageView(message: message)
        }
        
        // Then
        AssertSnapshot(view, variants: [.defaultLight], size: containerSize)
    }
    
    // MARK: - Edit - Link
    
    func test_editedMessageView_link() {
        // Given
        let linkAttachment = ChatMessageLinkAttachment(
            id: .unique,
            type: .linkPreview,
            payload: LinkAttachmentPayload(
                originalURL: URL(string: "https://bloomharbor.com/cafe-menu")!,
                title: "Bloom Harbor Cafe",
                text: "Check out our menu",
                author: nil,
                titleLink: nil,
                assetURL: nil,
                previewURL: URL(string: "https://bloomharbor.com/cafe-menu")!
            ),
            downloadingState: nil,
            uploadingState: nil
        )
        
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Looks cozy, right? https://bloomharbor.com/cafe-menu",
            author: author,
            attachments: [linkAttachment.asAnyAttachment],
            isSentByCurrentUser: true
        )
        
        // When
        let view = containerView {
            EditedMessageView(message: message)
        }
        
        // Then
        AssertSnapshot(view, variants: [.defaultLight], size: containerSize)
    }
    
    // MARK: - Edit - Photo (Single, Caption)
    
    func test_editedMessageView_photoSingleWithCaption() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "I think this one could work. Took a short clip earlier.",
            author: author,
            attachments: [
                ChatMessageImageAttachment.mock(
                    id: .unique,
                    imageURL: .localYodaImage
                ).asAnyAttachment
            ],
            isSentByCurrentUser: true
        )
        
        // When
        let view = containerView {
            EditedMessageView(message: message)
        }
        
        // Then
        AssertSnapshot(view, variants: [.defaultLight], size: containerSize)
    }
    
    // MARK: - Edit - Photo (Single, No Caption)
    
    func test_editedMessageView_photoSingleNoCaption() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: author,
            attachments: [
                ChatMessageImageAttachment.mock(
                    id: .unique,
                    imageURL: .localYodaImage
                ).asAnyAttachment
            ],
            isSentByCurrentUser: true
        )
        
        // When
        let view = containerView {
            EditedMessageView(message: message)
        }
        
        // Then
        AssertSnapshot(view, variants: [.defaultLight], size: containerSize)
    }
    
    // MARK: - Edit - Photo (Multiple, No Caption)
    
    func test_editedMessageView_photoMultipleNoCaption() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: author,
            attachments: [
                ChatMessageImageAttachment.mock(id: .unique, imageURL: .localYodaImage).asAnyAttachment,
                ChatMessageImageAttachment.mock(id: .unique, imageURL: .localYodaImage).asAnyAttachment,
                ChatMessageImageAttachment.mock(id: .unique, imageURL: .localYodaImage).asAnyAttachment
            ],
            isSentByCurrentUser: true
        )
        
        // When
        let view = containerView {
            EditedMessageView(message: message)
        }
        
        // Then
        AssertSnapshot(view, variants: [.defaultLight], size: containerSize)
    }
    
    // MARK: - Edit - Video (Single, No Caption)
    
    func test_editedMessageView_videoSingleNoCaption() {
        // Given
        let videoAttachment = ChatMessageVideoAttachment(
            id: .unique,
            type: .video,
            payload: VideoAttachmentPayload(
                title: "video.mp4",
                videoRemoteURL: .localYodaImage,
                thumbnailURL: .localYodaImage,
                file: .init(type: .mp4, size: 1024, mimeType: "video/mp4"),
                extraData: nil
            ),
            downloadingState: nil,
            uploadingState: nil
        )
        
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: author,
            attachments: [videoAttachment.asAnyAttachment],
            isSentByCurrentUser: true
        )
        
        // When
        let view = containerView {
            EditedMessageView(message: message)
        }
        
        // Then
        AssertSnapshot(view, variants: [.defaultLight], size: containerSize)
    }
    
    // MARK: - Edit - Video (Multiple, No Caption)
    
    func test_editedMessageView_videoMultipleNoCaption() {
        // Given
        let videoAttachment = { () -> AnyChatMessageAttachment in
            ChatMessageVideoAttachment(
                id: .unique,
                type: .video,
                payload: VideoAttachmentPayload(
                    title: "video.mp4",
                    videoRemoteURL: .localYodaImage,
                    thumbnailURL: .localYodaImage,
                    file: .init(type: .mp4, size: 1024, mimeType: "video/mp4"),
                    extraData: nil
                ),
                downloadingState: nil,
                uploadingState: nil
            ).asAnyAttachment
        }
        
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: author,
            attachments: [videoAttachment(), videoAttachment(), videoAttachment()],
            isSentByCurrentUser: true
        )
        
        // When
        let view = containerView {
            EditedMessageView(message: message)
        }
        
        // Then
        AssertSnapshot(view, variants: [.defaultLight], size: containerSize)
    }
    
    // MARK: - Edit - Mixed Content (No Caption)
    
    func test_editedMessageView_mixedContentNoCaption() {
        // Given
        let imageAttachment = ChatMessageImageAttachment.mock(
            id: .unique,
            imageURL: .localYodaImage
        ).asAnyAttachment

        let fileAttachment = ChatMessageFileAttachment(
            id: .unique,
            type: .file,
            payload: FileAttachmentPayload(
                title: "document.pdf",
                assetRemoteURL: .localYodaImage,
                file: .init(type: .pdf, size: 1024, mimeType: "application/pdf"),
                extraData: nil
            ),
            downloadingState: nil,
            uploadingState: nil
        ).asAnyAttachment
        
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: author,
            attachments: [imageAttachment, fileAttachment],
            isSentByCurrentUser: true
        )
        
        // When
        let view = containerView {
            EditedMessageView(message: message)
        }
        
        // Then
        AssertSnapshot(view, variants: [.defaultLight], size: containerSize)
    }
    
    // MARK: - Edit - Voice Message (No Caption)
    
    func test_editedMessageView_voiceMessageNoCaption() {
        // Given
        let voiceAttachment = ChatMessageVoiceRecordingAttachment(
            id: .unique,
            type: .voiceRecording,
            payload: VoiceRecordingAttachmentPayload(
                title: "Recording",
                voiceRecordingRemoteURL: .localYodaImage,
                file: try! .init(url: .localYodaQuote),
                duration: 72,
                waveformData: [0, 0.3, 0.6, 1],
                extraData: nil
            ),
            downloadingState: nil,
            uploadingState: nil
        )
        
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: author,
            attachments: [voiceAttachment.asAnyAttachment],
            isSentByCurrentUser: true
        )
        
        // When
        let view = containerView {
            EditedMessageView(message: message)
        }
        
        // Then
        AssertSnapshot(view, variants: [.defaultLight], size: containerSize)
    }
    
    // MARK: - Edit - File (Single, No Caption)
    
    func test_editedMessageView_fileSingleNoCaption() {
        // Given
        let fileAttachment = ChatMessageFileAttachment(
            id: .unique,
            type: .file,
            payload: FileAttachmentPayload(
                title: "bloom-and-harbor-cafe-menu-summer-2024.pdf",
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
            text: "",
            author: author,
            attachments: [fileAttachment.asAnyAttachment],
            isSentByCurrentUser: true
        )
        
        // When
        let view = containerView {
            EditedMessageView(message: message)
        }
        
        // Then
        AssertSnapshot(view, variants: [.defaultLight], size: containerSize)
    }
    
    // MARK: - Edit - Poll
    
    func test_editedMessageView_poll() {
        // Given
        let poll = Poll.mock(name: "Where should we host the next team offsite?")
        
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: author,
            isSentByCurrentUser: true,
            poll: poll
        )
        
        // When
        let view = containerView {
            EditedMessageView(message: message)
        }
        
        // Then
        AssertSnapshot(view, variants: [.defaultLight], size: containerSize)
    }

    // MARK: - Helper

    /// Wraps the edited message view in a container to visualize corner radius properly
    private func containerView<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ZStack {
            Color(UIColor.systemBackground)
            content()
                .frame(width: 340, height: 100)
        }
        .frame(width: containerSize.width, height: containerSize.height)
    }
}

// MARK: - Factory Helpers

extension EditedMessageView where Factory == DefaultViewFactory {
    init(message: ChatMessage) {
        self.init(
            factory: DefaultViewFactory.shared,
            viewModel: EditedMessageViewModel(message: message),
            onDismiss: {}
        )
    }
}
