//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

@MainActor
final class LazyImageExtensions_Tests: StreamChatTestCase {

    func test_imageURL_empty() {
        // Given
        let lazyImageView = LazyImage(imageURL: nil)
            .applyDefaultSize()
                
        // Then
        assertSnapshot(matching: lazyImageView, as: .image(perceptualPrecision: precision))
    }
    
    func test_imageURL_nonEmpty() {
        // Given
        let lazyImageView = LazyImage(
            imageURL: URL(string: "https://vignette.wikia.nocookie.net/starwars/images/2/20/LukeTLJ.jpg")
        )
        .applyDefaultSize()
                
        // Then
        assertSnapshot(matching: lazyImageView, as: .image(perceptualPrecision: precision))
    }
    
    func test_imageRequest_emptyURL() {
        // Given
        let lazyImageView = LazyImage(imageURL: nil) { _ in
            ProgressView()
        }
        .applyDefaultSize()
                
        // Then
        assertSnapshot(matching: lazyImageView, as: .image(perceptualPrecision: precision))
    }
}
