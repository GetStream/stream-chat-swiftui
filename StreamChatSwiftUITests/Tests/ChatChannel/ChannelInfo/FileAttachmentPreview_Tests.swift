//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

@testable import SnapshotTesting
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import SwiftUI
import XCTest

class FileAttachmentPreview_Tests: StreamChatTestCase {
    func test_fileAttachmentPreview_pdf() {
        let view = FileAttachmentPreview(
            title: "Document title",
            url: URL.localYodaQuote
        ).applyDefaultSize()
        
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_fileAttachmentPreview_navigationBarAppearance() {
        setThemedNavigationBarAppearance()
        
        let view = FileAttachmentPreview(
            title: "Document title",
            url: URL.localYodaQuote
        ).applyDefaultSize()
        
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
}
