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

final class AvatarTests: StreamChatTestCase {
    func test_groupAvatar_placeholders() async throws {
        // Given
        let size = CGSize(width: 130, height: 130)
        let view = HStack(spacing: 2) {
            VStack(spacing: 2) {
                ForEach(AvatarSize.standardSizes, id: \.self) { size in
                    GroupAvatar(
                        url: TestImages.yoda.url,
                        size: size
                    )
                }
            }
            VStack(spacing: 2) {
                ForEach(AvatarSize.standardSizes, id: \.self) { size in
                    GroupAvatar(
                        url: TestImages.yoda.url,
                        size: size
                    )
                }
            }
        }
        .frame(width: size.width, height: size.height)
        
        // Then
        AssertSnapshot(view, size: size)
    }
    
    func test_userAvatar_placeholders() async throws {
        // Given
        let size = CGSize(width: 130, height: 130)
        let view = HStack(spacing: 2) {
            VStack(spacing: 2) {
                ForEach(AvatarSize.standardSizes, id: \.self) { size in
                    UserAvatar(
                        url: nil,
                        initials: "EC",
                        size: size,
                        indicator: .online
                    )
                }
            }
            VStack(spacing: 2) {
                ForEach(AvatarSize.standardSizes, id: \.self) { size in
                    UserAvatar(
                        url: nil,
                        initials: "",
                        size: size,
                        indicator: .offline
                    )
                }
            }
        }
        .frame(width: size.width, height: size.height)
        
        // Then
        AssertSnapshot(view, size: size)
    }
}
