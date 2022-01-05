//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import SwiftUI
import UIKit

/// SwiftUI wrapper for displaying links in a text view.
struct LinkTextView: UIViewRepresentable {
    var text: String
    var width: CGFloat
    
    func makeUIView(context: Context) -> UITextView {
        let textView = OnlyLinkTappableTextView()
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.isUserInteractionEnabled = true
        textView.isScrollEnabled = false
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.dataDetectorTypes = .link
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true
        textView.text = text
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        DispatchQueue.main.async {
            let size = text.frameSize(maxWidth: width)
            uiView.frame.size = size
        }
    }
}

/// Text View that ignores all user interactions except touches on links
class OnlyLinkTappableTextView: UITextView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let range = characterRange(at: point),
           !range.isEmpty,
           let position = closestPosition(to: point, within: range),
           let styles = textStyling(at: position, in: .forward),
           styles[.link] != nil {
            return super.hitTest(point, with: event)
        } else {
            return nil
        }
    }
}

extension String {
    func frameSize(maxWidth: CGFloat? = nil, maxHeight: CGFloat? = nil) -> CGSize {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.preferredFont(forTextStyle: .body)
        ]
        let attributedText = NSAttributedString(string: self, attributes: attributes)
        let width = maxWidth != nil ? min(maxWidth!, CGFloat.greatestFiniteMagnitude) : CGFloat.greatestFiniteMagnitude
        let height = maxHeight != nil ? min(maxHeight!, CGFloat.greatestFiniteMagnitude) : CGFloat.greatestFiniteMagnitude
        let constraintBox = CGSize(width: width, height: height)
        let rect = attributedText.boundingRect(
            with: constraintBox,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        .integral
        
        return rect.size
    }
}
