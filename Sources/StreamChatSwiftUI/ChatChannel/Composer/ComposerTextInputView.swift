//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import SwiftUI
import UIKit

/// SwiftUI wrapper for a text field with multiple rows.
struct ComposerTextInputView: UIViewRepresentable {
    @Binding var text: String
    @Binding var height: CGFloat
    @Binding var selectedRangeLocation: Int
    
    var placeholder: String
    var maxMessageLength: Int?
    
    func makeUIView(context: Context) -> InputTextView {
        let inputTextView = InputTextView()
        context.coordinator.textView = inputTextView
        inputTextView.delegate = context.coordinator
        inputTextView.layoutManager.delegate = context.coordinator
        inputTextView.placeholderLabel.text = placeholder
        
        return inputTextView
    }
    
    func updateUIView(_ uiView: InputTextView, context: Context) {
        DispatchQueue.main.async {
            if uiView.markedTextRange == nil {
                uiView.selectedRange.location = selectedRangeLocation
                uiView.text = text
                uiView.handleTextChange()
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
            textInput.selectedRangeLocation = textView.selectedRange.location
            textInput.text = textView.text
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
        
        func layoutManager(
            _ layoutManager: NSLayoutManager,
            didCompleteLayoutFor textContainer: NSTextContainer?,
            atEnd layoutFinishedFlag: Bool
        ) {
            DispatchQueue.main.async { [weak self] in
                guard let view = self?.textView else {
                    return
                }
                let size = view.sizeThatFits(view.bounds.size)
                if self?.textInput.height != size.height {
                    self?.textInput.height = size.height
                }
            }
        }
    }
}
