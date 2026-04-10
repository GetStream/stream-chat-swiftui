//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

@MainActor class LoadingSpinnerView_Tests: StreamChatTestCase {

    func test_loadingSpinnerView_indeterminate_snapshot() {
        let view = LoadingSpinnerView(size: LoadingSpinnerSize.large)
            .frame(width: 64, height: 64)
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_loadingSpinnerView_determinateZero_snapshot() {
        let view = LoadingSpinnerView(size: LoadingSpinnerSize.large, progress: 0)
            .frame(width: 64, height: 64)
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_loadingSpinnerView_determinateHalf_snapshot() {
        let view = LoadingSpinnerView(size: LoadingSpinnerSize.large, progress: 0.5)
            .frame(width: 64, height: 64)
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_loadingSpinnerView_determinateFull_snapshot() {
        let view = LoadingSpinnerView(size: LoadingSpinnerSize.large, progress: 1.0)
            .frame(width: 64, height: 64)
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_loadingSpinnerView_bordered_snapshot() {
        let view = LoadingSpinnerView(size: LoadingSpinnerSize.large, bordered: true)
            .frame(width: 64, height: 64)
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_loadingSpinnerView_medium_snapshot() {
        let view = LoadingSpinnerView(size: LoadingSpinnerSize.medium)
            .frame(width: 64, height: 64)
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_loadingSpinnerView_medium_determinateHalf_snapshot() {
        let view = LoadingSpinnerView(size: LoadingSpinnerSize.medium, progress: 0.5)
            .frame(width: 64, height: 64)
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }

    func test_loadingSpinnerView_small_snapshot() {
        let view = LoadingSpinnerView(size: LoadingSpinnerSize.small)
            .frame(width: 64, height: 64)
        AssertSnapshot(view, variants: .onlyUserInterfaceStyles)
    }
}
