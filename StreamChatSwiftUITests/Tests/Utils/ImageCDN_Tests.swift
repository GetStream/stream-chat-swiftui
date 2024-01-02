//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class ImageCDN_Tests: XCTestCase {

    func test_cache_validStreamURL_filtered() {
        // Given
        let provider = StreamImageCDN()
        let url = URL(string: "https://wwww.stream-io-cdn.com/image.jpg?name=Luke&father=Anakin")!
        let filteredUrl = "https://wwww.stream-io-cdn.com/image.jpg"

        // When
        let key = provider.cachingKey(forImage: url)

        // Then
        XCTAssertEqual(key, filteredUrl)
    }

    func test_cache_validStreamUrl_withSizeParameters() {
        // Given
        let provider = StreamImageCDN()
        let url = URL(string: "https://wwww.stream-io-cdn.com/image.jpg?name=Luke&w=128&h=128&crop=center&resize=fill&ro=0")!
        let filteredUrl = "https://wwww.stream-io-cdn.com/image.jpg?w=128&h=128"

        // When
        let key = provider.cachingKey(forImage: url)

        // Then
        XCTAssertEqual(key, filteredUrl)
    }

    func test_cache_validStreamURL_unchanged() {
        // Given
        let provider = StreamImageCDN()
        let url = URL(string: "https://wwww.stream-io-cdn.com/image.jpg")!

        // When
        let key = provider.cachingKey(forImage: url)

        // Then
        XCTAssertEqual(key, url.absoluteString)
    }

    func test_cache_validURL_unchanged() {
        // Given
        let provider = StreamImageCDN()
        let url = URL(string: "https://wwww.stream.io")!

        // When
        let key = provider.cachingKey(forImage: url)

        // Then
        XCTAssertEqual(key, url.absoluteString)
    }

    func test_cache_invalidURL_unchanged() {
        // Given
        let provider = StreamImageCDN()

        // When
        let url1 = URL(string: "https://abc")!
        let key1 = provider.cachingKey(forImage: url1)

        let url2 = URL(string: "abc.def")!
        let key2 = provider.cachingKey(forImage: url2)

        // Then
        XCTAssertEqual(key1, url1.absoluteString)
        XCTAssertEqual(key2, url2.absoluteString)
    }

    func test_thumbnail_validStreamUrl_withoutParameters() {
        // Given
        let provider = StreamImageCDN()
        let url = URL(string: "https://wwww.stream-io-cdn.com/image.jpg")!
        let size = Int(40 * UIScreen.main.scale)
        let thumbnailUrl = URL(string: "https://wwww.stream-io-cdn.com/image.jpg?w=\(size)&h=\(size)&crop=center&resize=fill&ro=0")!

        // When
        let processedURL = provider.thumbnailURL(
            originalURL: url,
            preferredSize: CGSize(width: 40, height: 40)
        )

        // Then
        XCTAssertEqual(processedURL, thumbnailUrl)
    }

    func test_thumbnail_validStreamUrl_withParameters() {
        // Given
        let provider = StreamImageCDN()
        let url = URL(string: "https://wwww.stream-io-cdn.com/image.jpg?name=Luke")!
        let size = Int(40 * UIScreen.main.scale)
        let thumbnailUrl =
            URL(string: "https://wwww.stream-io-cdn.com/image.jpg?name=Luke&w=\(size)&h=\(size)&crop=center&resize=fill&ro=0")!

        // When
        let processedURL = provider.thumbnailURL(
            originalURL: url,
            preferredSize: CGSize(width: 40, height: 40)
        )

        // Then
        XCTAssertEqual(processedURL, thumbnailUrl)
    }

    func test_thumbnail_validURL_unchanged() {
        // Given
        let provider = StreamImageCDN()
        let url = URL(string: "https://wwww.stream.io")!

        // When
        let processedURL = provider.thumbnailURL(
            originalURL: url,
            preferredSize: CGSize(width: 40, height: 40)
        )

        // Then
        XCTAssertEqual(processedURL, url)
    }
}
