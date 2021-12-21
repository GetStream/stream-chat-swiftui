//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import SwiftUI
import UIKit

/// SwiftUI wrapper for a text field with multiple rows.
struct ComposerTextInputView: UIViewRepresentable {
    @Binding var text: String
    @Binding var height: CGFloat
    
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
                uiView.text = text
                uiView.handleTextChange()
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(textInput: self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate, NSLayoutManagerDelegate {
        weak var textView: InputTextView?

        var textInput: ComposerTextInputView
        
        init(textInput: ComposerTextInputView) {
            self.textInput = textInput
        }

        func textViewDidChange(_ textView: UITextView) {
            textInput.text = textView.text
        }

        func textView(
            _ textView: UITextView,
            shouldChangeTextIn range: NSRange,
            replacementText text: String
        ) -> Bool {
            true
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
