//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

@MainActor class MessageMediaAttachmentContentView_Tests: StreamChatTestCase {

    private let testURL = ChatChannelTestHelpers.testURL
    private let cellWidth: CGFloat = 200
    private let cellHeight: CGFloat = 150

    // MARK: - Upload Progress

    func test_imageUploadProgress_snapshot() {
        let source = makeMediaAttachment(
            type: .image,
            uploadState: .uploading(progress: 0.5)
        )
        let view = makeContentView(source: source)
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_imageUploadProgressStart_snapshot() {
        let source = makeMediaAttachment(
            type: .image,
            uploadState: .uploading(progress: 0)
        )
        let view = makeContentView(source: source)
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_imageUploadProgressAlmostDone_snapshot() {
        let source = makeMediaAttachment(
            type: .image,
            uploadState: .uploading(progress: 0.9)
        )
        let view = makeContentView(source: source)
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_videoUploadProgress_snapshot() {
        let source = makeMediaAttachment(
            type: .video,
            uploadState: .uploading(progress: 0.5)
        )
        let view = makeContentView(source: source)
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_videoUploadProgress_noPlayIcon_snapshot() {
        let source = makeMediaAttachment(
            type: .video,
            uploadState: .uploading(progress: 0.7)
        )
        let view = makeContentView(source: source, width: 200, height: 150)
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    // MARK: - Upload Failed

    func test_imageUploadFailed_snapshot() {
        let source = makeMediaAttachment(
            type: .image,
            uploadState: .uploadingFailed
        )
        let view = makeContentView(source: source)
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_videoUploadFailed_snapshot() {
        let source = makeMediaAttachment(
            type: .video,
            uploadState: .uploadingFailed
        )
        let view = makeContentView(source: source)
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_imageUploadFailed_outgoing_snapshot() {
        let source = makeMediaAttachment(
            type: .image,
            uploadState: .uploadingFailed
        )
        let view = makeContentView(source: source, isOutgoing: true)
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    // MARK: - Thumbnail Load Failed

    func test_imageThumbnailLoadFailed_snapshot() {
        let failingLoader = FailingImageLoader_Mock()
        streamChat = StreamChat(
            chatClient: chatClient,
            utils: Utils(
                videoPreviewLoader: VideoPreviewLoader_Mock(),
                imageLoader: failingLoader
            )
        )

        let source = makeMediaAttachment(type: .image)
        let view = makeContentView(source: source)
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_videoThumbnailLoadFailed_snapshot() {
        let failingVideoLoader = FailingVideoPreviewLoader_Mock()
        streamChat = StreamChat(
            chatClient: chatClient,
            utils: Utils(
                videoPreviewLoader: failingVideoLoader,
                imageLoader: ImageLoader_Mock()
            )
        )

        let source = makeMediaAttachment(type: .video)
        let view = makeContentView(source: source)
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_imageThumbnailLoadFailed_outgoing_snapshot() {
        let failingLoader = FailingImageLoader_Mock()
        streamChat = StreamChat(
            chatClient: chatClient,
            utils: Utils(
                videoPreviewLoader: VideoPreviewLoader_Mock(),
                imageLoader: failingLoader
            )
        )

        let source = makeMediaAttachment(type: .image)
        let view = makeContentView(source: source, isOutgoing: true)
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    // MARK: - Upload Completed

    func test_imageUploaded_snapshot() {
        let source = makeMediaAttachment(
            type: .image,
            uploadState: .uploaded
        )
        let view = makeContentView(source: source)
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    // MARK: - Helpers

    private func makeMediaAttachment(
        type: MediaAttachmentType,
        uploadState: LocalAttachmentState? = nil
    ) -> MediaAttachment {
        let uploadingState: AttachmentUploadingState? = uploadState.map {
            let file = type == .image
                ? AttachmentFile(type: .png, size: 0, mimeType: "image/png")
                : AttachmentFile(type: .mp4, size: 0, mimeType: "video/mp4")
            return AttachmentUploadingState(
                localFileURL: testURL,
                state: $0,
                file: file
            )
        }
        return MediaAttachment(
            url: testURL,
            type: type,
            uploadingState: uploadingState
        )
    }

    private func makeContentView(
        source: MediaAttachment,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        isOutgoing: Bool = false,
        onUploadRetry: (() -> Void)? = nil
    ) -> some View {
        let w = width ?? cellWidth
        let h = height ?? cellHeight
        return MessageMediaAttachmentContentView(
            factory: DefaultViewFactory.shared,
            source: source,
            width: w,
            height: h,
            isOutgoing: isOutgoing,
            onUploadRetry: onUploadRetry
        )
        .frame(width: w, height: h)
    }
}

// MARK: - Failing Video Preview Loader

private class FailingVideoPreviewLoader_Mock: VideoPreviewLoader {
    struct MockError: Error {}

    func loadPreviewForVideo(at url: URL, completion: @escaping @MainActor (Result<UIImage, Error>) -> Void) {
        StreamConcurrency.onMain {
            completion(.failure(MockError()))
        }
    }

    func loadPreviewForVideo(
        with attachment: ChatMessageVideoAttachment,
        completion: @escaping @MainActor (Result<UIImage, Error>) -> Void
    ) {
        completion(.failure(MockError()))
    }
}
