//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public struct MessageView<Factory: ViewFactory>: View {
    @Injected(\.utils) private var utils

    private var messageTypeResolver: MessageTypeResolving {
        utils.messageTypeResolver
    }

    public var factory: Factory
    public var message: ChatMessage
    public var contentWidth: CGFloat
    public var isFirst: Bool
    public let text: String
    @Binding public var scrolledId: String?

    public init(
        factory: Factory,
        message: ChatMessage,
        text: String,
        contentWidth: CGFloat,
        isFirst: Bool,
        scrolledId: Binding<String?>
    ) {
        self.factory = factory
        self.message = message
        self.text = text
        self.contentWidth = contentWidth
        self.isFirst = isFirst
        _scrolledId = scrolledId
    }

    public var body: some View {
        VStack(alignment: message.isRightAligned ? .trailing : .leading) {
            if messageTypeResolver.isDeleted(message: message) {
                factory.makeDeletedMessageView(
                    options: DeletedMessageViewOptions(
                        message: message,
                        isFirst: isFirst,
                        availableWidth: contentWidth
                    )
                )
            } else if messageTypeResolver.hasCustomAttachment(message: message) {
                factory.makeCustomAttachmentViewType(
                    options: CustomAttachmentViewTypeOptions(
                        message: message,
                        isFirst: isFirst,
                        availableWidth: contentWidth,
                        scrolledId: $scrolledId
                    )
                )
            } else if let poll = message.poll {
                factory.makePollView(
                    options: PollViewOptions(
                        message: message,
                        poll: poll,
                        isFirst: isFirst,
                        availableWidth: contentWidth
                    )
                )
            } else if messageTypeResolver.hasGiphyAttachment(message: message) {
                factory.makeGiphyAttachmentView(
                    options: GiphyAttachmentViewOptions(
                        message: message,
                        isFirst: isFirst,
                        availableWidth: contentWidth,
                        scrolledId: $scrolledId
                    )
                )
            } else if !message.attachmentCounts.isEmpty || message.quotedMessage != nil {
                factory.makeMessageAttachmentsView(
                    options: MessageAttachmentsViewOptions(
                        message: message,
                        text: text,
                        isFirst: isFirst,
                        availableWidth: contentWidth,
                        scrolledId: $scrolledId
                    )
                )
            } else {
                if message.shouldRenderAsJumbomoji {
                    factory.makeEmojiTextView(
                        options: EmojiTextViewOptions(
                            message: message,
                            scrolledId: $scrolledId,
                            isFirst: isFirst
                        )
                    )
                } else if !message.text.isEmpty {
                    factory.makeMessageTextView(
                        options: MessageTextViewOptions(
                            message: message,
                            text: text,
                            isFirst: isFirst,
                            availableWidth: contentWidth,
                            scrolledId: $scrolledId
                        )
                    )
                }
            }
        }
    }
}

public struct MessageTextView<Factory: ViewFactory>: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.utils) private var utils

    private let factory: Factory
    private let message: ChatMessage
    private let isFirst: Bool
    private let text: String
    private let leadingPadding: CGFloat
    private let trailingPadding: CGFloat
    private let topPadding: CGFloat
    private let bottomPadding: CGFloat
    @Binding var scrolledId: String?

    public init(
        factory: Factory,
        message: ChatMessage,
        text: String,
        isFirst: Bool,
        scrolledId: Binding<String?>
    ) {
        @Injected(\.tokens) var tokens
        self.init(
            factory: factory,
            message: message,
            text: text,
            isFirst: isFirst,
            leadingPadding: tokens.spacingSm,
            trailingPadding: tokens.spacingSm,
            topPadding: tokens.spacingXs,
            bottomPadding: tokens.spacingXs,
            scrolledId: scrolledId
        )
    }

    public init(
        factory: Factory,
        message: ChatMessage,
        text: String,
        isFirst: Bool,
        leadingPadding: CGFloat,
        trailingPadding: CGFloat,
        topPadding: CGFloat,
        bottomPadding: CGFloat,
        scrolledId: Binding<String?>
    ) {
        self.factory = factory
        self.message = message
        self.isFirst = isFirst
        self.text = text
        self.leadingPadding = leadingPadding
        self.trailingPadding = trailingPadding
        self.topPadding = topPadding
        self.bottomPadding = bottomPadding
        _scrolledId = scrolledId
    }

    public var body: some View {
        VStack(
            alignment: message.alignmentInBubble,
            spacing: 0
        ) {
            factory.makeStreamTextView(options: .init(message: message, text: text))
                .padding(.leading, leadingPadding)
                .padding(.trailing, trailingPadding)
                .padding(.top, topPadding)
                .padding(.bottom, bottomPadding)
                .fixedSize(horizontal: false, vertical: true)
        }
        .modifier(
            factory.styles.makeMessageViewModifier(
                for: MessageModifierInfo(
                    message: message,
                    isFirst: isFirst
                )
            )
        )
        .accessibilityIdentifier("MessageTextView")
    }
}

public struct EmojiTextView<Factory: ViewFactory>: View {
    var factory: Factory
    var message: ChatMessage
    @Binding var scrolledId: String?
    var isFirst: Bool

    @Injected(\.fonts) private var fonts

    public var body: some View {
        ZStack {
            if let quotedMessage = message.quotedMessage {
                VStack(spacing: 0) {
                    factory.makeChatQuotedMessageView(
                        options: ChatQuotedMessageViewOptions(
                            quotedMessage: quotedMessage,
                            parentMessage: message,
                            scrolledId: $scrolledId
                        )
                    )

                    Text(message.adjustedText)
                        .font(fonts.emoji)
                }
                .modifier(
                    factory.styles.makeMessageViewModifier(
                        for: MessageModifierInfo(
                            message: message,
                            isFirst: isFirst
                        )
                    )
                )
            } else {
                Text(message.adjustedText)
                    .font(fonts.emoji)
            }
        }
        .accessibilityIdentifier("MessageTextView")
    }
}

struct StreamTextView: View {
    @Injected(\.fonts) var fonts
    @Injected(\.utils) var utils

    let text: String
    let message: ChatMessage

    var body: some View {
        if #available(iOS 15, *) {
            LinkDetectionTextView(
                text: text,
                textColor: textColor(for: message),
                mentionedUsers: message.mentionedUsers,
                messageId: message.messageId,
                linkAttributes: utils.messageListConfig.messageDisplayOptions.messageLinkDisplayResolver(message)
            )
        } else {
            Text(text)
                .foregroundColor(textColor(for: message))
                .font(fonts.body)
        }
    }
}

@available(iOS 15, *)
public struct LinkDetectionTextView: View {
    @Environment(\.layoutDirection) var layoutDirection

    @Injected(\.fonts) var fonts
    @Injected(\.utils) var utils

    var text: String
    var textColor: Color
    var mentionedUsers: Set<ChatUser>
    var messageId: String
    var linkAttributes: [NSAttributedString.Key: Any]

    @State var linkDetector = TextLinkDetector()
    @State var tintColor = Color(InjectedValues[\.colors].accentPrimary)

    public init(
        text: String,
        textColor: Color,
        mentionedUsers: Set<ChatUser>,
        messageId: String,
        linkAttributes: [NSAttributedString.Key: Any] = [:]
    ) {
        self.text = text
        self.textColor = textColor
        self.mentionedUsers = mentionedUsers
        self.messageId = messageId
        self.linkAttributes = linkAttributes
    }

    public var body: some View {
        Text(displayText)
            .foregroundColor(textColor)
            .font(fonts.body)
            .tint(tintColor)
    }

    var displayText: AttributedString {
        // Markdown
        let attributes = AttributeContainer()
            .foregroundColor(textColor)
            .font(fonts.body)
        var attributedString: AttributedString
        if utils.messageListConfig.markdownSupportEnabled {
            attributedString = utils.markdownFormatter.format(
                text,
                attributes: attributes,
                layoutDirection: layoutDirection
            )
        } else {
            attributedString = AttributedString(text, attributes: attributes)
        }
        // Links and mentions
        if utils.messageListConfig.localLinkDetectionEnabled {
            for user in mentionedUsers {
                let mention = "@\(user.name ?? user.id)"
                let ranges = attributedString.ranges(of: mention, options: [.caseInsensitive])
                for range in ranges {
                    if let encodedId = messageId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
                       let url = URL(string: "getstream://mention/\(encodedId)/\(user.id)") {
                        attributedString[range].link = url
                    }
                }
            }
            for link in linkDetector.links(in: String(attributedString.characters)) {
                if let attributedStringRange = Range(link.range, in: attributedString) {
                    attributedString[attributedStringRange].link = link.url
                }
            }
        }
        // Finally change attributes for links (markdown links, text links, mentions)
        var linkAttributes = linkAttributes
        if !linkAttributes.isEmpty {
            var linkAttributeContainer = AttributeContainer()
            if let uiColor = linkAttributes[.foregroundColor] as? UIColor {
                linkAttributeContainer = linkAttributeContainer.foregroundColor(Color(uiColor: uiColor))
                linkAttributes.removeValue(forKey: .foregroundColor)
            }
            linkAttributeContainer.merge(AttributeContainer(linkAttributes))
            for (value, range) in attributedString.runs[\.link] {
                guard value != nil else { continue }
                attributedString[range].mergeAttributes(linkAttributeContainer)
            }
        }

        return attributedString
    }
}
