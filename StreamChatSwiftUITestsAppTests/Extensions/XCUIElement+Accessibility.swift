//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import XCTest

extension XCUIElement {
    /// Reads the element's accessibility hint from the accessibility tree.
    ///
    /// `InputTextView` exposes its placeholder through `accessibilityHint` while
    /// keeping the decorative placeholder label out of the tree, so UI tests
    /// must read the hint instead of querying `staticTexts`.
    var accessibilityHintValue: String {
        (value(forKey: "accessibilityHint") as? String) ?? ""
    }
}
