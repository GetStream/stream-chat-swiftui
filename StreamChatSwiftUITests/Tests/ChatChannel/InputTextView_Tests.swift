//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChatSwiftUI
import XCTest

@MainActor
final class InputTextView_Tests: StreamChatTestCase {
    // MARK: - Accessibility Hint

    func test_accessibilityHint_whenTextIsEmpty_returnsPlaceholder() {
        let textView = makeTextView(placeholder: "@username", text: "")

        XCTAssertEqual(textView.accessibilityHint, "@username")
    }

    func test_accessibilityHint_whenTextIsNonEmpty_returnsSuperHint() {
        // While the user is typing, VoiceOver should announce the typed text
        // as the value rather than the placeholder as a hint. Verify the
        // override yields exactly the same hint as a plain UITextView would.
        let textView = makeTextView(placeholder: "@username", text: "hello")
        let baseline = UITextView()
        baseline.text = "hello"

        XCTAssertEqual(textView.accessibilityHint, baseline.accessibilityHint)
    }

    func test_accessibilityHint_whenPlaceholderIsEmpty_doesNotOverride() {
        // With no placeholder text, the override has nothing to expose and
        // should fall back to UITextView's default hint behaviour.
        let textView = makeTextView(placeholder: "", text: "")
        let baseline = UITextView()

        XCTAssertEqual(textView.accessibilityHint, baseline.accessibilityHint)
    }

    // MARK: - Regression guards

    func test_accessibilityValue_whenTextIsEmpty_isEmpty() {
        let textView = makeTextView(placeholder: "@username", text: "")

        // `accessibilityValue` backs `XCUIElement.value` in UI tests. Keep it
        // empty when the composer is empty so UI tests can assert cleared state.
        XCTAssertTrue((textView.accessibilityValue ?? "").isEmpty)
    }

    func test_accessibilityLabel_doesNotFallBackToPlaceholder() {
        // `XCUIElement.text` falls back to `accessibilityLabel` when the value
        // is empty, so the placeholder must not leak into the label or UI tests
        // asserting `assertComposerText("")` will see the placeholder string.
        let textView = makeTextView(placeholder: "@username", text: "")

        XCTAssertNotEqual(textView.accessibilityLabel, "@username")
    }

    // MARK: - Helpers

    private func makeTextView(placeholder: String, text: String) -> InputTextView {
        let textView = InputTextView()
        textView.placeholderLabel.text = placeholder
        textView.text = text
        return textView
    }
}
