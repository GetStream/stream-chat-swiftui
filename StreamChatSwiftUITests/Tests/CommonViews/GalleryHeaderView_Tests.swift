//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import SwiftUI
import XCTest

final class GalleryHeaderView_Tests: StreamChatTestCase {
    let size = CGSize(width: 300, height: 60)
    
    func test_default_snapshot() {
        // When
        let view = GalleryHeaderView(title: "Title", subtitle: "Subtitle", isShown: .constant(false))
            .applySize(size)
        
        // Then
        AssertSnapshot(view, variants: [.defaultLight], size: size)
    }
    
    func test_customized_snapshot() {
        // When
        setThemedNavigationBarAppearance()
        let view = GalleryHeaderView(title: "Title", subtitle: "Subtitle", isShown: .constant(false))
            .applySize(size)
        
        // Then
        AssertSnapshot(view, variants: [.defaultLight], size: size)
    }
}
