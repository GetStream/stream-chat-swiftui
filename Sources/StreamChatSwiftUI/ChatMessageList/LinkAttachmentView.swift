//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Container for presenting link attachments.
/// In case of more than one link, only the first link is previewed.
public struct LinkAttachmentContainer<Factory: ViewFactory>: View {
    @Injected(\.colors) private var colors

    var factory: Factory
    var message: ChatMessage
    var width: CGFloat
    var isFirst: Bool
    var onImageTap: ((ChatMessageLinkAttachment) -> Void)?
    @Binding var scrolledId: String?

    private let padding: CGFloat = 8
    
    public init(
        factory: Factory,
        message: ChatMessage,
        width: CGFloat,
        isFirst: Bool,
        scrolledId: Binding<String?>,
        onImageTap: ((ChatMessageLinkAttachment) -> Void)? = nil
    ) {
        self.factory = factory
        self.message = message
        self.width = width
        self.isFirst = isFirst
        self.onImageTap = onImageTap
        _scrolledId = scrolledId
    }

    public var body: some View {
        if !message.linkAttachments.isEmpty {
            LinkAttachmentView(
                linkAttachment: message.linkAttachments[0],
                width: width,
                isFirst: isFirst,
                isRightAligned: message.isRightAligned,
                onImageTap: onImageTap
            )
            .background(MessageAttachmentsBubbleConfiguration.attachmentBackgroundColor(for: message))
            .roundWithBorder()
            .accessibilityIdentifier("LinkAttachmentContainer")
        }
    }
}

/// View for previewing link attachments.
public struct LinkAttachmentView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens

    var linkAttachment: ChatMessageLinkAttachment
    var width: CGFloat
    var isFirst: Bool
    let isRightAligned: Bool
    var onImageTap: ((ChatMessageLinkAttachment) -> Void)?

    public init(
        linkAttachment: ChatMessageLinkAttachment,
        width: CGFloat,
        isFirst: Bool,
        isRightAligned: Bool,
        onImageTap: ((ChatMessageLinkAttachment) -> Void)? = nil
    ) {
        self.linkAttachment = linkAttachment
        self.width = width
        self.isFirst = isFirst
        self.isRightAligned = isRightAligned
        self.onImageTap = onImageTap
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !imageHidden {
                ZStack {
                    LazyImage(imageURL: linkAttachment.previewURL ?? linkAttachment.originalURL) { state in
                        if let image = state.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        }
                    }
                    .onDisappear(.cancel)
                    .processors([ImageProcessors.Resize(width: width)])
                    .priority(.high)
                    .frame(height: width / 2)
                    .clipped()

                    if !authorHidden {
                        BottomLeftView {
                            Text(linkAttachment.author ?? "")
                                .foregroundColor(Color(colors.textPrimary))
                                .font(fonts.bodyBold)
                                .standardPadding()
                                .bubble(
                                    with: Color(colors.backgroundCoreElevation1),
                                    corners: [.topRight],
                                    borderColor: .clear
                                )
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: tokens.spacingXxs) {
                if let title = linkAttachment.title {
                    Text(title)
                        .font(fonts.footnoteBold)
                        .foregroundColor(Color(isRightAligned ? colors.chatTextOutgoing : colors.chatTextIncoming))
                        .lineLimit(1)
                }

                if let description = linkAttachment.text {
                    Text(description)
                        .font(fonts.footnote)
                        .foregroundColor(Color(isRightAligned ? colors.chatTextOutgoing : colors.chatTextIncoming))
                        .lineLimit(3)
                }
            }
            .padding(tokens.spacingSm)
        }
        .onTapGesture {
            if let onImageTap {
                onImageTap(linkAttachment)
                return
            }
            if let url = linkAttachment.originalURL.secureURL, UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:])
            }
        }
        .accessibilityIdentifier("LinkAttachmentView")
    }

    private var imageHidden: Bool {
        linkAttachment.previewURL == nil
    }

    private var authorHidden: Bool {
        linkAttachment.author == nil
    }
}
