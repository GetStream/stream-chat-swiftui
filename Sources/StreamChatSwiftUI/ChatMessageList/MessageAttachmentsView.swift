//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public struct MessageAttachmentsView<Factory: ViewFactory>: View {
    @Injected(\.tokens) private var tokens
    @Injected(\.utils) private var utils

    private var messageTypeResolver: MessageTypeResolving {
        utils.messageTypeResolver
    }

    let factory: Factory
    let message: ChatMessage
    let width: CGFloat
    let isFirst: Bool
    let translationLanguage: TranslationLanguage?
    private let messageModifierInfo: MessageModifierInfo?
    private let bubbleInsets: EdgeInsets
    @Binding var scrolledId: String?

    public init(
        factory: Factory,
        message: ChatMessage,
        width: CGFloat,
        isFirst: Bool,
        scrolledId: Binding<String?>,
        translationLanguage: TranslationLanguage? = nil
    ) {
        self.init(
            factory: factory,
            message: message,
            width: width,
            isFirst: isFirst,
            scrolledId: scrolledId,
            translationLanguage: translationLanguage,
            messageModifierInfo: MessageAttachmentsBubbleConfiguration.messageModifierInfo(
                for: message,
                isFirst: isFirst
            ),
            bubbleInsets: MessageAttachmentsBubbleConfiguration.bubbleInsets(for: message)
        )
    }

    /// Creates a message attachments view with configurable outer bubble styling.
    ///
    /// - Parameters:
    ///   - factory: The view factory used to build attachment subviews.
    ///   - message: The message containing attachments or quoted content.
    ///   - width: The available width for the attachments.
    ///   - isFirst: Whether this message is the first message in a message group.
    ///   - scrolledId: Binding to the currently scrolled message id.
    ///   - translationLanguage: The translation language to apply, or `nil` to show the original text.
    ///   - messageModifierInfo: Information used to apply the outer attachment bubble. Pass `nil` to hide the outer bubble.
    ///   - bubbleInsets: Insets applied inside the outer attachment bubble. This does not affect message-list row spacing or inner attachment container padding.
    public init(
        factory: Factory,
        message: ChatMessage,
        width: CGFloat,
        isFirst: Bool,
        scrolledId: Binding<String?>,
        translationLanguage: TranslationLanguage? = nil,
        messageModifierInfo: MessageModifierInfo?,
        bubbleInsets: EdgeInsets
    ) {
        self.factory = factory
        self.message = message
        self.width = width
        self.isFirst = isFirst
        self.translationLanguage = translationLanguage
        self.messageModifierInfo = messageModifierInfo
        self.bubbleInsets = bubbleInsets
        self._scrolledId = scrolledId
    }

    public var body: some View {
        VStack(alignment: message.alignmentInBubble, spacing: tokens.spacingXs) {
            VStack(alignment: message.isRightAligned ? .trailing : .leading, spacing: tokens.spacingXs) {
                if let quotedMessage = message.quotedMessage {
                    factory.makeChatQuotedMessageView(
                        options: ChatQuotedMessageViewOptions(
                            quotedMessage: quotedMessage,
                            parentMessage: message,
                            availableWidth: width,
                            scrolledId: $scrolledId
                        )
                    )
                }
                
                // Images or images and videos
                if messageTypeResolver.hasImageAttachment(message: message) {
                    factory.makeImageAttachmentView(
                        options: ImageAttachmentViewOptions(
                            message: message,
                            isFirst: isFirst,
                            availableWidth: width,
                            scrolledId: $scrolledId
                        )
                    )
                }

                // Only videos
                if messageTypeResolver.hasVideoAttachment(message: message)
                    && !messageTypeResolver.hasImageAttachment(message: message) {
                    factory.makeVideoAttachmentView(
                        options: VideoAttachmentViewOptions(
                            message: message,
                            isFirst: isFirst,
                            availableWidth: width,
                            scrolledId: $scrolledId
                        )
                    )
                }
                
                // Files
                if messageTypeResolver.hasFileAttachment(message: message) {
                    factory.makeFileAttachmentView(
                        options: FileAttachmentViewOptions(
                            message: message,
                            isFirst: isFirst,
                            availableWidth: width,
                            scrolledId: $scrolledId
                        )
                    )
                }
                
                // Voice recordings
                if messageTypeResolver.hasVoiceRecording(message: message) {
                    factory.makeVoiceRecordingView(
                        options: VoiceRecordingViewOptions(
                            message: message,
                            isFirst: isFirst,
                            availableWidth: width,
                            scrolledId: $scrolledId
                        )
                    )
                }
                
                // Link previews
                if messageTypeResolver.hasLinkAttachment(message: message)
                    && message.attachmentCounts.keys.allSatisfy({ $0 == .linkPreview }) {
                    factory.makeLinkAttachmentView(
                        options: LinkAttachmentViewOptions(
                            message: message,
                            isFirst: isFirst,
                            availableWidth: width,
                            scrolledId: $scrolledId
                        )
                    )
                }
            }
            // Text caption
            if !message.text.isEmpty {
                factory.makeAttachmentTextView(
                    options: AttachmentTextViewOptions(
                        message: message,
                        availableWidth: width,
                        translationLanguage: translationLanguage
                    )
                )
            }
        }
        .modifier(
            MessageAttachmentsBubbleModifier(
                factory: factory,
                messageModifierInfo: messageModifierInfo,
                bubbleInsets: bubbleInsets
            )
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("MessageAttachmentsView")
    }
}

private struct MessageAttachmentsBubbleModifier<Factory: ViewFactory>: ViewModifier {
    let factory: Factory
    let messageModifierInfo: MessageModifierInfo?
    let bubbleInsets: EdgeInsets
    
    @ViewBuilder
    func body(content: Content) -> some View {
        if let messageModifierInfo {
            content
                .padding(bubbleInsets)
                .modifier(
                    factory.styles.makeMessageViewModifier(
                        for: messageModifierInfo
                    )
                )
        } else {
            content
        }
    }
}

/// Bubble styling configuration for stacked attachments.
enum MessageAttachmentsBubbleConfiguration {
    @MainActor static func messageModifierInfo(for message: ChatMessage, isFirst: Bool) -> MessageModifierInfo? {
        guard isBubbleShown(for: message) else { return nil }
        return MessageModifierInfo(message: message, isFirst: isFirst)
    }

    @MainActor static func isBubbleShown(for message: ChatMessage) -> Bool {
        if message.hasSingleMediaAttachmentWithoutCaption {
            return false
        }
        return true
    }
    
    @MainActor static func bubbleInsets(for message: ChatMessage) -> EdgeInsets {
        guard isBubbleShown(for: message) else { return EdgeInsets() }
        // Single voice and file don't have extra padding
        if message.hasSingleFileOrVoiceAttachmentWithoutCaption {
            return EdgeInsets()
        }
        @Injected(\.tokens) var tokens
        return EdgeInsets(
            top: tokens.spacingXs,
            leading: tokens.spacingXs,
            bottom: tokens.spacingXs,
            trailing: tokens.spacingXs
        )
    }
    
    @MainActor static func attachmentBackgroundColor(for message: ChatMessage) -> Color {
        // Single file and voice attachments are rendered in a bubble, but attachment itself does not have additional darker background
        if message.hasSingleFileOrVoiceAttachmentWithoutCaption {
            return .clear
        }
        @Injected(\.colors) var colors
        return Color(message.isSentByCurrentUser ? colors.chatBackgroundAttachmentOutgoing : colors.chatBackgroundAttachmentIncoming)
    }

    /// Applies the attachment container styling: background color, border
    /// stroke, and clip shape with corners that respect the message bubble
    /// shape when the attachment is the only content.
    ///
    /// The caller provides `isSingleWithoutCaption` because "single"
    /// differs per attachment type (file count vs. voice recording count).
    struct AttachmentContainerModifier: ViewModifier {
        @Injected(\.colors) private var colors
        @Injected(\.tokens) private var tokens
        @Injected(\.utils) private var utils
        @Environment(\.layoutDirection) private var layoutDirection

        let message: ChatMessage
        let isFirst: Bool
        let isSingleWithoutCaption: Bool

        func body(content: Content) -> some View {
            let corners: UIRectCorner = isFirst && isSingleWithoutCaption
                ? message.bubbleCorners(
                    isFirst: isFirst,
                    forceLeftToRight: utils.messageListConfig.messageListAlignment == .leftAligned,
                    layoutDirection: layoutDirection
                )
                : .allCorners
            content
                .background(MessageAttachmentsBubbleConfiguration.attachmentBackgroundColor(for: message))
                .overlay(
                    BubbleBackgroundShape(
                        cornerRadius: tokens.messageBubbleRadiusAttachment,
                        corners: corners
                    )
                    .stroke(Color(colors.borderCoreDefault), lineWidth: 1)
                )
                .clipShape(
                    BubbleBackgroundShape(
                        cornerRadius: tokens.messageBubbleRadiusAttachment,
                        corners: corners
                    )
                )
        }
    }

    /// Applies the voice recording attachment container styling (padding,
    /// background, and rounded border). When the voice recording is a
    /// quoted reply without a text caption, the background and border are
    /// omitted so the player renders flat inside the message bubble.
    struct VoiceRecordingContainerModifier: ViewModifier {
        @Injected(\.tokens) private var tokens

        let message: ChatMessage
        let isFirst: Bool

        @ViewBuilder
        func body(content: Content) -> some View {
            if isContainerShown {
                content
                    .padding(.all, tokens.spacingXs)
                    .modifier(AttachmentContainerModifier(
                        message: message,
                        isFirst: isFirst,
                        isSingleWithoutCaption: message.text.isEmpty
                            && message.voiceRecordingAttachments.count == 1
                    ))
            } else {
                content
            }
        }

        private var isContainerShown: Bool {
            !(message.quotedMessage != nil && message.text.isEmpty)
        }
    }
}

extension ChatMessage {
    var hasSingleFileOrVoiceAttachmentWithoutCaption: Bool {
        guard text.isEmpty, quotedMessage == nil else { return false }
        return attachmentCounts.count == 1 && (attachmentCounts[.file] == 1 || attachmentCounts[.voiceRecording] == 1)
    }
    
    var hasSingleMediaAttachmentWithoutCaption: Bool {
        guard text.isEmpty, quotedMessage == nil else { return false }
        return attachmentCounts.count == 1 && (attachmentCounts[.image] == 1 || attachmentCounts[.video] == 1)
    }
    
    var hasSingleMediaAttachmentWithCaption: Bool {
        guard !text.isEmpty, quotedMessage == nil else { return false }
        return attachmentCounts.count == 1 && (attachmentCounts[.image] == 1 || attachmentCounts[.video] == 1)
    }
}
