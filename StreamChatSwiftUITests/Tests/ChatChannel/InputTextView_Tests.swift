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

    // MARK: - Text Direction

    func test_textAlignment_isNatural_inRTLLayout() {
        // Forcing `.right` on a UITextView causes trailing whitespace to be
        // visually trimmed. Using `.natural` lets bidi resolve trailing
        // spaces so pressing space in an RTL composer is visible.
        let textView = makeTextView(placeholder: "@username", text: "")
        textView.semanticContentAttribute = .forceRightToLeft

        XCTAssertEqual(textView.textAlignment, .natural)
    }

    func test_textAlignment_isNatural_inLTRLayout() {
        let textView = makeTextView(placeholder: "@username", text: "")
        textView.semanticContentAttribute = .forceLeftToRight

        XCTAssertEqual(textView.textAlignment, .natural)
    }

    func test_placeholderAlignment_followsLayoutDirection() {
        let textView = makeTextView(placeholder: "@username", text: "")

        textView.semanticContentAttribute = .forceRightToLeft
        XCTAssertEqual(textView.placeholderLabel.textAlignment, .right)

        textView.semanticContentAttribute = .forceLeftToRight
        XCTAssertEqual(textView.placeholderLabel.textAlignment, .left)
    }

    // MARK: - Placeholder Sizing

    func test_sizeThatFits_whenEmpty_includesMultilinePlaceholderHeight() {
        // A long placeholder at a constrained width must wrap, and the text view's
        // fitting height must grow to fit it so it is never truncated.
        let textView = makeTextView(
            placeholder: "You can't send messages in this channel",
            text: ""
        )
        textView.placeholderLabel.font = .systemFont(ofSize: 40)
        textView.handleTextChange()

        let narrow = CGSize(width: 120, height: CGFloat.greatestFiniteMagnitude)
        let placeholderHeight = textView.placeholderLabel.sizeThatFits(narrow).height
        let fittingHeight = textView.sizeThatFits(narrow).height

        XCTAssertGreaterThanOrEqual(fittingHeight, placeholderHeight)
        XCTAssertGreaterThan(placeholderHeight, 40, "Placeholder should wrap to multiple lines")
    }

    func test_sizeThatFits_whenNotEmpty_ignoresPlaceholder() {
        // Once there is text, the placeholder is hidden and must not influence sizing.
        let textView = makeTextView(placeholder: "A very long placeholder text here", text: "Hi")
        textView.handleTextChange()

        let size = CGSize(width: 120, height: CGFloat.greatestFiniteMagnitude)
        let baseline = UITextView()
        baseline.text = "Hi"

        XCTAssertEqual(
            textView.sizeThatFits(size).height,
            baseline.sizeThatFits(size).height,
            accuracy: 1
        )
    }

    // MARK: - Helpers

    private func makeTextView(placeholder: String, text: String) -> InputTextView {
        let textView = InputTextView()
        textView.placeholderLabel.text = placeholder
        textView.text = text
        return textView
    }
}
