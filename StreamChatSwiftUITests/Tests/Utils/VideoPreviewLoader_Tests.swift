//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import AVKit
@testable import StreamChat
import StreamChatCommonUI
@testable import StreamChatSwiftUI
import XCTest

class MediaLoader_Tests: StreamChatTestCase {
    private let testURL = URL(string: "https://example.com/video.mp4")!
    private let thumbnailURL = URL(string: "https://example.com/thumbnail.jpg")!
    private let cdnRequester = CDNRequester_Mock()

    // MARK: - Default Extension (URL-only conformer)

    func test_loadVideoPreviewWithAttachment_defaultExtensionCallsURLMethod() {
        let loader = URLOnlyMediaLoader()
        let attachment = makeVideoAttachment(thumbnailURL: thumbnailURL)

        let expectation = expectation(description: "Completion called")
        var receivedImage: UIImage?
        loader.loadVideoPreview(with: attachment, options: VideoLoadOptions(cdnRequester: cdnRequester)) { result in
            receivedImage = try? result.get()
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
        XCTAssertTrue(loader.loadVideoPreviewAtURLCalled)
        XCTAssertNotNil(receivedImage)
    }

    func test_loadVideoPreviewWithAttachment_defaultExtensionPassesCorrectURL() {
        let loader = URLOnlyMediaLoader()
        let attachment = makeVideoAttachment(thumbnailURL: thumbnailURL)

        let expectation = expectation(description: "Completion called")
        loader.loadVideoPreview(with: attachment, options: VideoLoadOptions(cdnRequester: cdnRequester)) { _ in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
        XCTAssertEqual(loader.receivedURL, attachment.videoURL)
    }

    // MARK: - Custom conformer implementing both methods

    func test_loadVideoPreviewWithAttachment_customImplementationCalled() {
        let loader = FullMediaLoaderTest()
        let attachment = makeVideoAttachment(thumbnailURL: thumbnailURL)

        let expectation = expectation(description: "Completion called")
        var receivedImage: UIImage?
        loader.loadVideoPreview(with: attachment, options: VideoLoadOptions(cdnRequester: cdnRequester)) { result in
            receivedImage = try? result.get()
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
        XCTAssertTrue(loader.loadVideoPreviewWithAttachmentCalled)
        XCTAssertFalse(loader.loadVideoPreviewAtURLCalled)
        XCTAssertNotNil(receivedImage)
    }

    func test_loadVideoPreviewAtURL_customImplementationStillWorks() {
        let loader = FullMediaLoaderTest()

        let expectation = expectation(description: "Completion called")
        var receivedImage: UIImage?
        loader.loadVideoPreview(at: testURL, options: VideoLoadOptions(cdnRequester: cdnRequester)) { result in
            receivedImage = try? result.get()
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
        XCTAssertTrue(loader.loadVideoPreviewAtURLCalled)
        XCTAssertFalse(loader.loadVideoPreviewWithAttachmentCalled)
        XCTAssertNotNil(receivedImage)
    }

    func test_loadVideoPreviewWithAttachment_receivesCorrectAttachment() {
        let loader = FullMediaLoaderTest()
        let attachment = makeVideoAttachment(thumbnailURL: thumbnailURL)

        let expectation = expectation(description: "Completion called")
        loader.loadVideoPreview(with: attachment, options: VideoLoadOptions(cdnRequester: cdnRequester)) { _ in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
        XCTAssertEqual(loader.receivedAttachment?.videoURL, attachment.videoURL)
        XCTAssertEqual(loader.receivedAttachment?.payload.thumbnailURL, thumbnailURL)
    }

    // MARK: - StreamMediaLoader with attachment

    func test_streamMediaLoader_withAttachment_whenThumbnailURLExists_loadsThumbnailImage() {
        let thumbnailImage = UIImage(systemName: "star.fill")!
        let downloader = ConfigurableImageDownloader(result: .success(thumbnailImage))
        let mediaLoader = StreamMediaLoader(downloader: downloader)
        let attachment = makeVideoAttachment(thumbnailURL: thumbnailURL)

        let expectation = expectation(description: "Completion called")
        var receivedImage: UIImage?
        mediaLoader.loadVideoPreview(with: attachment, options: VideoLoadOptions(cdnRequester: cdnRequester)) { result in
            receivedImage = try? result.get()
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
        XCTAssertTrue(downloader.downloadImageCalled)
        XCTAssertEqual(receivedImage, thumbnailImage)
    }

    func test_streamMediaLoader_withAttachment_whenNoThumbnailURL_doesNotCallImageDownloader() {
        let downloader = ConfigurableImageDownloader(result: .success(UIImage()))
        let mediaLoader = StreamMediaLoader(downloader: downloader)
        let attachment = makeVideoAttachment(thumbnailURL: nil)

        let expectation = expectation(description: "Completion called")
        mediaLoader.loadVideoPreview(with: attachment, options: VideoLoadOptions(cdnRequester: cdnRequester)) { _ in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
        XCTAssertFalse(downloader.downloadImageCalled)
    }

    // MARK: - Helpers

    private func makeVideoAttachment(
        thumbnailURL: URL? = nil
    ) -> ChatMessageVideoAttachment {
        let attachmentFile = AttachmentFile(type: .mp4, size: 0, mimeType: "video/mp4")
        return ChatMessageVideoAttachment(
            id: .unique,
            type: .video,
            payload: VideoAttachmentPayload(
                title: "test",
                videoRemoteURL: testURL,
                thumbnailURL: thumbnailURL,
                file: attachmentFile,
                extraData: nil
            ),
            downloadingState: nil,
            uploadingState: nil
        )
    }
}

// MARK: - Test Doubles

private class URLOnlyMediaLoader: MediaLoader {
    var loadVideoPreviewAtURLCalled = false
    var receivedURL: URL?

    func loadImage(
        url: URL?,
        options: ImageLoadOptions,
        completion: @escaping @MainActor (Result<MediaLoaderImage, Error>) -> Void
    ) {
        Task { @MainActor in completion(.failure(NSError(domain: "stub", code: 0))) }
    }

    func loadImages(
        from urls: [URL],
        options: ImageBatchLoadOptions,
        completion: @escaping @MainActor ([MediaLoaderImage]) -> Void
    ) {
        Task { @MainActor in completion([]) }
    }

    func loadVideoPreview(
        at url: URL,
        options: VideoLoadOptions,
        completion: @escaping @MainActor (Result<MediaLoaderVideoPreview, Error>) -> Void
    ) {
        loadVideoPreviewAtURLCalled = true
        receivedURL = url
        Task { @MainActor in completion(.success(MediaLoaderVideoPreview(image: UIImage()))) }
    }
}

private class FullMediaLoaderTest: MediaLoader {
    var loadVideoPreviewAtURLCalled = false
    var loadVideoPreviewWithAttachmentCalled = false
    var receivedURL: URL?
    var receivedAttachment: ChatMessageVideoAttachment?

    func loadImage(
        url: URL?,
        options: ImageLoadOptions,
        completion: @escaping @MainActor (Result<MediaLoaderImage, Error>) -> Void
    ) {
        Task { @MainActor in completion(.failure(NSError(domain: "stub", code: 0))) }
    }

    func loadImages(
        from urls: [URL],
        options: ImageBatchLoadOptions,
        completion: @escaping @MainActor ([MediaLoaderImage]) -> Void
    ) {
        Task { @MainActor in completion([]) }
    }

    func loadVideoPreview(
        at url: URL,
        options: VideoLoadOptions,
        completion: @escaping @MainActor (Result<MediaLoaderVideoPreview, Error>) -> Void
    ) {
        loadVideoPreviewAtURLCalled = true
        receivedURL = url
        Task { @MainActor in completion(.success(MediaLoaderVideoPreview(image: UIImage()))) }
    }

    func loadVideoPreview(
        with attachment: ChatMessageVideoAttachment,
        options: VideoLoadOptions,
        completion: @escaping @MainActor (Result<MediaLoaderVideoPreview, Error>) -> Void
    ) {
        loadVideoPreviewWithAttachmentCalled = true
        receivedAttachment = attachment
        Task { @MainActor in completion(.success(MediaLoaderVideoPreview(image: UIImage()))) }
    }
}

private class ConfigurableImageDownloader: ImageDownloading, @unchecked Sendable {
    var downloadImageCalled = false
    var receivedURL: URL?
    private let result: Result<UIImage, Error>

    init(result: Result<UIImage, Error>) {
        self.result = result
    }

    func downloadImage(
        url: URL,
        headers: [String: String]?,
        cachingKey: String?,
        resize: CGSize?,
        completion: @escaping @MainActor (Result<UIImage, Error>) -> Void
    ) {
        downloadImageCalled = true
        receivedURL = url
        let result = self.result
        Task { @MainActor in
            completion(result)
        }
    }
}
