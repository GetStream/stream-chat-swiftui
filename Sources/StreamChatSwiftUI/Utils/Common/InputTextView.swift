//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import UIKit

class InputTextView: UITextView {
    @Injected(\.colors) private var colors
    
    /// Label used as placeholder for textView when it's empty.
    open private(set) lazy var placeholderLabel: UILabel = UILabel()
        .withoutAutoresizingMaskConstraints
        
    /// The minimum height of the text view.
    /// When there is no content in the text view OR the height of the content is less than this value,
    /// the text view will be of this height
    open var minimumHeight: CGFloat {
        34.0
    }
    
    /// The constraint responsible for setting the height of the text view.
    open var heightConstraint: NSLayoutConstraint?
    
    /// The maximum height of the text view.
    /// When the content in the text view is greater than this height, scrolling will be enabled and the text view's height will be restricted to this value
    open var maximumHeight: CGFloat {
        76.0
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
    }
    
    open func setUpAppearance() {
        backgroundColor = .clear
        textContainer.lineFragmentPadding = 8
        font = UIFont.preferredFont(forTextStyle: .body)
        textColor = colors.text
        textAlignment = .natural
        
        placeholderLabel.font = font
        placeholderLabel.textAlignment = .center
        placeholderLabel.textColor = colors.subtitleText
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

        if contentSize.height <= minimumHeight {
            heightToSet = minimumHeight
        } else if contentSize.height >= maximumHeight {
            heightToSet = maximumHeight
        } else {
            heightToSet = contentSize.height
        }

        heightConstraint?.constant = heightToSet
        isScrollEnabled = heightToSet > minimumHeight
        layoutIfNeeded()
    }
}
