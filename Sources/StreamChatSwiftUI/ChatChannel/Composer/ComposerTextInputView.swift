//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SwiftUI
import UIKit

/// SwiftUI wrapper for a text field with multiple rows.
struct ComposerTextInputView: UIViewRepresentable {

    @Injected(\.utils) private var utils

    @Binding var text: String
    @Binding var height: CGFloat
    @Binding var selectedRangeLocation: Int

    var placeholder: String
    var editable: Bool
    var maxMessageLength: Int?
    var currentHeight: CGFloat

    func makeUIView(context: Context) -> InputTextView {
        let inputTextView: InputTextView
        if #available(iOS 16.0, *) {
            inputTextView = InputTextView(usingTextLayoutManager: false)
        } else {
            inputTextView = InputTextView()
        }
        context.coordinator.textView = inputTextView
        inputTextView.delegate = context.coordinator
        inputTextView.isEditable = editable
        inputTextView.layoutManager.delegate = context.coordinator
        inputTextView.placeholderLabel.text = placeholder
        inputTextView.contentInsetAdjustmentBehavior = .never
        inputTextView.setContentCompressionResistancePriority(.streamLow, for: .horizontal)

        if utils.messageListConfig.becomesFirstResponderOnOpen {
            inputTextView.becomeFirstResponder()
        }

        return inputTextView
    }

    func updateUIView(_ uiView: InputTextView, context: Context) {
        DispatchQueue.main.async {
            // Clear marked text if text is reset
            let canUpdate = uiView.markedTextRange == nil || text.isEmpty
            if canUpdate {
                var shouldAnimate = false
                if uiView.text != text {
                    let previousLocation = selectedRangeLocation
                    shouldAnimate = uiView.shouldAnimate(text)
                    uiView.text = text
                    selectedRangeLocation = previousLocation
                }
                uiView.selectedRange.location = selectedRangeLocation
                uiView.isEditable = editable
                uiView.placeholderLabel.text = placeholder
                uiView.handleTextChange()
                context.coordinator.updateHeight(uiView, shouldAnimate: shouldAnimate)
                if uiView.frame.size.height != currentHeight {
                    uiView.frame.size = CGSize(
                        width: uiView.frame.size.width,
                        height: currentHeight
                    )
                }
                if uiView.contentSize.height != height {
                    uiView.contentSize.height = height
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(textInput: self, maxMessageLength: maxMessageLength)
    }

    class Coordinator: NSObject, UITextViewDelegate, NSLayoutManagerDelegate {
        weak var textView: InputTextView?

        var textInput: ComposerTextInputView
        var maxMessageLength: Int?

        init(
            textInput: ComposerTextInputView,
            maxMessageLength: Int?
        ) {
            self.textInput = textInput
            self.maxMessageLength = maxMessageLength
        }

        func textViewDidChange(_ textView: UITextView) {
            let shouldAnimate = (textView as? InputTextView)?.shouldAnimate(textInput.text) ?? false
            textInput.text = textView.text
            textInput.selectedRangeLocation = textView.selectedRange.location
            updateHeight(textView, shouldAnimate: shouldAnimate)
        }

        func updateHeight(_ textView: UITextView, shouldAnimate: Bool) {
            var height = textView.sizeThatFits(textView.bounds.size).height
            if height < TextSizeConstants.minThreshold {
                height = TextSizeConstants.minimumHeight
            }
            if textInput.height != height {
                if shouldAnimate {
                    withAnimation {
                        textInput.height = height
                    }
                } else {
                    textInput.height = height
                }
            }
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            textInput.selectedRangeLocation = textView.selectedRange.location
        }

        func textView(
            _ textView: UITextView,
            shouldChangeTextIn range: NSRange,
            replacementText text: String
        ) -> Bool {
            guard let maxMessageLength = maxMessageLength else { return true }
            let newMessageLength = textView.text.count + (text.count - range.length)
            return newMessageLength <= maxMessageLength
        }
    }
}

extension UITextView {
    func scrollToBottom() {
        let textCount: Int = text.count
        guard textCount >= 1 else { return }
        scrollRangeToVisible(NSRange(location: textCount - 1, length: 1))
    }
}
