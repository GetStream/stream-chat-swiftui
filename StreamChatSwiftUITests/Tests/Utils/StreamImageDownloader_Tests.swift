//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChatSwiftUI
import XCTest

final class StreamImageDownloader_Tests: XCTestCase {
    // MARK: - Pipeline configuration

    func test_pipeline_usesAggressiveDiskCache() {
        // The default `.withURLCache` pipeline keeps processed images in memory
        // only. An aggressive on-disk `DataCache` is required to persist them.
        XCTAssertNotNil(StreamImageDownloader.pipeline.configuration.dataCache)
    }

    func test_pipeline_usesAutomaticDataCachePolicy() {
        // `.automatic` stores the processed (resized) image for requests that
        // carry a resize processor, so avatars are decoded from disk instead of
        // being downscaled again on every cache miss while scrolling.
        if case .automatic = StreamImageDownloader.pipeline.configuration.dataCachePolicy {
            // Expected policy.
        } else {
            XCTFail("Expected the pipeline to use the .automatic data cache policy")
        }
    }

    func test_pipeline_widensImageProcessingQueue() {
        XCTAssertEqual(
            StreamImageDownloader.pipeline.configuration.imageProcessingQueue.maxConcurrentOperationCount,
            4
        )
    }

    func test_pipeline_widensImageDecompressingQueue() {
        XCTAssertEqual(
            StreamImageDownloader.pipeline.configuration.imageDecompressingQueue.maxConcurrentOperationCount,
            4
        )
    }
}
