//
// Copyright © 2024 Stream.io Inc. All rights reserved.
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
    @Binding public var scrolledId: String?

    public init(factory: Factory, message: ChatMessage, contentWidth: CGFloat, isFirst: Bool, scrolledId: Binding<String?>) {
        self.factory = factory
        self.message = message
        self.contentWidth = contentWidth
        self.isFirst = isFirst
        _scrolledId = scrolledId
    }

    public var body: some View {
        VStack {
            if messageTypeResolver.isDeleted(message: message) {
                factory.makeDeletedMessageView(
                    for: message,
                    isFirst: isFirst,
                    availableWidth: contentWidth
                )
            } else if messageTypeResolver.hasCustomAttachment(message: message) {
                factory.makeCustomAttachmentViewType(
                    for: message,
                    isFirst: isFirst,
                    availableWidth: contentWidth,
                    scrolledId: $scrolledId
                )
            } else if !message.attachmentCounts.isEmpty {
                if messageTypeResolver.hasLinkAttachment(message: message) {
                    factory.makeLinkAttachmentView(
                        for: message,
                        isFirst: isFirst,
                        availableWidth: contentWidth,
                        scrolledId: $scrolledId
                    )
                }

                if messageTypeResolver.hasFileAttachment(message: message) {
                    factory.makeFileAttachmentView(
                        for: message,
                        isFirst: isFirst,
                        availableWidth: contentWidth,
                        scrolledId: $scrolledId
                    )
                }

                if messageTypeResolver.hasImageAttachment(message: message) {
                    factory.makeImageAttachmentView(
                        for: message,
                        isFirst: isFirst,
                        availableWidth: contentWidth,
                        scrolledId: $scrolledId
                    )
                }

                if messageTypeResolver.hasGiphyAttachment(message: message) {
                    factory.makeGiphyAttachmentView(
                        for: message,
                        isFirst: isFirst,
                        availableWidth: contentWidth,
                        scrolledId: $scrolledId
                    )
                }

                if messageTypeResolver.hasVideoAttachment(message: message) {
                    factory.makeVideoAttachmentView(
                        for: message,
                        isFirst: isFirst,
                        availableWidth: contentWidth,
                        scrolledId: $scrolledId
                    )
                }
                
                if messageTypeResolver.hasVoiceRecording(message: message) {
                    factory.makeVoiceRecordingView(
                        for: message,
                        isFirst: isFirst,
                        availableWidth: contentWidth,
                        scrolledId: $scrolledId
                    )
                }
            } else {
                if message.shouldRenderAsJumbomoji {
                    factory.makeEmojiTextView(
                        message: message,
                        scrolledId: $scrolledId,
                        isFirst: isFirst
                    )
                } else if !message.text.isEmpty {
                    factory.makeMessageTextView(
                        for: message,
                        isFirst: isFirst,
                        availableWidth: contentWidth,
                        scrolledId: $scrolledId
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
    private let leadingPadding: CGFloat
    private let trailingPadding: CGFloat
    private let topPadding: CGFloat
    private let bottomPadding: CGFloat
    @Binding var scrolledId: String?

    public init(
        factory: Factory,
        message: ChatMessage,
        isFirst: Bool,
        leadingPadding: CGFloat = 16,
        trailingPadding: CGFloat = 16,
        topPadding: CGFloat = 8,
        bottomPadding: CGFloat = 8,
        scrolledId: Binding<String?>
    ) {
        self.factory = factory
        self.message = message
        self.isFirst = isFirst
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
            if let quotedMessage = utils.messageCachingUtils.quotedMessage(for: message) {
                factory.makeQuotedMessageView(
                    quotedMessage: quotedMessage,
                    fillAvailableSpace: !message.attachmentCounts.isEmpty,
                    isInComposer: false,
                    scrolledId: $scrolledId
                )
            }

            StreamTextView(message: message)
                .padding(.leading, leadingPadding)
                .padding(.trailing, trailingPadding)
                .padding(.top, topPadding)
                .padding(.bottom, bottomPadding)
                .fixedSize(horizontal: false, vertical: true)
        }
        .modifier(
            factory.makeMessageViewModifier(
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
    @Injected(\.utils) private var utils

    public var body: some View {
        ZStack {
            if let quotedMessage = utils.messageCachingUtils.quotedMessage(for: message) {
                VStack(spacing: 0) {
                    factory.makeQuotedMessageView(
                        quotedMessage: quotedMessage,
                        fillAvailableSpace: !message.attachmentCounts.isEmpty,
                        isInComposer: false,
                        scrolledId: $scrolledId
                    )

                    Text(message.adjustedText)
                        .font(fonts.emoji)
                }
                .modifier(
                    factory.makeMessageViewModifier(
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
    
    @Injected(\.utils) var utils
    @Injected(\.fonts) var fonts
    
    var message: ChatMessage
    
    var body: some View {
        if #available(iOS 15, *), utils.messageListConfig.localLinkDetectionEnabled {
            LinkDetectionTextView(message: message)
        } else {
            Text(message.adjustedText)
                .foregroundColor(textColor(for: message))
                .font(fonts.body)
        }
    }
}

@available(iOS 15, *)
struct LinkDetectionTextView: View {
    
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    
    var message: ChatMessage
    
    var text: String {
        message.adjustedText
    }
    
    @State var displayedText: AttributedString
    
    @State var linkDetector = TextLinkDetector()
    
    init(message: ChatMessage) {
        self.message = message
        _displayedText = State(initialValue: AttributedString(message.adjustedText))
    }
    
    var body: some View {
        Text(displayedText)
            .foregroundColor(textColor(for: message))
            .font(fonts.body)
            .onAppear {
                let attributedText = NSMutableAttributedString(
                    string: text,
                    attributes: [
                        .foregroundColor: textColor(for: message),
                        .font: fonts.body
                    ]
                )

                linkDetector.links(in: text).forEach { textLink in
                    attributedText.addAttribute(.link, value: textLink.url, range: textLink.range)
                }
                
                self.displayedText = AttributedString(attributedText)
            }
    }
}
