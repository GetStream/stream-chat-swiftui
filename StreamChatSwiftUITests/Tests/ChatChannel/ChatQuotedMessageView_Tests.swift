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
    private let quotedViewSize = CGSize(width: 290, height: 56)
    private let containerSize = CGSize(width: 360, height: 120)
    private let author = ChatUser.mock(id: "emma", name: "Emma Chen")

    // MARK: - Reply - Text (Short)
    
    func test_chatQuotedMessageView_textShort_outgoing() {
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
            ChatQuotedMessageView(message: message)
        }
        
        // Then
        AssertSnapshot(view, size: containerSize)
    }
    
    func test_chatQuotedMessageView_textShort_incoming() {
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
            ChatQuotedMessageView(message: message)
        }
        
        // Then
        AssertSnapshot(view, size: containerSize)
    }
    
    // MARK: - Reply - Text (Long)
    
    func test_chatQuotedMessageView_textLong() {
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
            ChatQuotedMessageView(message: message)
        }
        
        // Then
        AssertSnapshot(view, size: containerSize)
    }
    
    // MARK: - Reply - Link
    
    func test_chatQuotedMessageView_link() {
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
            isSentByCurrentUser: false
        )
        
        // When
        let view = containerView {
            ChatQuotedMessageView(message: message)
        }
        
        // Then
        AssertSnapshot(view, size: containerSize)
    }
    
    // MARK: - Reply - Photo (Single, Caption)
    
    func test_chatQuotedMessageView_photoSingleWithCaption() {
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
            isSentByCurrentUser: false
        )
        
        // When
        let view = containerView {
            ChatQuotedMessageView(message: message)
        }
        
        // Then
        AssertSnapshot(view, size: containerSize)
    }
    
    // MARK: - Reply - Photo (Single, No Caption)
    
    func test_chatQuotedMessageView_photoSingleNoCaption() {
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
            isSentByCurrentUser: false
        )
        
        // When
        let view = containerView {
            ChatQuotedMessageView(message: message)
        }
        
        // Then
        AssertSnapshot(view, size: containerSize)
    }
    
    // MARK: - Reply - Photo (Multiple, Caption)
    
    func test_chatQuotedMessageView_photoMultipleWithCaption() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "I love these mountains",
            author: author,
            attachments: [
                ChatMessageImageAttachment.mock(id: .unique, imageURL: .localYodaImage).asAnyAttachment,
                ChatMessageImageAttachment.mock(id: .unique, imageURL: .localYodaImage).asAnyAttachment,
                ChatMessageImageAttachment.mock(id: .unique, imageURL: .localYodaImage).asAnyAttachment
            ],
            isSentByCurrentUser: false
        )
        
        // When
        let view = containerView {
            ChatQuotedMessageView(message: message)
        }
        
        // Then
        AssertSnapshot(view, size: containerSize)
    }
    
    // MARK: - Reply - Photo (Multiple, No Caption)
    
    func test_chatQuotedMessageView_photoMultipleNoCaption() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: author,
            attachments: [
                ChatMessageImageAttachment.mock(id: .unique, imageURL: .localYodaImage).asAnyAttachment,
                ChatMessageImageAttachment.mock(id: .unique, imageURL: .localYodaImage).asAnyAttachment,
                ChatMessageImageAttachment.mock(id: .unique, imageURL: .localYodaImage).asAnyAttachment,
                ChatMessageImageAttachment.mock(id: .unique, imageURL: .localYodaImage).asAnyAttachment,
                ChatMessageImageAttachment.mock(id: .unique, imageURL: .localYodaImage).asAnyAttachment,
                ChatMessageImageAttachment.mock(id: .unique, imageURL: .localYodaImage).asAnyAttachment
            ],
            isSentByCurrentUser: false
        )
        
        // When
        let view = containerView {
            ChatQuotedMessageView(message: message)
        }
        
        // Then
        AssertSnapshot(view, size: containerSize)
    }
    
    // MARK: - Reply - Video (Single, Caption)
    
    func test_chatQuotedMessageView_videoSingleWithCaption() {
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
            text: "I took a short clip earlier",
            author: author,
            attachments: [videoAttachment.asAnyAttachment],
            isSentByCurrentUser: false
        )
        
        // When
        let view = containerView {
            ChatQuotedMessageView(message: message)
        }
        
        // Then
        AssertSnapshot(view, size: containerSize)
    }
    
    // MARK: - Reply - Video (Single, No Caption)
    
    func test_chatQuotedMessageView_videoSingleNoCaption() {
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
            isSentByCurrentUser: false
        )
        
        // When
        let view = containerView {
            ChatQuotedMessageView(message: message)
        }
        
        // Then
        AssertSnapshot(view, size: containerSize)
    }
    
    // MARK: - Reply - Video (Multiple, Caption)
    
    func test_chatQuotedMessageView_videoMultipleWithCaption() {
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
            text: "I took some videos today",
            author: author,
            attachments: [videoAttachment(), videoAttachment(), videoAttachment()],
            isSentByCurrentUser: false
        )
        
        // When
        let view = containerView {
            ChatQuotedMessageView(message: message)
        }
        
        // Then
        AssertSnapshot(view, size: containerSize)
    }
    
    // MARK: - Reply - Video (Multiple, No Caption)
    
    func test_chatQuotedMessageView_videoMultipleNoCaption() {
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
            attachments: [
                videoAttachment(), videoAttachment(), videoAttachment(),
                videoAttachment(), videoAttachment(), videoAttachment()
            ],
            isSentByCurrentUser: false
        )
        
        // When
        let view = containerView {
            ChatQuotedMessageView(message: message)
        }
        
        // Then
        AssertSnapshot(view, size: containerSize)
    }
    
    // MARK: - Reply - Mixed Content (Caption)
    
    func test_chatQuotedMessageView_mixedContentWithCaption() {
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
            text: "I'm sending you some photos and files",
            author: author,
            attachments: [imageAttachment, fileAttachment],
            isSentByCurrentUser: false
        )
        
        // When
        let view = containerView {
            ChatQuotedMessageView(message: message)
        }
        
        // Then
        AssertSnapshot(view, size: containerSize)
    }
    
    // MARK: - Reply - Mixed Content (No Caption)
    
    func test_chatQuotedMessageView_mixedContentNoCaption() {
        // Given
        let imageAttachment = ChatMessageImageAttachment.mock(
            id: .unique,
            imageURL: .localYodaImage
        ).asAnyAttachment
        
        let fileAttachment = { () -> AnyChatMessageAttachment in
            ChatMessageFileAttachment(
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
        }
        
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: author,
            attachments: [
                imageAttachment,
                fileAttachment(), fileAttachment(), fileAttachment(),
                fileAttachment(), fileAttachment()
            ],
            isSentByCurrentUser: false
        )
        
        // When
        let view = containerView {
            ChatQuotedMessageView(message: message)
        }
        
        // Then
        AssertSnapshot(view, size: containerSize)
    }
    
    // MARK: - Reply - Voice Message (Caption)
    
    func test_chatQuotedMessageView_voiceMessageWithCaption() {
        // Given
        let voiceAttachment = ChatMessageVoiceRecordingAttachment(
            id: .unique,
            type: .voiceRecording,
            payload: VoiceRecordingAttachmentPayload(
                title: "Recording",
                voiceRecordingRemoteURL: .localYodaImage,
                file: try! .init(url: .localYodaQuote),
                duration: 12,
                waveformData: [0, 0.3, 0.6, 1],
                extraData: nil
            ),
            downloadingState: nil,
            uploadingState: nil
        )
        
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Here's a quick voice note",
            author: author,
            attachments: [voiceAttachment.asAnyAttachment],
            isSentByCurrentUser: false
        )
        
        // When
        let view = containerView {
            ChatQuotedMessageView(message: message)
        }
        
        // Then
        AssertSnapshot(view, size: containerSize)
    }
    
    // MARK: - Reply - Voice Message (No Caption)
    
    func test_chatQuotedMessageView_voiceMessageNoCaption() {
        // Given
        let voiceAttachment = ChatMessageVoiceRecordingAttachment(
            id: .unique,
            type: .voiceRecording,
            payload: VoiceRecordingAttachmentPayload(
                title: "Recording",
                voiceRecordingRemoteURL: .localYodaImage,
                file: try! .init(url: .localYodaQuote),
                duration: 12,
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
            isSentByCurrentUser: false
        )
        
        // When
        let view = containerView {
            ChatQuotedMessageView(message: message)
        }
        
        // Then
        AssertSnapshot(view, size: containerSize)
    }
    
    // MARK: - Reply - File (Single, Caption)
    
    func test_chatQuotedMessageView_fileSingleWithCaption() {
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
            ChatQuotedMessageView(message: message)
        }
        
        // Then
        AssertSnapshot(view, size: containerSize)
    }
    
    // MARK: - Reply - File (Single, No Caption)
    
    func test_chatQuotedMessageView_fileSingleNoCaption() {
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
            isSentByCurrentUser: false
        )
        
        // When
        let view = containerView {
            ChatQuotedMessageView(message: message)
        }
        
        // Then
        AssertSnapshot(view, size: containerSize)
    }
    
    // MARK: - Reply - Poll
    
    func test_chatQuotedMessageView_poll() {
        // Given
        let poll = Poll.mock(name: "Where should we host the next team offsite?")
        
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: author,
            isSentByCurrentUser: false,
            poll: poll
        )
        
        // When
        let view = containerView {
            ChatQuotedMessageView(message: message)
        }
        
        // Then
        AssertSnapshot(view, size: containerSize)
    }
    
    // MARK: - ComposerQuotedMessageView Tests
    
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
            ComposerQuotedMessageView(message: message, onDismiss: {})
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
            ComposerQuotedMessageView(message: message, onDismiss: {})
        }
        
        // Then
        AssertSnapshot(view, size: containerSize)
    }
    
    // MARK: - ViewModel Tests
    
    func test_quotedMessageViewModel_title() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Test message",
            author: author
        )
        let viewModel = QuotedMessageViewModel(message: message)
        
        // Then
        XCTAssertEqual(viewModel.title, "Reply to Emma Chen")
        XCTAssertEqual(viewModel.authorName, "Emma Chen")
    }
    
    func test_quotedMessageViewModel_subtitleWithText() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hello world",
            author: author
        )
        let viewModel = QuotedMessageViewModel(message: message)
        
        // Then
        XCTAssertEqual(viewModel.subtitle, "Hello world")
        XCTAssertNil(viewModel.subtitleIconName)
    }
    
    func test_quotedMessageViewModel_subtitleWithImage() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: author,
            attachments: [
                ChatMessageImageAttachment.mock(id: .unique, imageURL: .localYodaImage).asAnyAttachment
            ]
        )
        let viewModel = QuotedMessageViewModel(message: message)
        
        // Then
        XCTAssertEqual(viewModel.subtitle, "Photo")
        XCTAssertEqual(viewModel.subtitleIconName, "photo")
    }
    
    func test_quotedMessageViewModel_subtitleWithMultipleImages() {
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
            ]
        )
        let viewModel = QuotedMessageViewModel(message: message)
        
        // Then
        XCTAssertEqual(viewModel.subtitle, "3 photos")
        XCTAssertEqual(viewModel.subtitleIconName, "photo")
    }
    
    func test_quotedMessageViewModel_subtitleWithVoiceMessage() {
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
            attachments: [voiceAttachment.asAnyAttachment]
        )
        let viewModel = QuotedMessageViewModel(message: message)
        
        // Then
        XCTAssertEqual(viewModel.subtitle, "Voice message (1:12)")
        XCTAssertEqual(viewModel.subtitleIconName, "mic")
    }
    
    func test_quotedMessageViewModel_subtitleWithPoll() {
        // Given
        let poll = Poll.mock(name: "Team offsite location?")
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: author,
            poll: poll
        )
        let viewModel = QuotedMessageViewModel(message: message)
        
        // Then
        XCTAssertEqual(viewModel.subtitle, "Team offsite location?")
        XCTAssertEqual(viewModel.subtitleIconName, "chart.bar")
    }

    // MARK: - Helper

    /// Wraps the quoted message view in a container to visualize corner radius properly
    private func containerView<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ZStack {
            Color(UIColor.systemBackground)
            content()
                .frame(width: quotedViewSize.width, height: quotedViewSize.height)
        }
        .frame(width: containerSize.width, height: containerSize.height)
    }
}
