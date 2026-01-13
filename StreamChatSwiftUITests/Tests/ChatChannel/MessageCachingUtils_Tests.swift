//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import XCTest

class MessageCachingUtils_Tests: StreamChatTestCase {
    func test_messageCachingUtils_recreatingCache() {
        // Given
        let utils = MessageCachingUtils()
        utils.jumpToReplyId = "test"

        // When
        let initial = utils.jumpToReplyId
        utils.clearCache()
        let after = utils.jumpToReplyId

        // Then
        XCTAssertEqual("test", initial)
        XCTAssertNil(after)
    }
}
