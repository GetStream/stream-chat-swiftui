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
    public let formattedText: MessageFormattedText
    @Binding public var scrolledId: String?

    public init(
        factory: Factory,
        message: ChatMessage,
        formattedText: MessageFormattedText,
        contentWidth: CGFloat,
        isFirst: Bool,
        scrolledId: Binding<String?>
    ) {
        self.factory = factory
        self.message = message
        self.formattedText = formattedText
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
                        formattedText: formattedText,
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
                            formattedText: formattedText,
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
    private let formattedText: MessageFormattedText
    private let leadingPadding: CGFloat
    private let trailingPadding: CGFloat
    private let topPadding: CGFloat
    private let bottomPadding: CGFloat
    @Binding var scrolledId: String?

    public init(
        factory: Factory,
        message: ChatMessage,
        formattedText: MessageFormattedText,
        isFirst: Bool,
        scrolledId: Binding<String?>
    ) {
        @Injected(\.tokens) var tokens
        self.init(
            factory: factory,
            message: message,
            formattedText: formattedText,
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
        formattedText: MessageFormattedText,
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
        self.formattedText = formattedText
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
            factory.makeStreamTextView(options: .init(message: message, formattedText: formattedText))
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
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors

    let formattedText: MessageFormattedText
    let message: ChatMessage

    var body: some View {
        if #available(iOS 15.0, *), let attributedString = formattedText.attributedString {
            Text(attributedString)
                .font(fonts.body)
                .tint(Color(colors.accentPrimary))
        } else {
            Text(formattedText.string)
                .foregroundColor(textColor(for: message))
                .font(fonts.body)
        }
    }
}
