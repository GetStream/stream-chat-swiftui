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

final class VideoPlayIndicatorView_Tests: StreamChatTestCase {
    func test_videoPlayIndicator_default() {
        let size = CGSize(width: 280, height: 100)
        let view = stateRow(playing: false)
            .frame(width: size.width, height: size.height)

        AssertSnapshot(view, size: size)
    }

    func test_videoPlayIndicator_playing() {
        let size = CGSize(width: 280, height: 100)
        let view = stateRow(playing: true)
            .frame(width: size.width, height: size.height)

        AssertSnapshot(view, size: size)
    }

    // MARK: - Helpers

    private func stateRow(playing: Bool) -> some View {
        HStack(spacing: 12) {
            VideoPlayIndicatorView(size: VideoPlayIndicatorSize.extraLarge, playing: playing)
            VideoPlayIndicatorView(size: VideoPlayIndicatorSize.large, playing: playing)
            VideoPlayIndicatorView(size: VideoPlayIndicatorSize.medium, playing: playing)
            VideoPlayIndicatorView(size: VideoPlayIndicatorSize.small, playing: playing)
        }
    }
}
