//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import XCTest

final class MediaAttachmentGalleryOrdering_Tests: XCTestCase {
    // MARK: - Video uploading state URL selection

    func test_mediaAttachment_videoWithUploadingState_usesLocalFileURL() {
        let localURL = URL(fileURLWithPath: "/tmp/local-video.mp4")
        let remoteURL = URL(string: "https://cdn.example.com/remote-video.mp4")!
        let file = AttachmentFile(type: .mp4, size: 0, mimeType: "video/mp4")
        let uploadingState = AttachmentUploadingState(
            localFileURL: localURL,
            state: .pendingUpload,
            file: file
        )
        let attachment = ChatMessageVideoAttachment(
            id: .unique,
            type: .video,
            payload: VideoAttachmentPayload(
                title: "test",
                videoRemoteURL: remoteURL,
                file: file,
                extraData: nil
            ),
            downloadingState: nil,
            uploadingState: uploadingState
        )

        let media = MediaAttachment(from: attachment)

        XCTAssertEqual(media.url, localURL)
        XCTAssertEqual(media.type.rawValue, MediaAttachmentType.video.rawValue)
    }

    func test_mediaAttachment_videoWithoutUploadingState_usesRemoteURL() {
        let remoteURL = URL(string: "https://cdn.example.com/remote-video.mp4")!
        let file = AttachmentFile(type: .mp4, size: 0, mimeType: "video/mp4")
        let attachment = ChatMessageVideoAttachment(
            id: .unique,
            type: .video,
            payload: VideoAttachmentPayload(
                title: "test",
                videoRemoteURL: remoteURL,
                file: file,
                extraData: nil
            ),
            downloadingState: nil,
            uploadingState: nil
        )

        let media = MediaAttachment(from: attachment)

        XCTAssertEqual(media.url, remoteURL)
    }

    func test_mediaAttachment_imageWithUploadingState_usesLocalFileURL() {
        let localURL = URL(fileURLWithPath: "/tmp/local-image.png")
        let remoteURL = URL(string: "https://cdn.example.com/remote-image.png")!
        let file = AttachmentFile(type: .png, size: 0, mimeType: "image/png")
        let uploadingState = AttachmentUploadingState(
            localFileURL: localURL,
            state: .pendingUpload,
            file: file
        )
        let attachment = ChatMessageImageAttachment(
            id: .unique,
            type: .image,
            payload: ImageAttachmentPayload(
                title: "test",
                imageRemoteURL: remoteURL,
                file: file,
                extraData: [:]
            ),
            downloadingState: nil,
            uploadingState: uploadingState
        )

        let media = MediaAttachment(from: attachment)

        XCTAssertEqual(media.url, localURL)
        XCTAssertEqual(media.type.rawValue, MediaAttachmentType.image.rawValue)
    }

    func test_mediaAttachment_imageWithoutUploadingState_usesRemoteURL() {
        let remoteURL = URL(string: "https://cdn.example.com/remote-image.png")!
        let file = AttachmentFile(type: .png, size: 0, mimeType: "image/png")
        let attachment = ChatMessageImageAttachment(
            id: .unique,
            type: .image,
            payload: ImageAttachmentPayload(
                title: "test",
                imageRemoteURL: remoteURL,
                file: file,
                extraData: [:]
            ),
            downloadingState: nil,
            uploadingState: nil
        )

        let media = MediaAttachment(from: attachment)

        XCTAssertEqual(media.url, remoteURL)
    }

    // MARK: - Gallery ordering

    func test_galleryOrderedMediaAttachments_preservesMessageAttachmentOrder_imageThenVideo() {
        let image = ChatChannelTestHelpers.imageAttachments[0]
        let video = ChatChannelTestHelpers.videoAttachments[0]
        let message = ChatMessage.mock(attachments: [image, video])

        let ordered = MediaAttachment.galleryOrdered(from: message)

        XCTAssertEqual(ordered.count, 2)
        XCTAssertEqual(ordered[0].type.rawValue, MediaAttachmentType.image.rawValue)
        XCTAssertEqual(ordered[1].type.rawValue, MediaAttachmentType.video.rawValue)
    }

    func test_galleryOrderedMediaAttachments_preservesMessageAttachmentOrder_videoThenImage() {
        let image = ChatChannelTestHelpers.imageAttachments[0]
        let video = ChatChannelTestHelpers.videoAttachments[0]
        let message = ChatMessage.mock(attachments: [video, image])

        let ordered = MediaAttachment.galleryOrdered(from: message)

        XCTAssertEqual(ordered.count, 2)
        XCTAssertEqual(ordered[0].type.rawValue, MediaAttachmentType.video.rawValue)
        XCTAssertEqual(ordered[1].type.rawValue, MediaAttachmentType.image.rawValue)
    }
}
