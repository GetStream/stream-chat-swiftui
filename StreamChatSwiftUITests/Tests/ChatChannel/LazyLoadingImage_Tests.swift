//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

@MainActor class LazyLoadingImage_Tests: StreamChatTestCase {
    // MARK: - Snapshot

    func test_lazyLoadingImage_snapshot() {
        // Given
        let source = MediaAttachment(url: .localYodaImage, type: .image)
        let view = LazyLoadingImage(
            source: source,
            width: 80,
            height: 80,
            resize: true,
            showVideoIcon: false
        )
        .frame(width: 80, height: 80)

        // Then
        AssertSnapshot(view, variants: [.defaultLight], size: CGSize(width: 80, height: 80))
    }

    func test_lazyLoadingImage_noResize_snapshot() {
        // Given
        let source = MediaAttachment(url: .localYodaImage, type: .image)
        let view = LazyLoadingImage(
            source: source,
            width: 80,
            height: 80,
            resize: false,
            showVideoIcon: false
        )
        .frame(width: 80, height: 80)

        // Then
        AssertSnapshot(view, variants: [.defaultLight], size: CGSize(width: 80, height: 80))
    }

    // MARK: - Initial Load

    func test_lazyLoadingImage_loadsImageOnAppear() {
        // Given
        let imageLoader = streamChat?.utils.mediaLoader as? MediaLoader_Mock
        let source = MediaAttachment(url: .localYodaImage, type: .image)
        let view = LazyLoadingImage(
            source: source,
            width: 80,
            height: 80,
            resize: true,
            showVideoIcon: false
        )

        // When
        showView(view)

        let expectation = expectation(description: "Image loaded on appear")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)

        // Then
        XCTAssertEqual(imageLoader?.loadImageCalled, true)
        XCTAssertEqual(imageLoader?.loadImageCallCount, 1)
        XCTAssertEqual(imageLoader?.loadedURLs.first, .localYodaImage)
    }

    // MARK: - Source Change Reload

    func test_lazyLoadingImage_reloadsWhenSourceChanges() {
        // Given
        let imageLoader = streamChat?.utils.mediaLoader as? MediaLoader_Mock
        let initialURL = URL(string: "https://example.com/yoda.jpg")!
        let updatedURL = URL(string: "https://example.com/vader.jpg")!
        let source = CurrentValueContainer(MediaAttachment(url: initialURL, type: .image))

        let view = LazyLoadingImageSourceChangeTestView(source: source)
        showView(view)

        // Wait for initial load
        let initialLoad = expectation(description: "Initial image loaded")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            initialLoad.fulfill()
        }
        wait(for: [initialLoad], timeout: 2.0)

        let initialCallCount = imageLoader?.loadImageCallCount ?? 0
        XCTAssertGreaterThanOrEqual(initialCallCount, 1)

        // When: change source
        source.value = MediaAttachment(url: updatedURL, type: .image)

        // Wait for reload
        let reload = expectation(description: "Image reloaded after source change")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            reload.fulfill()
        }
        wait(for: [reload], timeout: 2.0)

        // Then
        let finalCallCount = imageLoader?.loadImageCallCount ?? 0
        XCTAssertGreaterThan(finalCallCount, initialCallCount)
        XCTAssertTrue(imageLoader?.loadedURLs.contains(updatedURL) ?? false)
    }

    // MARK: - Generate Thumbnail

    func test_mediaAttachment_generateThumbnail_callsMediaLoader() {
        // Given
        let imageLoader = streamChat?.utils.mediaLoader as? MediaLoader_Mock
        let attachment = MediaAttachment(url: .localYodaImage, type: .image)

        // When
        let expectation = expectation(description: "Thumbnail generated")
        attachment.generateThumbnail(
            resize: true,
            preferredSize: CGSize(width: 80, height: 80)
        ) { _ in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)

        // Then
        XCTAssertEqual(imageLoader?.loadImageCalled, true)
        XCTAssertEqual(imageLoader?.loadedURLs.first, .localYodaImage)
    }

    // MARK: - CDN Requester

    func test_mediaAttachment_generateThumbnail_usesInjectedCDNRequester() {
        // Given
        let customRequester = CDNRequester_Mock()
        let mediaLoader = MediaLoader_Mock()
        let utils = Utils(cdnRequester: customRequester, mediaLoader: mediaLoader)
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
        let attachment = MediaAttachment(url: .localYodaImage, type: .image)

        // When
        let expectation = expectation(description: "Thumbnail generated")
        attachment.generateThumbnail(
            resize: true,
            preferredSize: CGSize(width: 80, height: 80)
        ) { _ in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)

        // Then
        XCTAssertEqual(mediaLoader.loadImageOptions.count, 1)
        XCTAssert(mediaLoader.loadImageOptions.first?.cdnRequester is CDNRequester_Mock)
    }

    func test_mediaAttachment_videoPreview_usesInjectedCDNRequester() {
        // Given
        let customRequester = CDNRequester_Mock()
        let mediaLoader = MediaLoader_Mock()
        let utils = Utils(cdnRequester: customRequester, mediaLoader: mediaLoader)
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
        let videoAttachment = ChatMessageVideoAttachment(
            id: .init(cid: .init(type: .messaging, id: "test"), messageId: "msg", index: 0),
            type: .video,
            payload: VideoAttachmentPayload(
                title: nil,
                videoRemoteURL: URL(string: "https://example.com/video.mp4")!,
                file: .init(type: .mp4, size: 0, mimeType: nil),
                extraData: nil
            ),
            downloadingState: nil,
            uploadingState: nil
        )
        let attachment = MediaAttachment(
            url: URL(string: "https://example.com/video.mp4")!,
            type: .video,
            videoAttachment: videoAttachment
        )

        // When
        let expectation = expectation(description: "Video preview generated")
        attachment.generateThumbnail(
            resize: false,
            preferredSize: CGSize(width: 80, height: 80)
        ) { _ in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)

        // Then
        XCTAssertEqual(mediaLoader.loadVideoPreviewOptions.count, 1)
        XCTAssert(mediaLoader.loadVideoPreviewOptions.first?.cdnRequester is CDNRequester_Mock)
    }

    // MARK: - MediaAttachment Equatable

    func test_mediaAttachment_equalityByURL() {
        // Given
        let url1 = URL(string: "https://example.com/image1.jpg")!
        let url2 = URL(string: "https://example.com/image2.jpg")!

        let attachment1 = MediaAttachment(url: url1, type: .image)
        let attachment2 = MediaAttachment(url: url1, type: .image)
        let attachment3 = MediaAttachment(url: url2, type: .image)

        // Then
        XCTAssertEqual(attachment1, attachment2)
        XCTAssertNotEqual(attachment1, attachment3)
    }

    func test_mediaAttachment_equalityByType() {
        // Given
        let url = URL(string: "https://example.com/media.mp4")!
        let imageAttachment = MediaAttachment(url: url, type: .image)
        let videoAttachment = MediaAttachment(url: url, type: .video)

        // Then
        XCTAssertNotEqual(imageAttachment, videoAttachment)
    }
}

// MARK: - Test Helpers

@MainActor
private class CurrentValueContainer<T>: ObservableObject {
    @Published var value: T
    init(_ value: T) {
        self.value = value
    }
}

@MainActor
private struct LazyLoadingImageSourceChangeTestView: View {
    @ObservedObject var source: CurrentValueContainer<MediaAttachment>

    var body: some View {
        LazyLoadingImage(
            source: source.value,
            width: 80,
            height: 80,
            resize: true,
            showVideoIcon: false
        )
    }
}
