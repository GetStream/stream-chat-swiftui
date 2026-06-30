//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChatSwiftUI
import SwiftUI
import XCTest

@MainActor
final class SnackBarView_Tests: StreamChatTestCase {
    func test_snackBarView_default() {
        let view = SnackBarView(text: "Muted Elena Barros")
            .frame(width: 375)

        AssertSnapshot(view, variants: [.defaultLight, .defaultDark])
    }

    func test_snackBarView_longText() {
        let view = SnackBarView(text: "Muted a user with a very long display name that should be truncated")
            .frame(width: 375)

        AssertSnapshot(view, variants: [.defaultLight])
    }

    func test_snackBarView_unmute() {
        let view = SnackBarView(text: "Unmuted Elena Barros")
            .frame(width: 375)

        AssertSnapshot(view, variants: [.defaultLight])
    }

    func test_snackBarView_extraExtraExtraLarge() {
        let view = SnackBarView(text: "Hold to record. Release to save.")
            .frame(width: 375)

        AssertSnapshot(view, variants: [.extraExtraExtraLargeLight])
    }
}
