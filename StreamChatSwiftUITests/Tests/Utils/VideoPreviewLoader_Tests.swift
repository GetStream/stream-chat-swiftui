//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
import StreamChatCommonUI
@testable import StreamChatSwiftUI
import XCTest

class VideoLoader_Tests: StreamChatTestCase {
    private let testURL = URL(string: "https://example.com/video.mp4")!
    private let thumbnailURL = URL(string: "https://example.com/thumbnail.jpg")!

    // MARK: - Default Extension (URL-only conformer)

    func test_loadPreviewWithAttachment_defaultExtensionCallsURLMethod() {
        let loader = URLOnlyVideoLoader()
        let attachment = makeVideoAttachment(thumbnailURL: thumbnailURL)

        let expectation = expectation(description: "Completion called")
        var receivedImage: UIImage?
        loader.loadPreview(with: attachment) { result in
            receivedImage = try? result.get()
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
        XCTAssertTrue(loader.loadPreviewAtURLCalled)
        XCTAssertNotNil(receivedImage)
    }

    func test_loadPreviewWithAttachment_defaultExtensionPassesCorrectURL() {
        let loader = URLOnlyVideoLoader()
        let attachment = makeVideoAttachment(thumbnailURL: thumbnailURL)

        let expectation = expectation(description: "Completion called")
        loader.loadPreview(with: attachment) { _ in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
        XCTAssertEqual(loader.receivedURL, attachment.videoURL)
    }

    // MARK: - Custom conformer implementing both methods

    func test_loadPreviewWithAttachment_customImplementationCalled() {
        let loader = FullVideoLoaderTest()
        let attachment = makeVideoAttachment(thumbnailURL: thumbnailURL)

        let expectation = expectation(description: "Completion called")
        var receivedImage: UIImage?
        loader.loadPreview(with: attachment) { result in
            receivedImage = try? result.get()
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
        XCTAssertTrue(loader.loadPreviewWithAttachmentCalled)
        XCTAssertFalse(loader.loadPreviewAtURLCalled)
        XCTAssertNotNil(receivedImage)
    }

    func test_loadPreviewAtURL_customImplementationStillWorks() {
        let loader = FullVideoLoaderTest()

        let expectation = expectation(description: "Completion called")
        var receivedImage: UIImage?
        loader.loadPreview(at: testURL) { result in
            receivedImage = try? result.get()
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
        XCTAssertTrue(loader.loadPreviewAtURLCalled)
        XCTAssertFalse(loader.loadPreviewWithAttachmentCalled)
        XCTAssertNotNil(receivedImage)
    }

    func test_loadPreviewWithAttachment_receivesCorrectAttachment() {
        let loader = FullVideoLoaderTest()
        let attachment = makeVideoAttachment(thumbnailURL: thumbnailURL)

        let expectation = expectation(description: "Completion called")
        loader.loadPreview(with: attachment) { _ in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
        XCTAssertEqual(loader.receivedAttachment?.videoURL, attachment.videoURL)
        XCTAssertEqual(loader.receivedAttachment?.payload.thumbnailURL, thumbnailURL)
    }

    // MARK: - StreamVideoLoader with attachment

    func test_streamVideoLoader_withAttachment_whenThumbnailURLExists_loadsThumbnailImage() {
        let imageLoader = ConfigurableImageLoaderTest(result: .success(ConfigurableImageLoaderTest.thumbnailImage))
        let videoLoader = StreamVideoLoader(imageLoader: imageLoader)
        let attachment = makeVideoAttachment(thumbnailURL: thumbnailURL)

        let expectation = expectation(description: "Completion called")
        var receivedImage: UIImage?
        videoLoader.loadPreview(with: attachment) { result in
            receivedImage = try? result.get()
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
        XCTAssertTrue(imageLoader.loadImageCalled)
        XCTAssertEqual(imageLoader.receivedURL, thumbnailURL)
        XCTAssertEqual(receivedImage, ConfigurableImageLoaderTest.thumbnailImage)
    }

    func test_streamVideoLoader_withAttachment_whenNoThumbnailURL_doesNotCallImageLoader() {
        let imageLoader = ConfigurableImageLoaderTest(result: .success(ConfigurableImageLoaderTest.thumbnailImage))
        let videoLoader = StreamVideoLoader(imageLoader: imageLoader)
        let attachment = makeVideoAttachment(thumbnailURL: nil)

        let expectation = expectation(description: "Completion called")
        videoLoader.loadPreview(with: attachment) { _ in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
        XCTAssertFalse(imageLoader.loadImageCalled)
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

private class URLOnlyVideoLoader: VideoLoader {
    var loadPreviewAtURLCalled = false
    var receivedURL: URL?

    func loadPreview(
        at url: URL,
        completion: @escaping @MainActor (Result<UIImage, Error>) -> Void
    ) {
        loadPreviewAtURLCalled = true
        receivedURL = url
        completion(.success(UIImage()))
    }
}

private class FullVideoLoaderTest: VideoLoader {
    var loadPreviewAtURLCalled = false
    var loadPreviewWithAttachmentCalled = false
    var receivedURL: URL?
    var receivedAttachment: ChatMessageVideoAttachment?

    func loadPreview(at url: URL, completion: @escaping @MainActor (Result<UIImage, Error>) -> Void) {
        loadPreviewAtURLCalled = true
        receivedURL = url
        completion(.success(UIImage()))
    }

    func loadPreview(
        with attachment: ChatMessageVideoAttachment,
        completion: @escaping @MainActor (Result<UIImage, Error>) -> Void
    ) {
        loadPreviewWithAttachmentCalled = true
        receivedAttachment = attachment
        completion(.success(UIImage()))
    }
}

private class ConfigurableImageLoaderTest: ImageLoader, @unchecked Sendable {
    static let thumbnailImage = UIImage(systemName: "star.fill")!

    var loadImageCalled = false
    var receivedURL: URL?
    private let result: Result<UIImage, Error>

    init(result: Result<UIImage, Error>) {
        self.result = result
    }

    func loadImage(
        url: URL?,
        resize: ImageResize?,
        completion: @escaping @MainActor (Result<UIImage, Error>) -> Void
    ) {
        loadImageCalled = true
        receivedURL = url
        Task { @MainActor in
            completion(result)
        }
    }

    func loadImages(
        from urls: [URL],
        placeholders: [UIImage],
        loadThumbnails: Bool,
        thumbnailSize: CGSize,
        completion: @escaping @MainActor ([UIImage]) -> Void
    ) {
        Task { @MainActor in
            completion([])
        }
    }
}
