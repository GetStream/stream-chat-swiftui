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

final class UserAvatar_Tests: StreamChatTestCase {
    func test_userAvatar_placeholders() async throws {
        // Given
        let size = CGSize(width: 320, height: 320)
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
            VStack(spacing: 2) {
                ForEach(AvatarSize.standardSizes, id: \.self) { size in
                    UserAvatar(
                        url: nil,
                        initials: "",
                        size: size,
                        indicator: .offline
                    )
                    .redacted(reason: .placeholder)
                }
            }
        }
        .frame(width: size.width, height: size.height)
        
        // Then
        AssertSnapshot(view, size: size)
    }
}
