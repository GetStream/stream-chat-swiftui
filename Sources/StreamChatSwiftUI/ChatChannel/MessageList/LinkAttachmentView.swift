//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Container for presenting link attachments.
/// In case of more than one link, only the first link is previewed.
public struct LinkAttachmentContainer<Factory: ViewFactory>: View {
    @Injected(\.colors) private var colors
    @Injected(\.utils) private var utils

    var factory: Factory
    var message: ChatMessage
    var width: CGFloat
    var isFirst: Bool
    @Binding var scrolledId: String?

    private let padding: CGFloat = 8
    
    public init(
        factory: Factory,
        message: ChatMessage,
        width: CGFloat,
        isFirst: Bool,
        scrolledId: Binding<String?>
    ) {
        self.factory = factory
        self.message = message
        self.width = width
        self.isFirst = isFirst
        _scrolledId = scrolledId
    }

    public var body: some View {
        VStack(
            alignment: message.alignmentInBubble,
            spacing: 0
        ) {
            if let quotedMessage = utils.messageCachingUtils.quotedMessage(for: message) {
                factory.makeQuotedMessageView(
                    quotedMessage: quotedMessage,
                    fillAvailableSpace: !message.attachmentCounts.isEmpty,
                    isInComposer: false,
                    scrolledId: $scrolledId
                )
            }

            let availableWidth = width - 4 * padding
            let size = message.adjustedText.frameSize(maxWidth: availableWidth)
            LinkTextView(
                message: message,
                width: availableWidth,
                textColor: UIColor(textColor(for: message))
            )
            .frame(width: availableWidth, height: size.height)
            .standardPadding()

            if !message.linkAttachments.isEmpty {
                LinkAttachmentView(
                    linkAttachment: message.linkAttachments[0],
                    width: width,
                    isFirst: isFirst
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
                                .foregroundColor(colors.tintColor)
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
                        .lineLimit(1)
                }

                if let description = linkAttachment.text {
                    Text(description)
                        .font(fonts.footnote)
                        .lineLimit(3)
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .padding(.horizontal, padding)
        .onTapGesture {
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
