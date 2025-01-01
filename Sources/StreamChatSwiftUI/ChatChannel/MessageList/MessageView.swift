//
// Copyright © 2025 Stream.io Inc. All rights reserved.
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
            } else if let poll = message.poll {
                factory.makePollView(message: message, poll: poll, isFirst: isFirst)
            } else if !message.attachmentCounts.isEmpty {
                let hasOnlyLinks = { message.attachmentCounts.keys.allSatisfy { $0 == .linkPreview } }
                if messageTypeResolver.hasLinkAttachment(message: message) && hasOnlyLinks() {
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

                if messageTypeResolver.hasVideoAttachment(message: message)
                    && !messageTypeResolver.hasImageAttachment(message: message) {
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
    
    @Injected(\.fonts) var fonts
    
    let message: ChatMessage
    private let adjustedText: String
    
    init(message: ChatMessage) {
        self.message = message
        adjustedText = message.adjustedText
    }
    
    var body: some View {
        if #available(iOS 15, *) {
            LinkDetectionTextView(message: message)
        } else {
            Text(adjustedText)
                .foregroundColor(textColor(for: message))
                .font(fonts.body)
        }
    }
}

@available(iOS 15, *)
public struct LinkDetectionTextView: View {
    
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    @Injected(\.utils) var utils
    
    var message: ChatMessage
    
    var text: LocalizedStringKey {
        LocalizedStringKey(message.adjustedText)
    }
    
    @State var displayedText: AttributedString?
    
    @State var linkDetector = TextLinkDetector()
    
    @State var tintColor = InjectedValues[\.colors].tintColor
        
    public init(message: ChatMessage) {
        self.message = message
    }
    
    private var markdownEnabled: Bool {
        utils.messageListConfig.markdownSupportEnabled
    }
    
    public var body: some View {
        Group {
            if let displayedText {
                Text(displayedText)
            } else if markdownEnabled {
                Text(text)
            } else {
                Text(message.adjustedText)
            }
        }
        .foregroundColor(textColor(for: message))
        .font(fonts.body)
        .tint(tintColor)
        .onAppear {
            detectLinks(for: message)
        }
        .onChange(of: message, perform: { updated in
            detectLinks(for: updated)
        })
    }
    
    func detectLinks(for message: ChatMessage) {
        guard utils.messageListConfig.localLinkDetectionEnabled else { return }
        var attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: textColor(for: message),
            .font: fonts.body
        ]
        
        let additional = utils.messageListConfig.messageDisplayOptions.messageLinkDisplayResolver(message)
        for (key, value) in additional {
            if key == .foregroundColor, let value = value as? UIColor {
                tintColor = Color(value)
            } else {
                attributes[key] = value
            }
        }
        
        let attributedText = NSMutableAttributedString(
            string: message.adjustedText,
            attributes: attributes
        )
        let attributedTextString = attributedText.string
        var containsLinks = false

        message.mentionedUsers.forEach { user in
            containsLinks = true
            let mention = "@\(user.name ?? user.id)"
            attributedTextString
                .ranges(of: mention, options: [.caseInsensitive])
                .map { NSRange($0, in: attributedTextString) }
                .forEach {
                    let messageId = message.messageId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
                    if let messageId {
                        attributedText.addAttribute(.link, value: "getstream://mention/\(messageId)/\(user.id)", range: $0)
                    }
                }
        }

        let range = NSRange(location: 0, length: message.adjustedText.utf16.count)
        linkDetector.links(in: message.adjustedText).forEach { textLink in
            let escapedOriginalText = NSRegularExpression.escapedPattern(for: textLink.originalText)
            let pattern = "\\[([^\\]]+)\\]\\(\(escapedOriginalText)\\)"
            if let regex = try? NSRegularExpression(pattern: pattern) {
                containsLinks = (regex.firstMatch(
                    in: message.adjustedText,
                    options: [],
                    range: range
                ) == nil) || !markdownEnabled
            } else {
                containsLinks = true
            }
            
            if !message.adjustedText.contains("](\(textLink.originalText))") {
                containsLinks = true
            }
            attributedText.addAttribute(.link, value: textLink.url, range: textLink.range)
        }
            
        if containsLinks {
            displayedText = AttributedString(attributedText)
        }
    }
}
