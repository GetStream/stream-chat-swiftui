//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

@MainActor
final class NukeImageLoader_Tests: StreamChatTestCase {
    // MARK: - cachedResult

    func test_cachedResult_returnsNil_whenNoKeyStored() {
        let url = URL(string: "https://example.com/never-loaded.jpg")!
        let result = NukeImageLoader.cachedResult(url: url, resize: nil)
        XCTAssertNil(result)
    }

    func test_cachedResult_returnsNil_withResize_whenNoKeyStored() {
        let url = URL(string: "https://example.com/never-loaded.jpg")!
        let resize = ImageResize(CGSize(width: 100, height: 100))
        let result = NukeImageLoader.cachedResult(url: url, resize: resize)
        XCTAssertNil(result)
    }

    // MARK: - loadImage (cache miss path)

    func test_loadImage_callsOnCacheMiss_whenImageNotCached() async throws {
        let url = URL(string: "https://example.com/test-miss-\(UUID().uuidString).jpg")!
        let cdnRequester = CDNRequester_Mock()
        var cacheMissCalled = false

        do {
            _ = try await NukeImageLoader.loadImage(
                url: url,
                resize: nil,
                cdnRequester: cdnRequester,
                onCacheMiss: { cacheMissCalled = true }
            )
        } catch {
            // Network error is expected in tests — we only care about the cache miss callback
        }

        XCTAssertTrue(cacheMissCalled)
        XCTAssertEqual(cdnRequester.imageRequestCallCount, 1)
        XCTAssertEqual(cdnRequester.imageRequestCalledWithURLs, [url])
    }

    func test_loadImage_callsCDNRequester_withCorrectURL() async {
        let url = URL(string: "https://example.com/cdn-check-\(UUID().uuidString).jpg")!
        let cdnRequester = CDNRequester_Mock()

        do {
            _ = try await NukeImageLoader.loadImage(
                url: url,
                resize: nil,
                cdnRequester: cdnRequester
            )
        } catch {
            // Expected
        }

        XCTAssertEqual(cdnRequester.imageRequestCallCount, 1)
        XCTAssertEqual(cdnRequester.imageRequestCalledWithURLs.first, url)
    }

    // MARK: - loadImage with resize

    func test_loadImage_passesCDNRequester_withResize() async {
        let url = URL(string: "https://example.com/resize-\(UUID().uuidString).jpg")!
        let cdnRequester = CDNRequester_Mock()
        let resize = ImageResize(CGSize(width: 200, height: 150))

        do {
            _ = try await NukeImageLoader.loadImage(
                url: url,
                resize: resize,
                cdnRequester: cdnRequester
            )
        } catch {
            // Expected
        }

        XCTAssertEqual(cdnRequester.imageRequestCallCount, 1)
    }

    // MARK: - loadImage (cache hit after CDN transform)

    func test_loadImage_skipsOnCacheMiss_whenCacheHitAfterTransform() async throws {
        let testImage = UIImage(systemName: "star.fill")!
        let uniqueKey = "cached-key-\(UUID().uuidString)"
        let cdnURL = URL(string: "https://cdn.example.com/\(uniqueKey)")!

        let request = ImageRequest(
            url: cdnURL,
            userInfo: [.imageIdKey: uniqueKey]
        )
        ImagePipeline.shared.cache[request] = ImageContainer(image: testImage)

        let cdnRequester = CDNRequester_Mock()
        cdnRequester.imageRequestResult = .success(
            CDNRequest(url: cdnURL, cachingKey: uniqueKey)
        )

        let originalURL = URL(string: "https://example.com/original-\(uniqueKey)")!
        var cacheMissCalled = false

        let result = try await NukeImageLoader.loadImage(
            url: originalURL,
            resize: nil,
            cdnRequester: cdnRequester,
            onCacheMiss: { cacheMissCalled = true }
        )

        XCTAssertFalse(cacheMissCalled)
        XCTAssertNotNil(result.image)
        XCTAssertEqual(cdnRequester.imageRequestCallCount, 1)

        ImagePipeline.shared.cache[request] = nil
    }

    // MARK: - cachingKeyMap persistence

    func test_cachedResult_returnsImage_afterLoadStoresCachingKey() async throws {
        let testImage = UIImage(systemName: "heart.fill")!
        let uniqueKey = "persist-key-\(UUID().uuidString)"
        let cdnURL = URL(string: "https://cdn.example.com/\(uniqueKey)")!
        let originalURL = URL(string: "https://example.com/\(uniqueKey)")!

        let cdnRequester = CDNRequester_Mock()
        cdnRequester.imageRequestResult = .success(
            CDNRequest(url: cdnURL, cachingKey: uniqueKey)
        )

        let request = ImageRequest(
            url: cdnURL,
            userInfo: [.imageIdKey: uniqueKey]
        )
        ImagePipeline.shared.cache[request] = ImageContainer(image: testImage)

        _ = try await NukeImageLoader.loadImage(
            url: originalURL,
            resize: nil,
            cdnRequester: cdnRequester
        )

        let cached = NukeImageLoader.cachedResult(url: originalURL, resize: nil)
        XCTAssertNotNil(cached)
        XCTAssertNotNil(cached?.image)

        ImagePipeline.shared.cache[request] = nil
    }
}
