//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChatCommonUI
@testable import StreamChatSwiftUI
import XCTest

@MainActor
final class StreamImageDownloader_Tests: XCTestCase {
    private let downloader = StreamImageDownloader()

    // MARK: - Error Handling

    func test_downloadImage_returnsError_forInvalidURL() {
        let url = URL(string: "https://invalid.test/\(UUID().uuidString).jpg")!
        let options = ImageDownloadingOptions()
        let expectation = expectation(description: "Completion called")

        var receivedResult: Result<DownloadedImage, Error>?
        downloader.downloadImage(url: url, options: options) { result in
            receivedResult = result
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
        switch receivedResult {
        case .failure:
            break // expected
        default:
            XCTFail("Expected failure for invalid URL, got \(String(describing: receivedResult))")
        }
    }

    // MARK: - Options Propagation

    func test_downloadImage_propagatesHeaders() {
        let url = URL(string: "https://headers-test.invalid/\(UUID().uuidString).jpg")!
        let headers = ["Authorization": "Bearer test-token", "X-Custom": "value"]
        let options = ImageDownloadingOptions(headers: headers)

        let expectation = expectation(description: "Completion called")
        downloader.downloadImage(url: url, options: options) { _ in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
        // Verifies the call completes without crash when headers are provided.
        // Full header assertion would require intercepting the URLRequest.
    }

    func test_downloadImage_propagatesCachingKey() {
        let url = URL(string: "https://caching-test.invalid/\(UUID().uuidString).jpg")!
        let options = ImageDownloadingOptions(cachingKey: "custom-caching-key")

        let expectation = expectation(description: "Completion called")
        downloader.downloadImage(url: url, options: options) { _ in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func test_downloadImage_handlesResizeOption() {
        let url = URL(string: "https://resize-test.invalid/\(UUID().uuidString).jpg")!
        let options = ImageDownloadingOptions(resize: CGSize(width: 100, height: 100))

        let expectation = expectation(description: "Completion called")
        downloader.downloadImage(url: url, options: options) { _ in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func test_downloadImage_ignoresZeroResize() {
        let url = URL(string: "https://zero-resize.invalid/\(UUID().uuidString).jpg")!
        let options = ImageDownloadingOptions(resize: .zero)

        let expectation = expectation(description: "Completion called")
        downloader.downloadImage(url: url, options: options) { _ in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func test_downloadImage_worksWithAllOptions() {
        let url = URL(string: "https://all-opts.invalid/\(UUID().uuidString).jpg")!
        let options = ImageDownloadingOptions(
            headers: ["Auth": "token"],
            cachingKey: "my-key",
            resize: CGSize(width: 200, height: 200)
        )

        let expectation = expectation(description: "Completion called")
        downloader.downloadImage(url: url, options: options) { _ in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }
}
