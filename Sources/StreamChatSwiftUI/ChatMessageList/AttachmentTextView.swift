//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public struct AttachmentTextView<Factory: ViewFactory>: View {
    @Injected(\.tokens) private var tokens
    @Environment(\.messageCompositeAccessibilityLabel) private var captionAccessibilityLabel

    var factory: Factory
    var message: ChatMessage
    var availableWidth: CGFloat
    var translationLanguage: TranslationLanguage?

    public init(
        factory: Factory = DefaultViewFactory.shared,
        message: ChatMessage,
        availableWidth: CGFloat,
        translationLanguage: TranslationLanguage? = nil
    ) {
        self.factory = factory
        self.message = message
        self.availableWidth = availableWidth
        self.translationLanguage = translationLanguage
    }

    public var body: some View {
        factory.makeStreamTextView(options: .init(
            message: message,
            translationLanguage: translationLanguage
        ))
        .padding(.horizontal, tokens.spacingXxs)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: maxTextWidth, alignment: .leading)
        .accessibilityIdentifier("MessageTextView")
        .modifier(CaptionAccessibilityLabelModifier(label: captionAccessibilityLabel))
    }

    /// Limit text width for messages with portrait image attachment.
    private var maxTextWidth: CGFloat {
        guard message.hasSingleAttachment(of: [.image, .video], captioned: true) else { return availableWidth }
        let mediaAttachments = MediaAttachment.galleryOrdered(from: message)
        let orientation = MediaGalleryOrientation(mediaAttachments: mediaAttachments)
        let size = MessageMediaAttachmentsContainerView<Factory>.containerSize(
            for: mediaAttachments.count,
            orientation: orientation,
            maxItemWidth: availableWidth
        )
        return size.width
    }
}

/// Overrides the caption's VoiceOver label with the message's composite label
/// (sender, content, time and delivery status) when one is provided by the
/// surrounding message cell, so that focusing the caption of an attachment
/// message reads the same thing as a message without attachments.
private struct CaptionAccessibilityLabelModifier: ViewModifier {
    let label: String?

    @ViewBuilder
    func body(content: Content) -> some View {
        if let label, !label.isEmpty {
            content
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(label)
        } else {
            content
        }
    }
}
