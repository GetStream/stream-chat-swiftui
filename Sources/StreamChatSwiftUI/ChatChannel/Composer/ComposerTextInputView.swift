//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import SwiftUI
import UIKit

/// SwiftUI wrapper for a text field with multiple rows.
struct ComposerTextInputView: UIViewRepresentable {
    @Binding var text: String
    @Binding var height: CGFloat
    @Binding var selectedRangeLocation: Int
    @Binding var isFirstResponder: Bool
    
    var placeholder: String
    
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
                switch isFirstResponder {
                case true: uiView.becomeFirstResponder()
                case false: uiView.resignFirstResponder()
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(textInput: self, isFirstResponder: $isFirstResponder)
    }
    
    class Coordinator: NSObject, UITextViewDelegate, NSLayoutManagerDelegate {
        weak var textView: InputTextView?

        var textInput: ComposerTextInputView
        var isFirstResponder: Binding<Bool>
        
        init(
            textInput: ComposerTextInputView,
            isFirstResponder: Binding<Bool>
        ) {
            self.textInput = textInput
            self.isFirstResponder = isFirstResponder
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
            true
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            isFirstResponder.wrappedValue = true
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            isFirstResponder.wrappedValue = false
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
