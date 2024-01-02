//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
@testable import StreamChatSwiftUI
import XCTest

final class SortReactions_Tests: StreamChatTestCase {
    
    @Injected(\.utils) var utils
    @Injected(\.images) var images

    func test_utils_defaultSorting() {
        // Given
        let reactions = images.availableReactions.keys
            .map { $0 }
        let expected: [MessageReactionType] = [
            .init(rawValue: "haha"),
            .init(rawValue: "like"),
            .init(rawValue: "love"),
            .init(rawValue: "sad"),
            .init(rawValue: "wow")
        ]
        
        // When
        let sorted = reactions.sorted(by: utils.sortReactions)
        
        // Then
        XCTAssert(sorted == expected)
    }
    
    func test_utils_customSorting() {
        // Given
        let reactions = images.availableReactions.keys
            .map { $0 }
        let expected: [MessageReactionType] = [
            .init(rawValue: "wow"),
            .init(rawValue: "sad"),
            .init(rawValue: "love"),
            .init(rawValue: "like"),
            .init(rawValue: "haha")
        ]
        utils.sortReactions = { lhs, rhs in
            lhs.rawValue > rhs.rawValue
        }
        
        // When
        let sorted = reactions.sorted(by: utils.sortReactions)
        
        // Then
        XCTAssert(sorted == expected)
    }
}
