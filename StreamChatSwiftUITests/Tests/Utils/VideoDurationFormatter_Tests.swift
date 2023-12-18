//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import Foundation
@testable import StreamChat
@testable import StreamChatSwiftUI
import SwiftUI
import XCTest

final class VideoDurationFormatter_Tests: XCTestCase {

    func test_videoDurationFormatter_seconds() {
        // Given
        let formatter: VideoDurationFormatter = DefaultVideoDurationFormatter()
        
        // When
        let formatted = formatter.format(5)
        
        // Then
        XCTAssert(formatted == "00:05")
    }

    func test_videoDurationFormatter_minutes() {
        // Given
        let formatter: VideoDurationFormatter = DefaultVideoDurationFormatter()
        
        // When
        let formatted = formatter.format(65)
        
        // Then
        XCTAssert(formatted == "01:05")
    }
    
    func test_videoDurationFormatter_hours() {
        // Given
        let formatter: VideoDurationFormatter = DefaultVideoDurationFormatter()
        
        // When
        let formatted = formatter.format(3605)
        
        // Then
        XCTAssert(formatted == "60:05")
    }
}
