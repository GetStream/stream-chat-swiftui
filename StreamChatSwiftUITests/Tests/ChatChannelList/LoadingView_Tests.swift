//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class LoadingView_Tests: StreamChatTestCase {

    func test_redactedLoadingView_snapshot() {
        // Given
        let factory = DefaultViewFactory.shared
        
        // When
        let view = RedactedLoadingView(factory: factory)
            .frame(width: defaultScreenSize.width, height: defaultScreenSize.height)
                
        // Then
        assertSnapshot(matching: view, as: .image)
    }
    
    func test_loadingView_snapshot() {
        // Given
        let view = LoadingView()
            .frame(width: defaultScreenSize.width, height: defaultScreenSize.height)
                
        // Then
        assertSnapshot(matching: view, as: .image)
    }
}
