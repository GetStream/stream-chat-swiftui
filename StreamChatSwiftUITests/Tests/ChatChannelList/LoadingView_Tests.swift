//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import XCTest

@MainActor class LoadingView_Tests: StreamChatTestCase {
    func test_redactedLoadingView_snapshot() {
        // Given
        let factory = DefaultViewFactory.shared

        // When
        let view = RedactedLoadingView(factory: factory)
            .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }

    func test_loadingView_snapshot() {
        // Given
        let view = LoadingView()
            .applyDefaultSize()

        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
}
