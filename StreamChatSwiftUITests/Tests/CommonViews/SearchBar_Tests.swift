//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChatSwiftUI
import SwiftUI
import XCTest

@MainActor
final class SearchBar_Tests: StreamChatTestCase {
    private let size = CGSize(width: 360, height: 60)

    func test_searchBar_empty_snapshot() {
        let view = SearchBar(text: .constant(""))
            .applySize(size)

        AssertSnapshot(view, variants: [.defaultLight, .defaultDark], size: size)
    }

    func test_searchBar_withText_snapshot() {
        let view = SearchBar(text: .constant("Hello"))
            .applySize(size)

        AssertSnapshot(view, variants: [.defaultLight, .defaultDark], size: size)
    }
}
