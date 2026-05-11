//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChatSwiftUI
import XCTest

@MainActor
final class InputTextView_Tests: StreamChatTestCase {
    // MARK: - Accessibility Value

    func test_accessibilityValue_whenTextIsEmpty_returnsPlaceholder() {
        let textView = makeTextView(placeholder: "@username", text: "")

        XCTAssertEqual(textView.accessibilityValue, "@username")
    }

    func test_accessibilityValue_whenTextIsNonEmpty_returnsSuperValue() {
        let textView = makeTextView(placeholder: "@username", text: "hello")

        XCTAssertNotEqual(textView.accessibilityValue, "@username")
    }

    func test_accessibilityValue_whenPlaceholderIsEmpty_doesNotOverride() {
        let textView = makeTextView(placeholder: "", text: "")

        XCTAssertNotEqual(textView.accessibilityValue, "")
    }

    // MARK: - Helpers

    private func makeTextView(placeholder: String, text: String) -> InputTextView {
        let textView = InputTextView()
        textView.placeholderLabel.text = placeholder
        textView.text = text
        return textView
    }
}
