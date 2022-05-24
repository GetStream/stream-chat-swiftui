//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import UIKit

struct TextSizeConstants {
    static let composerConfig = InjectedValues[\.utils].composerConfig
    static let defaultInputViewHeight: CGFloat = 38.0
    static var minimumHeight: CGFloat {
        composerConfig.inputViewMinHeight
    }

    static let maximumHeight: CGFloat = 76
    static var minThreshold: CGFloat {
        composerConfig.inputViewMinHeight
    }
}

class InputTextView: UITextView {
    @Injected(\.colors) private var colors
    @Injected(\.utils) private var utils
        
    /// Label used as placeholder for textView when it's empty.
    open private(set) lazy var placeholderLabel: UILabel = UILabel()
        .withoutAutoresizingMaskConstraints
        
    /// The minimum height of the text view.
    /// When there is no content in the text view OR the height of the content is less than this value,
    /// the text view will be of this height
    open var minimumHeight: CGFloat {
        TextSizeConstants.minimumHeight
    }
    
    /// The constraint responsible for setting the height of the text view.
    open var heightConstraint: NSLayoutConstraint?
    
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
        
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard superview != nil else { return }
        
        setUp()
        setUpLayout()
        setUpAppearance()
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
            name: NSNotification.Name(firstResponderNotification),
            object: nil
        )
    }
    
    open func setUpAppearance() {
        backgroundColor = .clear
        textContainer.lineFragmentPadding = 8
        font = utils.composerConfig.inputFont
        textColor = colors.text
        textAlignment = .natural
        
        placeholderLabel.font = font
        placeholderLabel.textAlignment = .center
        placeholderLabel.textColor = colors.composerPlaceholderColor
    }
    
    open func setUpLayout() {
        embed(
            placeholderLabel,
            insets: .init(
                top: .zero,
                leading: directionalLayoutMargins.leading,
                bottom: .zero,
                trailing: .zero
            )
        )
        placeholderLabel.pin(anchors: [.centerY], to: self)
        
        heightConstraint = heightAnchor.constraint(equalToConstant: minimumHeight)
        heightConstraint?.isActive = true
        isScrollEnabled = false
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
        setTextViewHeight()
    }

    open func setTextViewHeight() {
        var heightToSet = minimumHeight
        let contentHeight = sizeThatFits(bounds.size).height

        if contentHeight <= minimumHeight {
            heightToSet = minimumHeight
        } else if contentHeight >= maximumHeight {
            heightToSet = maximumHeight
        } else {
            heightToSet = contentHeight
        }

        if heightConstraint?.constant != heightToSet {
            heightConstraint?.constant = heightToSet
            isScrollEnabled = heightToSet > minimumHeight
            layoutIfNeeded()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if TextSizeConstants.defaultInputViewHeight != minimumHeight {
            let rect = layoutManager.usedRect(for: textContainer)
            let topInset = (bounds.size.height - rect.height) / 2.0
            textContainerInset.top = max(0, topInset)
        }
    }
        
    override open func paste(_ sender: Any?) {
        super.paste(sender)
        handleTextChange()
        
        // This is due to bug in UITextView where the scroll sometimes disables
        // when a very long text is pasted in it.
        // Doing this ensures that it doesn't happen
        // Reference: https://stackoverflow.com/a/33194525/3825788
        isScrollEnabled = false
        isScrollEnabled = true
    }
}
