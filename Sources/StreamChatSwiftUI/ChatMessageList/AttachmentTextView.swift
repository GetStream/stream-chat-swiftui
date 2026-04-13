//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public struct AttachmentTextView<Factory: ViewFactory>: View {
    @Environment(\.layoutDirection) private var layoutDirection
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens

    var factory: Factory
    @ObservedObject var messageViewModel: MessageViewModel
    var availableWidth: CGFloat

    public init(
        factory: Factory = DefaultViewFactory.shared,
        messageViewModel: MessageViewModel,
        availableWidth: CGFloat
    ) {
        self.factory = factory
        self.messageViewModel = messageViewModel
        self.availableWidth = availableWidth
    }

    public var body: some View {
        messageText
            .font(fonts.body)
            .foregroundColor(textColor(for: messageViewModel.message))
            .accentColor(Color(colors.accentPrimary))
            .padding(.horizontal, tokens.spacingXxs)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: maxTextWidth, alignment: .leading)
            .accessibilityIdentifier("MessageTextView")
    }

    private var messageText: Text {
        if #available(iOS 15.0, *) {
            return Text(messageViewModel.attributedString(layoutDirection: layoutDirection))
        } else {
            return Text(messageViewModel.textContent)
        }
    }

    /// Limit text width for messages with portrait image attachment.
    private var maxTextWidth: CGFloat {
        let message = messageViewModel.message
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
