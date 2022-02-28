//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import UIKit

private var renderViews: [EmojiSource: UIImageView] = [:]

// MARK: Public

extension UITextView {
    /// Configures this UITextView to display custom emojis.
    ///
    /// - Parameter emojis: A dictionary of emoji keyed by its shortcode.
    /// - Parameter rendering: The rendering options. Defaults to `.highQuality`.
    public func configureEmojis(_ emojis: [String: EmojiSource], rendering: EmojiRendering = .highQuality) {
        applyEmojis(emojis, rendering: rendering)

        NotificationCenter.default.addObserver(
            forName: UITextView.textDidChangeNotification,
            object: self,
            queue: .main
        ) { [weak self] _ in
            self?.applyEmojis(emojis, rendering: rendering)
        }
    }
}

// MARK: Private

extension UITextView {
    private var textContainerView: UIView { subviews[1] }
    
    private var customEmojiViews: [EmojiView] {
        textContainerView.subviews.compactMap { $0 as? EmojiView }
    }
    
    func clearEmojis() {
        for (_, emojiView) in renderViews {
            emojiView.removeFromSuperview()
        }
        for view in textContainerView.subviews {
            if view is EmojiView {
                view.removeFromSuperview()
            }
        }
        renderViews = [:]
    }
    
    private func applyEmojis(_ emojis: [String: EmojiSource], rendering: EmojiRendering) {
        let range = selectedRange
        let count = attributedText?.string.count ?? 0
        attributedText = attributedText.insertingEmojis(emojis, rendering: rendering)
        let newCount = attributedText.string.count
        customEmojiViews.forEach { $0.removeFromSuperview() }
        addEmojiImagesIfNeeded(rendering: rendering)
        selectedRange = NSRange(location: range.location - (count - newCount), length: range.length)
    }
    
    private func addEmojiImagesIfNeeded(rendering: EmojiRendering) {
        attributedText.enumerateAttributes(
            in: NSRange(location: 0, length: attributedText.length),
            options: [],
            using: { attributes, crange, _ in
                DispatchQueue.main.async {
                    guard
                        let emojiAttachment = attributes[NSAttributedString.Key.attachment] as? NSTextAttachment,
                        let position1 = self.position(from: self.beginningOfDocument, offset: crange.location),
                        let position2 = self.position(from: position1, offset: crange.length),
                        let range = self.textRange(from: position1, to: position2),
                        let emojiData = emojiAttachment.contents,
                        let emoji = try? JSONDecoder().decode(EmojiSource.self, from: emojiData)
                    else {
                        return
                    }
                
                    let rect = self.firstRect(for: range)

                    let emojiView = EmojiView(frame: rect)
                    emojiView.backgroundColor = self.backgroundColor
                    emojiView.isUserInteractionEnabled = false
                
                    switch emoji {
                    case let .character(character):
                        emojiView.label.text = character
                    case let .imageUrl(imageUrl):
                        guard renderViews[emoji] == nil else {
                            break
                        }
                    
                        if let url = URL(string: imageUrl) {
                            let renderView = UIImageView(frame: rect)
                            renderView.setFromURL(url, rendering: rendering)
                            renderViews[emoji] = renderView
                            self.window?.addSubview(renderView)
                            renderView.alpha = 0
                        }
                    case let .imageAsset(imageAsset):
                        guard renderViews[emoji] == nil else {
                            break
                        }
                    
                        let renderView = UIImageView(frame: rect)
                        renderView.setFromAsset(imageAsset, rendering: rendering)
                        renderViews[emoji] = renderView
                        self.window?.addSubview(renderView)
                        renderView.alpha = 0
                    case .alias:
                        break
                    }
                
                    if let view = renderViews[emoji] {
                        emojiView.setFromRenderView(view)
                    }
                
                    self.textContainerView.addSubview(emojiView)
                }
            }
        )
    }
}
