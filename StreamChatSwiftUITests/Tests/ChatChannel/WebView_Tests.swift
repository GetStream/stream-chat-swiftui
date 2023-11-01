//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import XCTest

class WebView_Tests: StreamChatTestCase {

    private let mockURL = Bundle(for: WebView_Tests.self).url(forResource: "mock", withExtension: "html")!

    func test_webView_snapshot() throws {
        throw XCTSkip("Check it out: https://github.com/pointfreeco/swift-snapshot-testing/issues/625")

        // Given
        let url = mockURL

        // When
        let webView = WebView(
            url: url,
            isLoading: .constant(false),
            title: .constant("Test"),
            error: .constant(nil)
        )
        .applyDefaultSize()

        // Then
        assertSnapshot(matching: webView, as: .image(perceptualPrecision: precision))
    }
}
