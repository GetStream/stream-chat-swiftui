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

    // MARK: - Custom conformer

    func test_loadVideoPreviewWithAttachment_customImplementationCalled() {
        let loader = CustomMediaLoader()
        let attachment = makeVideoAttachment(thumbnailURL: thumbnailURL)

        let expectation = expectation(description: "Completion called")
        var receivedPreview: MediaLoaderVideoPreview?
        loader.loadVideoPreview(with: attachment, options: VideoLoadOptions(cdnRequester: cdnRequester)) { result in
            receivedPreview = try? result.get()
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
        XCTAssertTrue(loader.loadVideoPreviewCalled)
        XCTAssertNotNil(receivedPreview?.image)
    }

    func test_loadVideoPreviewWithAttachment_receivesCorrectAttachment() {
        let loader = CustomMediaLoader()
        let attachment = makeVideoAttachment(thumbnailURL: thumbnailURL)

        let expectation = expectation(description: "Completion called")
        loader.loadVideoPreview(with: attachment, options: VideoLoadOptions(cdnRequester: cdnRequester)) { _ in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
        XCTAssertEqual(loader.receivedAttachment?.videoURL, attachment.videoURL)
        XCTAssertEqual(loader.receivedAttachment?.payload.thumbnailURL, thumbnailURL)
    }

    // MARK: - StreamMediaLoader loadImage

    func test_streamMediaLoader_loadImage_callsDownloader() {
        let expectedImage = UIImage(systemName: "star.fill")!
        let downloader = ConfigurableImageDownloader(result: .success(expectedImage))
        let mediaLoader = StreamMediaLoader(downloader: downloader)
        let url = URL(string: "https://example.com/image.jpg")!

        let expectation = expectation(description: "Completion called")
        var receivedImage: MediaLoaderImage?
        mediaLoader.loadImage(url: url, options: ImageLoadOptions(cdnRequester: cdnRequester)) { result in
            receivedImage = try? result.get()
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
        XCTAssertTrue(downloader.downloadImageCalled)
        XCTAssertEqual(receivedImage?.image, expectedImage)
    }

    func test_streamMediaLoader_loadImage_returnsError_whenURLNil() {
        let downloader = ConfigurableImageDownloader(result: .success(UIImage()))
        let mediaLoader = StreamMediaLoader(downloader: downloader)

        let expectation = expectation(description: "Completion called")
        var receivedError: Error?
        mediaLoader.loadImage(url: nil, options: ImageLoadOptions(cdnRequester: cdnRequester)) { result in
            if case let .failure(error) = result {
                receivedError = error
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
        XCTAssertNotNil(receivedError)
        XCTAssertFalse(downloader.downloadImageCalled)
    }

    func test_streamMediaLoader_loadImage_propagatesDownloaderError() {
        let expectedError = NSError(domain: "test", code: 42)
        let downloader = ConfigurableImageDownloader(result: .failure(expectedError))
        let mediaLoader = StreamMediaLoader(downloader: downloader)
        let url = URL(string: "https://example.com/fail.jpg")!

        let expectation = expectation(description: "Completion called")
        var receivedError: NSError?
        mediaLoader.loadImage(url: url, options: ImageLoadOptions(cdnRequester: cdnRequester)) { result in
            if case let .failure(error) = result {
                receivedError = error as NSError
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
        XCTAssertEqual(receivedError?.code, 42)
    }

    // MARK: - StreamMediaLoader with attachment

    func test_streamMediaLoader_withAttachment_whenThumbnailURLExists_loadsThumbnailImage() {
        let thumbnailImage = UIImage(systemName: "star.fill")!
        let downloader = ConfigurableImageDownloader(result: .success(thumbnailImage))
        let mediaLoader = StreamMediaLoader(downloader: downloader)
        let attachment = makeVideoAttachment(thumbnailURL: thumbnailURL)

        let expectation = expectation(description: "Completion called")
        var receivedPreview: MediaLoaderVideoPreview?
        mediaLoader.loadVideoPreview(with: attachment, options: VideoLoadOptions(cdnRequester: cdnRequester)) { result in
            receivedPreview = try? result.get()
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
        XCTAssertTrue(downloader.downloadImageCalled)
        XCTAssertEqual(receivedPreview?.image, thumbnailImage)
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

private class CustomMediaLoader: MediaLoader, @unchecked Sendable {
    var loadVideoPreviewCalled = false
    var receivedAttachment: ChatMessageVideoAttachment?

    func loadImage(
        url: URL?,
        options: ImageLoadOptions,
        completion: @escaping @MainActor (Result<MediaLoaderImage, Error>) -> Void
    ) {
        Task { @MainActor in completion(.failure(NSError(domain: "stub", code: 0))) }
    }

    func loadVideoAsset(
        at url: URL,
        options: VideoLoadOptions,
        completion: @escaping @MainActor (Result<MediaLoaderVideoAsset, Error>) -> Void
    ) {
        Task { @MainActor in completion(.success(MediaLoaderVideoAsset(asset: AVURLAsset(url: url)))) }
    }

    func loadVideoPreview(
        with attachment: ChatMessageVideoAttachment,
        options: VideoLoadOptions,
        completion: @escaping @MainActor (Result<MediaLoaderVideoPreview, Error>) -> Void
    ) {
        loadVideoPreviewCalled = true
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
        options: ImageDownloadingOptions,
        completion: @escaping @MainActor (Result<DownloadedImage, Error>) -> Void
    ) {
        downloadImageCalled = true
        receivedURL = url
        let result = self.result
        Task { @MainActor in
            completion(result.map { DownloadedImage(image: $0) })
        }
    }
}
