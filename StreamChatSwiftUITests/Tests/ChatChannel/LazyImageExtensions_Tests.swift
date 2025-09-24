//
// Copyright © 2025 Stream.io Inc. All rights reserved.
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
        let lazyImageView = LazyImage(imageURL: nil) { state in
            if let image = state.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        }
        .applyDefaultSize()
                
        // Then
        assertSnapshot(matching: lazyImageView, as: .image(perceptualPrecision: precision))
    }
    
    func test_imageURL_nonEmpty() {
        // Given
        let lazyImageView = LazyImage(
            imageURL: .localYodaImage
        ) { state in
            if let image = state.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        }
        .applyDefaultSize()
                
        // Then
        assertSnapshot(matching: lazyImageView, as: .image(perceptualPrecision: precision))
    }
    
    func test_imageRequest_emptyURL() {
        // Given
        let lazyImageView = LazyImage(request: nil) { _ in
            ProgressView()
        }
        .applyDefaultSize()
                
        // Then
        assertSnapshot(matching: lazyImageView, as: .image(perceptualPrecision: precision))
    }
}
