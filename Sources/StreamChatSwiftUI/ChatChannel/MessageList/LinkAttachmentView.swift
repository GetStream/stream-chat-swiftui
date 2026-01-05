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
        VStack(
            alignment: message.alignmentInBubble,
            spacing: 0
        ) {
            if let quotedMessage = message.quotedMessage {
                factory.makeQuotedMessageView(
                    quotedMessage: quotedMessage,
                    fillAvailableSpace: !message.attachmentCounts.isEmpty,
                    isInComposer: false,
                    scrolledId: $scrolledId
                )
            }

            if #available(iOS 15, *) {
                HStack {
                    factory.makeAttachmentTextView(options: .init(mesage: message))
                        .standardPadding()
                    Spacer()
                }
                .layoutPriority(1)
            } else {
                let availableWidth = width - 4 * padding
                let size = message.adjustedText.frameSize(maxWidth: availableWidth)
                LinkTextView(
                    message: message,
                    width: availableWidth,
                    textColor: UIColor(textColor(for: message))
                )
                .frame(width: availableWidth, height: size.height)
                .standardPadding()
            }

            if !message.linkAttachments.isEmpty {
                LinkAttachmentView(
                    linkAttachment: message.linkAttachments[0],
                    width: width,
                    isFirst: isFirst,
                    onImageTap: onImageTap
                )
            }
        }
        .padding(.bottom, 8)
        .modifier(
            factory.makeMessageViewModifier(
                for: MessageModifierInfo(
                    message: message,
                    isFirst: isFirst,
                    injectedBackgroundColor: colors.highlightedAccentBackground1
                )
            )
        )
        .accessibilityIdentifier("LinkAttachmentContainer")
    }
}

/// View for previewing link attachments.
public struct LinkAttachmentView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts

    private let padding: CGFloat = 8

    var linkAttachment: ChatMessageLinkAttachment
    var width: CGFloat
    var isFirst: Bool
    var onImageTap: ((ChatMessageLinkAttachment) -> Void)?

    public init(
        linkAttachment: ChatMessageLinkAttachment,
        width: CGFloat,
        isFirst: Bool,
        onImageTap: ((ChatMessageLinkAttachment) -> Void)? = nil
    ) {
        self.linkAttachment = linkAttachment
        self.width = width
        self.isFirst = isFirst
        self.onImageTap = onImageTap
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: padding) {
            if !imageHidden {
                ZStack {
                    LazyImage(imageURL: linkAttachment.previewURL ?? linkAttachment.originalURL)
                        .onDisappear(.cancel)
                        .processors([ImageProcessors.Resize(width: width)])
                        .priority(.high)
                        .frame(width: width - 2 * padding, height: (width - 2 * padding) / 2)
                        .cornerRadius(14)

                    if !authorHidden {
                        BottomLeftView {
                            Text(linkAttachment.author ?? "")
                                .foregroundColor(colors.messageLinkAttachmentAuthorColor)
                                .font(fonts.bodyBold)
                                .standardPadding()
                                .bubble(
                                    with: Color(colors.highlightedAccentBackground1),
                                    corners: [.topRight],
                                    borderColor: .clear
                                )
                        }
                    }
                }
            }

            VStack(alignment: .leading) {
                if let title = linkAttachment.title {
                    Text(title)
                        .font(fonts.footnoteBold)
                        .foregroundColor(colors.messageLinkAttachmentTitleColor)
                        .lineLimit(1)
                }

                if let description = linkAttachment.text {
                    Text(description)
                        .font(fonts.footnote)
                        .foregroundColor(colors.messageLinkAttachmentTextColor)
                        .lineLimit(3)
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .padding(.horizontal, padding)
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
