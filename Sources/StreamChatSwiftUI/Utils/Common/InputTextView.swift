//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import UIKit

@MainActor enum TextSizeConstants {
    static var composerConfig: ComposerConfig { InjectedValues[\.utils].composerConfig }
    static let defaultInputViewHeight: CGFloat = 40.0
    static var minimumHeight: CGFloat {
        composerConfig.inputViewMinHeight
    }

    static var maximumHeight: CGFloat {
        composerConfig.inputViewMaxHeight
    }

    static var minThreshold: CGFloat {
        composerConfig.inputViewMinHeight
    }

    static var cornerRadius: CGFloat {
        composerConfig.inputViewCornerRadius
    }
}

class InputTextView: UITextView, AccessibilityView {
    @Injected(\.colors) private var colors
    @Injected(\.utils) private var utils

    private var didRequestInitialVoiceOverFocus = false
    private var lastReportedPlaceholderHeight: CGFloat = 0

    /// Called when `layoutSubviews` detects the placeholder needs a different
    /// height than what was last reported. The coordinator sets this so the
    /// SwiftUI height binding stays in sync once the view has valid bounds.
    var onPlaceholderHeightChanged: ((_ height: CGFloat) -> Void)?

    /// Label used as placeholder for textView when it's empty.
    open private(set) lazy var placeholderLabel: UILabel = UILabel()
        .withoutAutoresizingMaskConstraints

    /// The minimum height of the text view.
    /// When there is no content in the text view OR the height of the content is less than this value,
    /// the text view will be of this height
    open var minimumHeight: CGFloat {
        TextSizeConstants.minimumHeight
    }

    /// The maximum height of the text view.
    /// When the content in the text view is greater than this height, scrolling will be enabled and the text view's height will be restricted to this value
    open var maximumHeight: CGFloat {
        TextSizeConstants.maximumHeight
    }

    override open var text: String! {
        didSet {
            if !oldValue.isEmpty && text.isEmpty {
                textDidChangeProgrammatically()
            }
        }
    }
    
    var onImagePasted: ((UIImage) -> Void)?

    override open var accessibilityHint: String? {
        // Expose the (possibly dynamic) placeholder as the accessibility hint
        // so VoiceOver announces the command-mode placeholder (e.g. "@username")
        // when the field is empty. `accessibilityHint` does not back
        // `XCUIElement.text` / `XCUIElement.value` / `XCUIElement.label`, so UI
        // tests that assert a cleared composer continue to see an empty value.
        get {
            if text.isEmpty, let placeholder = placeholderLabel.text, !placeholder.isEmpty {
                return placeholder
            }
            return super.accessibilityHint
        }
        set { super.accessibilityHint = newValue }
    }

    override open var semanticContentAttribute: UISemanticContentAttribute {
        didSet {
            placeholderLabel.semanticContentAttribute = semanticContentAttribute
            applyTextAlignmentForCurrentDirection()
        }
    }

    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard superview != nil else { return }

        setAccessibilityIdentifier()
        setUp()
        setUpLayout()
        setUpAppearance()
    }

    override open func didMoveToWindow() {
        super.didMoveToWindow()
        guard window != nil,
              !didRequestInitialVoiceOverFocus,
              UIAccessibility.isVoiceOverRunning else { return }
        didRequestInitialVoiceOverFocus = true
        UIAccessibility.post(notification: .screenChanged, argument: self)
    }

    open func setUp() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTextChange),
            name: UITextView.textDidChangeNotification,
            object: self
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(becomeFirstResponder),
            name: NSNotification.Name(getStreamFirstResponderNotification),
            object: nil
        )
    }

    open func setUpAppearance() {
        backgroundColor = .clear
        textContainer.lineFragmentPadding = 8
        font = InjectedValues[\.utils].composerConfig.inputFont
        textColor = InjectedValues[\.colors].textPrimary

        placeholderLabel.font = font
        placeholderLabel.textColor = InjectedValues[\.colors].inputTextPlaceholder
        applyTextAlignmentForCurrentDirection()
    }

    private func applyTextAlignmentForCurrentDirection() {
        // The text view itself always uses `.natural` alignment so that
        // characters whose visual position depends on bidi resolution
        // (including spaces, especially trailing ones) are rendered
        // correctly. Forcing `.right`/`.left` on a UITextView causes
        // trailing whitespace to be visually trimmed which makes pressing
        // spacebar appear to do nothing in RTL composers.
        // The placeholder follows the configured layout direction so that
        // it appears on the correct side of an empty composer.
        textAlignment = .natural
        switch semanticContentAttribute {
        case .forceRightToLeft:
            placeholderLabel.textAlignment = .right
        case .forceLeftToRight:
            placeholderLabel.textAlignment = .left
        default:
            placeholderLabel.textAlignment = .natural
        }
    }

    open func setUpLayout() {
        addSubview(placeholderLabel)
        placeholderLabel.isAccessibilityElement = false
        placeholderLabel.numberOfLines = 0
        placeholderLabel.adjustsFontForContentSizeCategory = true
        placeholderLabel.setContentCompressionResistancePriority(.streamLow, for: .horizontal)
        NSLayoutConstraint.activate([
            placeholderLabel.leadingAnchor.pin(equalTo: leadingAnchor, constant: directionalLayoutMargins.leading),
            placeholderLabel.trailingAnchor.pin(equalTo: trailingAnchor, constant: -directionalLayoutMargins.trailing),
            placeholderLabel.widthAnchor.pin(equalTo: layoutMarginsGuide.widthAnchor),
            placeholderLabel.topAnchor.pin(equalTo: topAnchor),
            placeholderLabel.bottomAnchor.pin(lessThanOrEqualTo: bottomAnchor),
            placeholderLabel.centerYAnchor.pin(equalTo: centerYAnchor)
        ])
        isScrollEnabled = true
    }

    /// Sets the given text in the current caret position.
    /// In case the caret is selecting a range of text, it replaces that text.
    ///
    /// - Parameter text: A string to replace the text in the caret position.
    open func replaceSelectedText(_ text: String) {
        guard let selectedRange = selectedTextRange else {
            self.text.append(text)
            return
        }

        replace(selectedRange, withText: text)
    }

    open func textDidChangeProgrammatically() {
        delegate?.textViewDidChange?(self)
        handleTextChange()
    }

    @objc open func handleTextChange() {
        placeholderLabel.isHidden = !text.isEmpty
    }

    /// The height required to display the placeholder without truncation.
    /// Returns `0` when the text view has content or the placeholder is hidden.
    var placeholderFittingHeight: CGFloat {
        guard text.isEmpty,
              let placeholderText = placeholderLabel.text,
              !placeholderText.isEmpty,
              bounds.width > 0 else { return 0 }
        let availableWidth = bounds.width - textContainer.lineFragmentPadding * 2
        guard availableWidth > 0 else { return 0 }
        let size = placeholderLabel.sizeThatFits(
            CGSize(width: availableWidth, height: .greatestFiniteMagnitude)
        )
        return size.height
    }

    open func shouldAnimate(_ newText: String) -> Bool {
        abs(newText.count - text.count) < 10
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if TextSizeConstants.defaultInputViewHeight != minimumHeight
            && minimumHeight == frame.size.height {
            let rect = layoutManager.usedRect(for: textContainer)
            let topInset = (frame.size.height - rect.height) / 2.0
            textContainerInset.top = max(0, topInset)
        }

        let neededHeight = placeholderFittingHeight
        if neededHeight > 0, neededHeight != lastReportedPlaceholderHeight {
            lastReportedPlaceholderHeight = neededHeight
            onPlaceholderHeightChanged?(neededHeight)
        }
    }

    override open func paste(_ sender: Any?) {
        super.paste(sender)
        if let pastedImage = UIPasteboard.general.image,
           let onImagePasted {
            onImagePasted(pastedImage)
            return
        }
        handleTextChange()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.scrollToBottom()
        }
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(paste(_:)) && onImagePasted != nil && UIPasteboard.general.image != nil {
            true
        } else {
            super.canPerformAction(action, withSender: sender)
        }
    }
}
