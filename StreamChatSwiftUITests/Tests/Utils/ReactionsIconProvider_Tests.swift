//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import Foundation
@testable import StreamChat
@testable import StreamChatSwiftUI
import SwiftUI
import XCTest

final class ReactionsIconProvider_Tests: StreamChatTestCase {
    
    @Injected(\.colors) var colors
    
    func test_reactionsIconProvider_largeIcon() {
        // Given
        let reaction = MessageReactionType(rawValue: "like")
        
        // When
        let icon = ReactionsIconProvider.icon(for: reaction, useLargeIcons: true)
        
        // Then
        XCTAssertNotNil(icon)
    }
    
    func test_reactionsIconProvider_smallIcon() {
        // Given
        let reaction = MessageReactionType(rawValue: "like")
        
        // When
        let icon = ReactionsIconProvider.icon(for: reaction, useLargeIcons: false)
        
        // Then
        XCTAssertNotNil(icon)
    }
    
    func test_reactionsIconProvider_nonExisting() {
        // Given
        let reaction = MessageReactionType(rawValue: "non-existing")
        
        // When
        let icon = ReactionsIconProvider.icon(for: reaction, useLargeIcons: true)
        
        // Then
        XCTAssertNil(icon)
    }
    
    func test_reactionsIconProvider_currentUserColor() {
        // Given
        let reaction = MessageReactionType(rawValue: "like")
        
        // When
        let color = ReactionsIconProvider.color(for: reaction, userReactionIDs: [reaction])
        
        // Then
        XCTAssert(color == Color(colors.reactionCurrentUserColor!))
    }
    
    func test_reactionsIconProvider_otherUserColor() {
        // Given
        let reaction = MessageReactionType(rawValue: "like")
        
        // When
        let color = ReactionsIconProvider.color(for: reaction, userReactionIDs: [])
        
        // Then
        XCTAssert(color == Color(colors.reactionOtherUserColor!))
    }
}
