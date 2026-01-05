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
            if let quotedMessage = message.quotedMessage {
                factory.makeQuotedMessageView(
                    quotedMessage: quotedMessage,
                    fillAvailableSpace: !message.attachmentCounts.isEmpty,
                    isInComposer: false,
                    scrolledId: $scrolledId
                )
            }

            factory.makeAttachmentTextView(options: .init(mesage: message))
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

    public var body: some View {
        ZStack {
            if let quotedMessage = message.quotedMessage {
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

// Options for the attachment text view.
public class AttachmentTextViewOptions {
    // The message to display the text for.
    public let message: ChatMessage
    
    public init(mesage: ChatMessage) {
        self.message = mesage
    }
}

@available(iOS 15, *)
public struct LinkDetectionTextView: View {
    @Environment(\.layoutDirection) var layoutDirection
    @Environment(\.channelTranslationLanguage) var translationLanguage
    @Environment(\.messageViewModel) var messageViewModel

    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    @Injected(\.utils) var utils
    
    var message: ChatMessage

    // The translations store is used to detect changes so the textContent is re-rendered.
    // The @Environment(\.messageViewModel) is not reactive like @EnvironmentObject.
    // TODO: On v5 the TextView should be refactored and not depend directly on the view model.
    @ObservedObject var originalTranslationsStore = InjectedValues[\.utils].originalTranslationsStore

    @State var text: AttributedString?
    @State var linkDetector = TextLinkDetector()
    @State var tintColor = InjectedValues[\.colors].tintColor
        
    public init(
        message: ChatMessage
    ) {
        self.message = message
    }
    
    public var body: some View {
        Group {
            Text(text ?? displayText)
        }
        .foregroundColor(textColor(for: message))
        .font(fonts.body)
        .tint(tintColor)
        .onChange(of: message) { message in
            messageViewModel?.message = message
            text = displayText
        }
    }
    
    var displayText: AttributedString {
        let text = messageViewModel?.textContent ?? message.text

        // Markdown
        let attributes = AttributeContainer()
            .foregroundColor(textColor(for: message))
            .font(fonts.body)
        var attributedString: AttributedString
        if utils.messageListConfig.markdownSupportEnabled {
            attributedString = utils.markdownFormatter.format(
                text,
                attributes: attributes,
                layoutDirection: layoutDirection
            )
        } else {
            attributedString = AttributedString(message.adjustedText, attributes: attributes)
        }
        // Links and mentions
        if utils.messageListConfig.localLinkDetectionEnabled {
            for user in message.mentionedUsers {
                let mention = "@\(user.name ?? user.id)"
                let ranges = attributedString.ranges(of: mention, options: [.caseInsensitive])
                for range in ranges {
                    if let messageId = message.messageId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
                       let url = URL(string: "getstream://mention/\(messageId)/\(user.id)") {
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
        var linkAttributes = utils.messageListConfig.messageDisplayOptions.messageLinkDisplayResolver(message)
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
