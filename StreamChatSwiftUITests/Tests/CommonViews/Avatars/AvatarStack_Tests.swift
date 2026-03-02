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

final class AvatarStack_Tests: StreamChatTestCase {
    func test_avatarStack_singleAvatar() {
        let size = CGSize(width: 200, height: 60)
        let view = sizeRow(avatarCount: 1)
            .frame(width: size.width, height: size.height)
        
        AssertSnapshot(view, size: size)
    }
    
    func test_avatarStack_twoAvatars() {
        let size = CGSize(width: 230, height: 60)
        let view = sizeRow(avatarCount: 2)
            .frame(width: size.width, height: size.height)
        
        AssertSnapshot(view, size: size)
    }
    
    func test_avatarStack_threeAvatars() {
        let size = CGSize(width: 260, height: 60)
        let view = sizeRow(avatarCount: 3)
            .frame(width: size.width, height: size.height)
        
        AssertSnapshot(view, size: size)
    }
    
    func test_avatarStack_overflow() {
        let size = CGSize(width: 300, height: 60)
        let view = sizeRow(avatarCount: 10)
            .frame(width: size.width, height: size.height)
        
        AssertSnapshot(view, size: size)
    }
    
    // MARK: - Helpers
    
    private let allInitials = ["AB", "CD", "EF", "GH", "IJ", "KL", "MN", "OP", "QR", "ST"]
    
    private func sizeRow(avatarCount: Int) -> some View {
        let avatars: [(url: URL?, initials: String)] = (0..<avatarCount).map { i in
            (nil, allInitials[i % allInitials.count])
        }
        return HStack(spacing: 16) {
            AvatarStack(avatars: avatars, totalCount: avatarCount, size: AvatarSize.medium)
            AvatarStack(avatars: avatars, totalCount: avatarCount, size: AvatarSize.small)
            AvatarStack(avatars: avatars, totalCount: avatarCount, size: AvatarSize.extraSmall)
        }
    }
}
