//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import SwiftUI
import XCTest

@MainActor class StreamAsyncImage_Tests: StreamChatTestCase {
    // Regression: a content closure that renders nothing outside `.success`
    // (as `LinkAttachmentView` does) must still trigger the image load.
    func test_streamAsyncImage_loadsImage_whenContentRendersNothingForNonSuccessPhase() {
        // Given
        StreamAsyncImageTestHooks.syncResolver = nil
        let mediaLoader = streamChat?.utils.mediaLoader as? MediaLoader_Mock
        let url = URL.localYodaImage
        let view = StreamAsyncImage(url: url) { phase in
            if let image = phase.image {
                image.resizable()
            }
        }

        // When
        showView(view)

        let expectation = expectation(description: "Image load task fired")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: defaultTimeout)

        // Then
        XCTAssertEqual(mediaLoader?.loadImageCalled, true)
        XCTAssertEqual(mediaLoader?.loadedURLs.first, url)
    }
}
