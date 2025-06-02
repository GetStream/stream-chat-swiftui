//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

final class MessageAvatarView_Tests: StreamChatTestCase {
    
    func test_defaultPlaceholder_snapshot() {
        let size = CGSize.defaultAvatarSize
        let view = MessageAvatarView(avatarURL: nil)
        AssertSnapshot(view, variants: [.defaultLight], size: size)
    }
    
    func test_colorFilledPlaceholder_snapshot() {
        let size = CGSize.defaultAvatarSize
        let view = MessageAvatarView(
            avatarURL: nil,
            placeholder: {
                Rectangle().foregroundStyle(Color.red)
            }
        )
        AssertSnapshot(view, variants: [.defaultLight], size: size)
    }
}
