//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class VideoPreviewLoader_Tests: StreamChatTestCase {
    private let testURL = URL(string: "https://example.com/video.mp4")!
    private let thumbnailURL = URL(string: "https://example.com/thumbnail.jpg")!

    // MARK: - Default Extension (URL-only conformer)

    func test_loadPreviewForVideoWithAttachment_defaultExtensionCallsURLMethod() {
        // Given
        let loader = URLOnlyVideoPreviewLoader()
        let attachment = makeVideoAttachment(thumbnailURL: thumbnailURL)

        // When
        let expectation = expectation(description: "Completion called")
        var receivedImage: UIImage?
        loader.loadPreviewForVideo(with: attachment) { result in
            receivedImage = try? result.get()
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1)
        XCTAssertTrue(loader.loadPreviewAtURLCalled)
        XCTAssertNotNil(receivedImage)
    }

    func test_loadPreviewForVideoWithAttachment_defaultExtensionPassesCorrectURL() {
        // Given
        let loader = URLOnlyVideoPreviewLoader()
        let attachment = makeVideoAttachment(thumbnailURL: thumbnailURL)

        // When
        let expectation = expectation(description: "Completion called")
        loader.loadPreviewForVideo(with: attachment) { _ in
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1)
        XCTAssertEqual(loader.receivedURL, attachment.videoURL)
    }

    // MARK: - Custom conformer implementing both methods

    func test_loadPreviewForVideoWithAttachment_customImplementationCalled() {
        // Given
        let loader = FullVideoPreviewLoader()
        let attachment = makeVideoAttachment(thumbnailURL: thumbnailURL)

        // When
        let expectation = expectation(description: "Completion called")
        var receivedImage: UIImage?
        loader.loadPreviewForVideo(with: attachment) { result in
            receivedImage = try? result.get()
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1)
        XCTAssertTrue(loader.loadPreviewWithAttachmentCalled)
        XCTAssertFalse(loader.loadPreviewAtURLCalled)
        XCTAssertNotNil(receivedImage)
    }

    func test_loadPreviewForVideoAtURL_customImplementationStillWorks() {
        // Given
        let loader = FullVideoPreviewLoader()

        // When
        let expectation = expectation(description: "Completion called")
        var receivedImage: UIImage?
        loader.loadPreviewForVideo(at: testURL) { result in
            receivedImage = try? result.get()
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1)
        XCTAssertTrue(loader.loadPreviewAtURLCalled)
        XCTAssertFalse(loader.loadPreviewWithAttachmentCalled)
        XCTAssertNotNil(receivedImage)
    }

    func test_loadPreviewForVideoWithAttachment_receivesCorrectAttachment() {
        // Given
        let loader = FullVideoPreviewLoader()
        let attachment = makeVideoAttachment(thumbnailURL: thumbnailURL)

        // When
        let expectation = expectation(description: "Completion called")
        loader.loadPreviewForVideo(with: attachment) { _ in
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1)
        XCTAssertEqual(loader.receivedAttachment?.videoURL, attachment.videoURL)
        XCTAssertEqual(loader.receivedAttachment?.payload.thumbnailURL, thumbnailURL)
    }

    // MARK: - DefaultVideoPreviewLoader with attachment

    func test_defaultLoader_withAttachment_whenThumbnailURLExists_loadsThumbnailImage() {
        // Given
        let imageLoader = ConfigurableImageLoader(result: .success(ConfigurableImageLoader.thumbnailImage))
        streamChat = StreamChat(
            chatClient: chatClient,
            utils: Utils(imageLoader: imageLoader)
        )
        let loader = DefaultVideoPreviewLoader()
        let attachment = makeVideoAttachment(thumbnailURL: thumbnailURL)

        // When
        let expectation = expectation(description: "Completion called")
        var receivedImage: UIImage?
        loader.loadPreviewForVideo(with: attachment) { result in
            receivedImage = try? result.get()
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1)
        XCTAssertTrue(imageLoader.loadImageCalled)
        XCTAssertEqual(imageLoader.receivedURL, thumbnailURL)
        XCTAssertEqual(receivedImage, ConfigurableImageLoader.thumbnailImage)
    }

    func test_defaultLoader_withAttachment_whenThumbnailURLExists_cachesResult() {
        // Given
        let imageLoader = ConfigurableImageLoader(result: .success(ConfigurableImageLoader.thumbnailImage))
        streamChat = StreamChat(
            chatClient: chatClient,
            utils: Utils(imageLoader: imageLoader)
        )
        let loader = DefaultVideoPreviewLoader()
        let attachment = makeVideoAttachment(thumbnailURL: thumbnailURL)

        // When - first call to populate cache
        let firstExpectation = expectation(description: "First completion called")
        loader.loadPreviewForVideo(with: attachment) { _ in
            firstExpectation.fulfill()
        }
        waitForExpectations(timeout: 1)

        // Reset tracker
        imageLoader.loadImageCalled = false
        imageLoader.receivedURL = nil

        // When - second call should hit cache
        let secondExpectation = expectation(description: "Second completion called")
        var receivedImage: UIImage?
        loader.loadPreviewForVideo(with: attachment) { result in
            receivedImage = try? result.get()
            secondExpectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1)
        XCTAssertFalse(imageLoader.loadImageCalled)
        XCTAssertEqual(receivedImage, ConfigurableImageLoader.thumbnailImage)
    }

    func test_defaultLoader_withAttachment_whenNoThumbnailURL_doesNotCallImageLoader() {
        // Given
        let imageLoader = ConfigurableImageLoader(result: .success(ConfigurableImageLoader.thumbnailImage))
        streamChat = StreamChat(
            chatClient: chatClient,
            utils: Utils(imageLoader: imageLoader)
        )
        let loader = DefaultVideoPreviewLoader()
        let attachment = makeVideoAttachment(thumbnailURL: nil)

        // When
        let expectation = expectation(description: "Completion called")
        loader.loadPreviewForVideo(with: attachment) { _ in
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 5)
        XCTAssertFalse(imageLoader.loadImageCalled)
    }

    func test_defaultLoader_withAttachment_whenThumbnailLoadFails_fallsBackToVideoPreview() {
        // Given
        let imageLoader = ConfigurableImageLoader(result: .failure(NSError(domain: "test", code: -1)))
        streamChat = StreamChat(
            chatClient: chatClient,
            utils: Utils(imageLoader: imageLoader)
        )
        let loader = DefaultVideoPreviewLoader()
        let attachment = makeVideoAttachment(thumbnailURL: thumbnailURL)

        // When
        let expectation = expectation(description: "Completion called")
        var receivedImage: UIImage?
        loader.loadPreviewForVideo(with: attachment) { result in
            receivedImage = try? result.get()
            expectation.fulfill()
        }

        // Then - image loader was called but failed, so it fell back to video frame extraction
        waitForExpectations(timeout: 5)
        XCTAssertTrue(imageLoader.loadImageCalled)
        XCTAssertNotEqual(receivedImage, ConfigurableImageLoader.thumbnailImage)
    }

    func test_defaultLoader_withAttachment_whenCached_returnsCachedWithoutLoadingThumbnail() {
        // Given
        let imageLoader = ConfigurableImageLoader(result: .success(ConfigurableImageLoader.thumbnailImage))
        streamChat = StreamChat(
            chatClient: chatClient,
            utils: Utils(imageLoader: imageLoader)
        )
        let loader = DefaultVideoPreviewLoader()
        let attachment = makeVideoAttachment(thumbnailURL: thumbnailURL)

        // Pre-populate via the URL-based method (which also populates the cache for the same URL)
        let setupExpectation = expectation(description: "Setup completion called")
        loader.loadPreviewForVideo(with: attachment) { _ in
            setupExpectation.fulfill()
        }
        waitForExpectations(timeout: 1)

        imageLoader.loadImageCalled = false

        // When - second call with attachment should use cache
        let expectation = expectation(description: "Completion called")
        var receivedImage: UIImage?
        loader.loadPreviewForVideo(with: attachment) { result in
            receivedImage = try? result.get()
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1)
        XCTAssertFalse(imageLoader.loadImageCalled)
        XCTAssertNotNil(receivedImage)
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

/// A conformer that only implements the URL-based method.
/// The attachment-based method should use the default protocol extension.
private class URLOnlyVideoPreviewLoader: VideoPreviewLoader {
    var loadPreviewAtURLCalled = false
    var receivedURL: URL?

    func loadPreviewForVideo(at url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
        loadPreviewAtURLCalled = true
        receivedURL = url
        completion(.success(UIImage()))
    }
}

/// A conformer that implements both methods independently.
private class FullVideoPreviewLoader: VideoPreviewLoader {
    var loadPreviewAtURLCalled = false
    var loadPreviewWithAttachmentCalled = false
    var receivedURL: URL?
    var receivedAttachment: ChatMessageVideoAttachment?

    func loadPreviewForVideo(at url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
        loadPreviewAtURLCalled = true
        receivedURL = url
        completion(.success(UIImage()))
    }

    func loadPreviewForVideo(
        with attachment: ChatMessageVideoAttachment,
        completion: @escaping (Result<UIImage, Error>) -> Void
    ) {
        loadPreviewWithAttachmentCalled = true
        receivedAttachment = attachment
        completion(.success(UIImage()))
    }
}

/// Configurable image loader that can be set to succeed or fail.
private class ConfigurableImageLoader: ImageLoading {
    static let thumbnailImage = UIImage(systemName: "star.fill")!

    var loadImageCalled = false
    var receivedURL: URL?
    private let result: Result<UIImage, Error>

    init(result: Result<UIImage, Error>) {
        self.result = result
    }

    func loadImage(
        url: URL?,
        imageCDN: ImageCDN,
        resize: Bool,
        preferredSize: CGSize?,
        completion: @escaping ((Result<UIImage, Error>) -> Void)
    ) {
        loadImageCalled = true
        receivedURL = url
        completion(result)
    }

    func loadImages(
        from urls: [URL],
        placeholders: [UIImage],
        loadThumbnails: Bool,
        thumbnailSize: CGSize,
        imageCDN: ImageCDN,
        completion: @escaping (([UIImage]) -> Void)
    ) {
        completion([])
    }
}
