//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import StreamSwiftTestHelpers
import XCTest

@MainActor class MessageAttachmentPreviewResolver_Tests: StreamChatTestCase {
    private let author = ChatUser.mock(id: "emma", name: "Emma Chen")

    // MARK: - No Attachments

    func test_resolver_noAttachments() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Hello world",
            author: author
        )
        
        // When
        let resolver = MessageAttachmentPreviewResolver(message: message)
        
        // Then
        XCTAssertNil(resolver.previewDescription)
        XCTAssertNil(resolver.previewIcon)
        XCTAssertNil(resolver.previewThumbnail)
    }

    // MARK: - Single Image

    func test_resolver_singleImage() {
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
        
        // When
        let resolver = MessageAttachmentPreviewResolver(message: message)
        
        // Then
        XCTAssertEqual(resolver.previewDescription, "Photo")
        XCTAssertEqual(resolver.previewIcon, .photo)
        XCTAssertNotNil(resolver.previewThumbnail)
        XCTAssertEqual(resolver.previewThumbnail?.url, .localYodaImage)
        XCTAssertTrue(resolver.previewThumbnail?.isImage == true)
    }

    func test_resolver_multipleImages() {
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
        
        // When
        let resolver = MessageAttachmentPreviewResolver(message: message)
        
        // Then
        XCTAssertEqual(resolver.previewDescription, "3 photos")
        XCTAssertEqual(resolver.previewIcon, .photo)
        XCTAssertNotNil(resolver.previewThumbnail)
        XCTAssertEqual(resolver.previewThumbnail?.url, .localYodaImage)
        XCTAssertEqual(resolver.previewThumbnail?.isImage, true)
    }

    // MARK: - Video

    func test_resolver_singleVideo() {
        // Given
        let thumbnailURL = URL(string: "https://example.com/thumb.jpg")!
        let videoAttachment = ChatMessageVideoAttachment(
            id: .unique,
            type: .video,
            payload: VideoAttachmentPayload(
                title: "video.mp4",
                videoRemoteURL: URL(string: "https://example.com/video.mp4")!,
                thumbnailURL: thumbnailURL,
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
            attachments: [videoAttachment.asAnyAttachment]
        )
        
        // When
        let resolver = MessageAttachmentPreviewResolver(message: message)
        
        // Then
        XCTAssertEqual(resolver.previewDescription, "Video")
        XCTAssertEqual(resolver.previewIcon, .video)
        XCTAssertNotNil(resolver.previewThumbnail)
        XCTAssertEqual(resolver.previewThumbnail?.url, thumbnailURL)
        XCTAssertTrue(resolver.previewThumbnail?.isVideo == true)
    }

    func test_resolver_multipleVideos() {
        // Given
        let thumbnailURL = URL(string: "https://example.com/thumb.jpg")!
        let videoAttachment = { () -> AnyChatMessageAttachment in
            ChatMessageVideoAttachment(
                id: .unique,
                type: .video,
                payload: VideoAttachmentPayload(
                    title: "video.mp4",
                    videoRemoteURL: URL(string: "https://example.com/video.mp4")!,
                    thumbnailURL: thumbnailURL,
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
            attachments: [videoAttachment(), videoAttachment()]
        )
        
        // When
        let resolver = MessageAttachmentPreviewResolver(message: message)
        
        // Then
        XCTAssertEqual(resolver.previewDescription, "2 videos")
        XCTAssertEqual(resolver.previewIcon, .video)
        XCTAssertNotNil(resolver.previewThumbnail)
        XCTAssertEqual(resolver.previewThumbnail?.url, thumbnailURL)
        XCTAssertEqual(resolver.previewThumbnail?.isVideo, true)
    }

    // MARK: - File

    func test_resolver_singleFile() {
        // Given
        let assetURL = URL(string: "https://example.com/document.pdf")!
        let fileAttachment = ChatMessageFileAttachment(
            id: .unique,
            type: .file,
            payload: FileAttachmentPayload(
                title: "Q4-Report.pdf",
                assetRemoteURL: assetURL,
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
            attachments: [fileAttachment.asAnyAttachment]
        )
        
        // When
        let resolver = MessageAttachmentPreviewResolver(message: message)
        
        // Then
        XCTAssertEqual(resolver.previewDescription, "Q4-Report.pdf")
        XCTAssertEqual(resolver.previewIcon, .document)
        XCTAssertNotNil(resolver.previewThumbnail)
        XCTAssertEqual(resolver.previewThumbnail?.url, assetURL)
        XCTAssertTrue(resolver.previewThumbnail?.isFile == true)
    }

    func test_resolver_singleFileWithoutTitle() {
        // Given
        let assetURL = URL(string: "https://example.com/document.pdf")!
        let fileAttachment = ChatMessageFileAttachment(
            id: .unique,
            type: .file,
            payload: FileAttachmentPayload(
                title: nil,
                assetRemoteURL: assetURL,
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
            attachments: [fileAttachment.asAnyAttachment]
        )
        
        // When
        let resolver = MessageAttachmentPreviewResolver(message: message)
        
        // Then
        XCTAssertEqual(resolver.previewDescription, "File")
        XCTAssertEqual(resolver.previewIcon, .document)
        XCTAssertNotNil(resolver.previewThumbnail)
        XCTAssertEqual(resolver.previewThumbnail?.url, assetURL)
        XCTAssertEqual(resolver.previewThumbnail?.isFile, true)
    }

    func test_resolver_multipleFiles() {
        // Given
        let assetURL = URL(string: "https://example.com/document.pdf")!
        let fileAttachment = { () -> AnyChatMessageAttachment in
            ChatMessageFileAttachment(
                id: .unique,
                type: .file,
                payload: FileAttachmentPayload(
                    title: "document.pdf",
                    assetRemoteURL: assetURL,
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
            attachments: [fileAttachment(), fileAttachment(), fileAttachment()]
        )
        
        // When
        let resolver = MessageAttachmentPreviewResolver(message: message)
        
        // Then
        XCTAssertEqual(resolver.previewDescription, "3 files")
        XCTAssertEqual(resolver.previewIcon, .document)
        XCTAssertNotNil(resolver.previewThumbnail)
        XCTAssertEqual(resolver.previewThumbnail?.url, assetURL)
        XCTAssertEqual(resolver.previewThumbnail?.isFile, true)
    }

    // MARK: - Voice Recording

    func test_resolver_voiceRecordingWithDuration() {
        // Given
        let voiceAttachment = ChatMessageVoiceRecordingAttachment(
            id: .unique,
            type: .voiceRecording,
            payload: VoiceRecordingAttachmentPayload(
                title: "Recording",
                voiceRecordingRemoteURL: URL(string: "https://example.com/voice.m4a")!,
                file: .init(type: .m4a, size: 1024, mimeType: "audio/m4a"),
                duration: 72, // 1:12
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
        
        // When
        let resolver = MessageAttachmentPreviewResolver(message: message)
        
        // Then
        XCTAssertEqual(resolver.previewDescription, "Voice message (01:12)")
        XCTAssertEqual(resolver.previewIcon, .voiceRecording)
        XCTAssertNil(resolver.previewThumbnail)
    }

    func test_resolver_voiceRecordingWithoutDuration() {
        // Given
        let voiceAttachment = ChatMessageVoiceRecordingAttachment(
            id: .unique,
            type: .voiceRecording,
            payload: VoiceRecordingAttachmentPayload(
                title: "Recording",
                voiceRecordingRemoteURL: URL(string: "https://example.com/voice.m4a")!,
                file: .init(type: .m4a, size: 1024, mimeType: "audio/m4a"),
                duration: nil,
                waveformData: nil,
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
        
        // When
        let resolver = MessageAttachmentPreviewResolver(message: message)
        
        // Then
        XCTAssertEqual(resolver.previewDescription, "Voice message")
        XCTAssertEqual(resolver.previewIcon, .voiceRecording)
        XCTAssertNil(resolver.previewThumbnail)
    }

    // MARK: - Link

    func test_resolver_linkWithPreview() {
        // Given
        let previewURL = URL(string: "https://example.com/preview.jpg")!
        let linkAttachment = ChatMessageLinkAttachment(
            id: .unique,
            type: .linkPreview,
            payload: LinkAttachmentPayload(
                originalURL: URL(string: "https://example.com")!,
                title: "Example Site",
                text: "Description",
                author: nil,
                titleLink: nil,
                assetURL: nil,
                previewURL: previewURL
            ),
            downloadingState: nil,
            uploadingState: nil
        )
        
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Check this out",
            author: author,
            attachments: [linkAttachment.asAnyAttachment]
        )
        
        // When
        let resolver = MessageAttachmentPreviewResolver(message: message)
        
        // Then
        XCTAssertNil(resolver.previewDescription) // Links don't have description
        XCTAssertEqual(resolver.previewIcon, .link)
        XCTAssertNotNil(resolver.previewThumbnail)
        XCTAssertEqual(resolver.previewThumbnail?.url, previewURL)
        XCTAssertTrue(resolver.previewThumbnail?.isImage == true)
    }

    func test_resolver_linkWithoutPreview() {
        // Given
        let linkAttachment = ChatMessageLinkAttachment(
            id: .unique,
            type: .linkPreview,
            payload: LinkAttachmentPayload(
                originalURL: URL(string: "https://example.com")!,
                title: "Example Site",
                text: "Description",
                author: nil,
                titleLink: nil,
                assetURL: nil,
                previewURL: nil
            ),
            downloadingState: nil,
            uploadingState: nil
        )
        
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "Check this out",
            author: author,
            attachments: [linkAttachment.asAnyAttachment]
        )
        
        // When
        let resolver = MessageAttachmentPreviewResolver(message: message)
        
        // Then
        XCTAssertNil(resolver.previewDescription)
        XCTAssertEqual(resolver.previewIcon, .link)
        XCTAssertNil(resolver.previewThumbnail)
    }

    // MARK: - Poll

    func test_resolver_poll() {
        // Given
        let poll = Poll.mock(name: "Where should we host the next team offsite?")
        
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: author,
            poll: poll
        )
        
        // When
        let resolver = MessageAttachmentPreviewResolver(message: message)
        
        // Then
        XCTAssertEqual(resolver.previewDescription, "Where should we host the next team offsite?")
        XCTAssertEqual(resolver.previewIcon, .poll)
        XCTAssertNil(resolver.previewThumbnail)
    }

    // MARK: - Mixed Content

    func test_resolver_mixedContent() {
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
            attachments: [imageAttachment, fileAttachment]
        )
        
        // When
        let resolver = MessageAttachmentPreviewResolver(message: message)
        
        // Then
        XCTAssertEqual(resolver.previewDescription, "2 files")
        XCTAssertEqual(resolver.previewIcon, .mixed)
        XCTAssertNil(resolver.previewThumbnail)
    }

    func test_resolver_mixedContent_multipleAttachments() {
        // Given
        let imageAttachment = ChatMessageImageAttachment.mock(
            id: .unique,
            imageURL: .localYodaImage
        ).asAnyAttachment

        let imageAttachment2 = ChatMessageImageAttachment.mock(
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
                imageAttachment, imageAttachment2,
                fileAttachment(), fileAttachment(), fileAttachment()
            ]
        )
        
        // When
        let resolver = MessageAttachmentPreviewResolver(message: message)
        
        // Then
        XCTAssertEqual(resolver.previewDescription, "5 files")
        XCTAssertEqual(resolver.previewIcon, .mixed)
        XCTAssertNil(resolver.previewThumbnail)
    }

    // MARK: - Audio

    func test_resolver_audio() {
        // Given
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: author,
            attachments: [
                .dummy(
                    type: .audio,
                    payload: try! JSONEncoder().encode(AudioAttachmentPayload(
                        title: "song.mp3",
                        audioRemoteURL: URL(string: "https://example.com/song.mp3")!,
                        file: .init(type: .mp3, size: 1024, mimeType: "audio/mp3"),
                        extraData: nil
                    ))
                )
            ]
        )
        
        // When
        let resolver = MessageAttachmentPreviewResolver(message: message)
        
        // Then
        XCTAssertEqual(resolver.previewDescription, "Audio")
        XCTAssertEqual(resolver.previewIcon, .audio)
        XCTAssertNil(resolver.previewThumbnail)
    }

    // MARK: - Giphy

    func test_resolver_giphy() {
        // Given
        let giphyURL = URL(string: "https://giphy.com/preview.gif")!
        let giphyAttachment = ChatMessageGiphyAttachment(
            id: .unique,
            type: .giphy,
            payload: GiphyAttachmentPayload(
                title: "Funny GIF",
                previewURL: giphyURL,
                actions: []
            ),
            downloadingState: nil,
            uploadingState: nil
        )
        
        let message = ChatMessage.mock(
            id: .unique,
            cid: .unique,
            text: "",
            author: author,
            attachments: [giphyAttachment.asAnyAttachment]
        )
        
        // When
        let resolver = MessageAttachmentPreviewResolver(message: message)
        
        // Then
        XCTAssertEqual(resolver.previewDescription, "Photo")
        XCTAssertEqual(resolver.previewIcon, .photo)
        XCTAssertNotNil(resolver.previewThumbnail)
        XCTAssertEqual(resolver.previewThumbnail?.url, giphyURL)
        XCTAssertTrue(resolver.previewThumbnail?.isImage == true)
    }
}
