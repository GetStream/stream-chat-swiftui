//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import StreamChat
@testable import StreamChatSwiftUI
import XCTest

final class PaddingsConfig_Tests: XCTestCase {

    func test_paddingsConfig() {
        // Given
        let paddingsConfig = PaddingsConfig(top: 4, bottom: 4, leading: 8, trailing: 8)
        
        // Then
        XCTAssert(paddingsConfig.horizontal == 16)
        XCTAssert(paddingsConfig.vertical == 8)
        XCTAssert(paddingsConfig.bottom == 4)
        XCTAssert(paddingsConfig.top == 4)
        XCTAssert(paddingsConfig.leading == 8)
        XCTAssert(paddingsConfig.trailing == 8)
    }
}
