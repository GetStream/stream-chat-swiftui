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
    func test_channelAvatar_placeholders() async throws {
        // Given
        let view = HStack(spacing: 2) {
            VStack(spacing: 2) {
                ForEach(ComponentSize.allCases, id: \.self) { size in
                    ChannelAvatar(
                        url: TestImages.yoda.url,
                        size: size,
                        border: true
                    )
                }
            }
            VStack(spacing: 2) {
                ForEach(ComponentSize.allCases, id: \.self) { size in
                    ChannelAvatar(
                        url: TestImages.yoda.url,
                        size: size,
                        border: true
                    )
                }
            }
        }
        .frame(width: 130, height: 130)
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
    
    func test_userAvatar_placeholders() async throws {
        // Given
        let view = HStack(spacing: 2) {
            VStack(spacing: 2) {
                ForEach(ComponentSize.allCases, id: \.self) { size in
                    UserAvatar(
                        url: nil,
                        initials: "EC",
                        size: size,
                        indicator: .online,
                        border: false
                    )
                }
            }
            VStack(spacing: 2) {
                ForEach(ComponentSize.allCases, id: \.self) { size in
                    UserAvatar(
                        url: nil,
                        initials: "",
                        size: size,
                        indicator: .offline,
                        border: true
                    )
                }
            }
        }
        .frame(width: 130, height: 130)
        
        // Then
        assertSnapshot(matching: view, as: .image(perceptualPrecision: precision))
    }
}
