//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
import StreamChatCommonUI
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

    // MARK: - storeCachingKey + cachedResult

    func test_cachedResult_returnsImage_afterStoringKeyAndPopulatingNukeCache() {
        let testImage = UIImage(systemName: "star.fill")!
        let uniqueKey = "cached-key-\(UUID().uuidString)"
        let cdnURL = URL(string: "https://cdn.example.com/\(uniqueKey)")!
        let originalURL = URL(string: "https://example.com/original-\(uniqueKey)")!

        let request = ImageRequest(
            url: cdnURL,
            userInfo: [.imageIdKey: uniqueKey]
        )
        ImagePipeline.shared.cache[request] = ImageContainer(image: testImage)

        NukeImageLoader.storeCachingKey(uniqueKey, url: originalURL, resize: nil)

        let cached = NukeImageLoader.cachedResult(url: originalURL, resize: nil)
        XCTAssertNotNil(cached)
        XCTAssertNotNil(cached?.image)

        ImagePipeline.shared.cache[request] = nil
    }

    func test_cachedResult_returnsNil_whenKeyStoredButNukeCacheEvicted() {
        let uniqueKey = "evicted-key-\(UUID().uuidString)"
        let originalURL = URL(string: "https://example.com/evicted-\(uniqueKey)")!

        NukeImageLoader.storeCachingKey(uniqueKey, url: originalURL, resize: nil)

        let cached = NukeImageLoader.cachedResult(url: originalURL, resize: nil)
        XCTAssertNil(cached)
    }

    func test_cachedResult_withResize_returnsImage() {
        let testImage = UIImage(systemName: "heart.fill")!
        let uniqueKey = "resize-key-\(UUID().uuidString)"
        let cdnURL = URL(string: "https://cdn.example.com/\(uniqueKey)")!
        let originalURL = URL(string: "https://example.com/resize-\(uniqueKey)")!
        let resize = ImageResize(CGSize(width: 200, height: 150))

        let request = ImageRequest(
            url: cdnURL,
            processors: NukeImageLoader.makeProcessors(resize: resize),
            userInfo: [.imageIdKey: uniqueKey]
        )
        ImagePipeline.shared.cache[request] = ImageContainer(image: testImage)

        NukeImageLoader.storeCachingKey(uniqueKey, url: originalURL, resize: resize)

        let cached = NukeImageLoader.cachedResult(url: originalURL, resize: resize)
        XCTAssertNotNil(cached)

        ImagePipeline.shared.cache[request] = nil
    }
}
