//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public struct AttachmentTextView<Factory: ViewFactory>: View {
    @Injected(\.tokens) private var tokens

    var factory: Factory
    var message: ChatMessage
    var availableWidth: CGFloat

    public init(
        factory: Factory = DefaultViewFactory.shared,
        message: ChatMessage,
        availableWidth: CGFloat
    ) {
        self.factory = factory
        self.message = message
        self.availableWidth = availableWidth
    }

    public var body: some View {
        factory.makeStreamTextView(options: .init(message: message))
            .padding(.horizontal, tokens.spacingXxs)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: maxTextWidth, alignment: .leading)
            .accessibilityIdentifier("MessageTextView")
    }

    /// Limit text width for messages with portrait image attachment.
    private var maxTextWidth: CGFloat {
        guard message.hasSingleMediaAttachmentWithCaption else { return availableWidth }
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
