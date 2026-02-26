//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

final class BadgeCount_Tests: StreamChatTestCase {
    func test_badgeCount_singleDigit() {
        let size = CGSize(width: 200, height: 60)
        let view = sizeRow(count: 3)
            .frame(width: size.width, height: size.height)
        
        AssertSnapshot(view, size: size)
    }
    
    func test_badgeCount_doubleDigit() {
        let size = CGSize(width: 200, height: 60)
        let view = sizeRow(count: 42)
            .frame(width: size.width, height: size.height)
        
        AssertSnapshot(view, size: size)
    }
    
    func test_badgeCount_clampedAt99() {
        let size = CGSize(width: 200, height: 60)
        let view = sizeRow(count: 150)
            .frame(width: size.width, height: size.height)
        
        AssertSnapshot(view, size: size)
    }
    
    // MARK: - Helpers
    
    private func sizeRow(count: Int) -> some View {
        HStack(spacing: 12) {
            BadgeCount(count: count, size: AvatarSize.medium)
            BadgeCount(count: count, size: AvatarSize.small)
            BadgeCount(count: count, size: AvatarSize.extraSmall)
        }
    }
}
