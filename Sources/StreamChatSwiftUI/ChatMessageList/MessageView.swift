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
    @ObservedObject public var messageViewModel: MessageViewModel
    public var contentWidth: CGFloat
    public var isFirst: Bool
    @Binding public var scrolledId: String?

    public init(
        factory: Factory,
        messageViewModel: MessageViewModel,
        contentWidth: CGFloat,
        isFirst: Bool,
        scrolledId: Binding<String?>
    ) {
        self.factory = factory
        self.messageViewModel = messageViewModel
        self.contentWidth = contentWidth
        self.isFirst = isFirst
        _scrolledId = scrolledId
    }

    public var body: some View {
        VStack(alignment: messageViewModel.message.isRightAligned ? .trailing : .leading) {
            if messageTypeResolver.isDeleted(message: messageViewModel.message) {
                factory.makeDeletedMessageView(
                    options: DeletedMessageViewOptions(
                        message: messageViewModel.message,
                        isFirst: isFirst,
                        availableWidth: contentWidth
                    )
                )
            } else if messageTypeResolver.hasCustomAttachment(message: messageViewModel.message) {
                factory.makeCustomAttachmentViewType(
                    options: CustomAttachmentViewTypeOptions(
                        message: messageViewModel.message,
                        isFirst: isFirst,
                        availableWidth: contentWidth,
                        scrolledId: $scrolledId
                    )
                )
            } else if let poll = messageViewModel.message.poll {
                factory.makePollView(
                    options: PollViewOptions(
                        message: messageViewModel.message,
                        poll: poll,
                        isFirst: isFirst,
                        availableWidth: contentWidth
                    )
                )
            } else if messageTypeResolver.hasGiphyAttachment(message: messageViewModel.message) {
                factory.makeGiphyAttachmentView(
                    options: GiphyAttachmentViewOptions(
                        message: messageViewModel.message,
                        isFirst: isFirst,
                        availableWidth: contentWidth,
                        scrolledId: $scrolledId
                    )
                )
            } else if !messageViewModel.message.attachmentCounts.isEmpty || messageViewModel.message.quotedMessage != nil {
                factory.makeMessageAttachmentsView(
                    options: MessageAttachmentsViewOptions(
                        messageViewModel: messageViewModel,
                        isFirst: isFirst,
                        availableWidth: contentWidth,
                        scrolledId: $scrolledId
                    )
                )
            } else {
                if messageViewModel.message.shouldRenderAsJumbomoji {
                    factory.makeEmojiTextView(
                        options: EmojiTextViewOptions(
                            message: messageViewModel.message,
                            scrolledId: $scrolledId,
                            isFirst: isFirst
                        )
                    )
                } else if !messageViewModel.message.text.isEmpty {
                    factory.makeMessageTextView(
                        options: MessageTextViewOptions(
                            messageViewModel: messageViewModel,
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
    @Environment(\.layoutDirection) private var layoutDirection
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.utils) private var utils

    private let factory: Factory
    @ObservedObject private var messageViewModel: MessageViewModel
    private let isFirst: Bool
    private let leadingPadding: CGFloat
    private let trailingPadding: CGFloat
    private let topPadding: CGFloat
    private let bottomPadding: CGFloat
    @Binding var scrolledId: String?

    public init(
        factory: Factory,
        messageViewModel: MessageViewModel,
        isFirst: Bool,
        scrolledId: Binding<String?>
    ) {
        @Injected(\.tokens) var tokens
        self.init(
            factory: factory,
            messageViewModel: messageViewModel,
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
        messageViewModel: MessageViewModel,
        isFirst: Bool,
        leadingPadding: CGFloat,
        trailingPadding: CGFloat,
        topPadding: CGFloat,
        bottomPadding: CGFloat,
        scrolledId: Binding<String?>
    ) {
        self.factory = factory
        self.messageViewModel = messageViewModel
        self.isFirst = isFirst
        self.leadingPadding = leadingPadding
        self.trailingPadding = trailingPadding
        self.topPadding = topPadding
        self.bottomPadding = bottomPadding
        _scrolledId = scrolledId
    }

    public var body: some View {
        VStack(
            alignment: messageViewModel.message.alignmentInBubble,
            spacing: 0
        ) {
            messageText
                .font(fonts.body)
                .foregroundColor(textColor(for: messageViewModel.message))
                .accentColor(Color(colors.accentPrimary))
                .padding(.leading, leadingPadding)
                .padding(.trailing, trailingPadding)
                .padding(.top, topPadding)
                .padding(.bottom, bottomPadding)
                .fixedSize(horizontal: false, vertical: true)
        }
        .modifier(
            factory.styles.makeMessageViewModifier(
                for: MessageModifierInfo(
                    message: messageViewModel.message,
                    isFirst: isFirst
                )
            )
        )
        .accessibilityIdentifier("MessageTextView")
    }

    private var messageText: Text {
        if #available(iOS 15.0, *) {
            return Text(messageViewModel.attributedString(layoutDirection: layoutDirection))
        } else {
            return Text(messageViewModel.textContent)
        }
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
