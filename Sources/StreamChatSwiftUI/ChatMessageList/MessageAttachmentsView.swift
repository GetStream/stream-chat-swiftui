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
    @ObservedObject var messageViewModel: MessageViewModel
    let width: CGFloat
    let isFirst: Bool
    @Binding var scrolledId: String?

    public init(
        factory: Factory,
        messageViewModel: MessageViewModel,
        width: CGFloat,
        isFirst: Bool,
        scrolledId: Binding<String?>
    ) {
        self.factory = factory
        self.messageViewModel = messageViewModel
        self.width = width
        self.isFirst = isFirst
        self._scrolledId = scrolledId
    }

    public var body: some View {
        VStack(alignment: messageViewModel.message.alignmentInBubble, spacing: tokens.spacingXs) {
            VStack(alignment: messageViewModel.message.isRightAligned ? .trailing : .leading, spacing: tokens.spacingXs) {
                if let quotedMessage = messageViewModel.message.quotedMessage {
                    factory.makeChatQuotedMessageView(
                        options: ChatQuotedMessageViewOptions(
                            quotedMessage: quotedMessage,
                            parentMessage: messageViewModel.message,
                            availableWidth: width,
                            scrolledId: $scrolledId
                        )
                    )
                }

                // Images or images and videos
                if messageTypeResolver.hasImageAttachment(message: messageViewModel.message) {
                    factory.makeImageAttachmentView(
                        options: ImageAttachmentViewOptions(
                            message: messageViewModel.message,
                            isFirst: isFirst,
                            availableWidth: width,
                            scrolledId: $scrolledId
                        )
                    )
                }

                // Only videos
                if messageTypeResolver.hasVideoAttachment(message: messageViewModel.message)
                    && !messageTypeResolver.hasImageAttachment(message: messageViewModel.message) {
                    factory.makeVideoAttachmentView(
                        options: VideoAttachmentViewOptions(
                            message: messageViewModel.message,
                            isFirst: isFirst,
                            availableWidth: width,
                            scrolledId: $scrolledId
                        )
                    )
                }

                // Files
                if messageTypeResolver.hasFileAttachment(message: messageViewModel.message) {
                    factory.makeFileAttachmentView(
                        options: FileAttachmentViewOptions(
                            message: messageViewModel.message,
                            isFirst: isFirst,
                            availableWidth: width,
                            scrolledId: $scrolledId
                        )
                    )
                }

                // Voice recordings
                if messageTypeResolver.hasVoiceRecording(message: messageViewModel.message) {
                    factory.makeVoiceRecordingView(
                        options: VoiceRecordingViewOptions(
                            message: messageViewModel.message,
                            isFirst: isFirst,
                            availableWidth: width,
                            scrolledId: $scrolledId
                        )
                    )
                }

                // Link previews
                if messageTypeResolver.hasLinkAttachment(message: messageViewModel.message)
                    && messageViewModel.message.attachmentCounts.keys.allSatisfy({ $0 == .linkPreview }) {
                    factory.makeLinkAttachmentView(
                        options: LinkAttachmentViewOptions(
                            message: messageViewModel.message,
                            isFirst: isFirst,
                            availableWidth: width,
                            scrolledId: $scrolledId
                        )
                    )
                }
            }
            // Text caption
            if !messageViewModel.message.text.isEmpty {
                factory.makeAttachmentTextView(
                    options: AttachmentTextViewOptions(
                        messageViewModel: messageViewModel,
                        availableWidth: width
                    )
                )
            }
        }
        .if(MessageAttachmentsBubbleConfiguration.isBubbleShown(for: messageViewModel.message)) { view in
            view
                .padding(MessageAttachmentsBubbleConfiguration.bubbleContentPadding(for: messageViewModel.message))
                .modifier(
                    factory.styles.makeMessageViewModifier(
                        for: MessageModifierInfo(
                            message: messageViewModel.message,
                            isFirst: isFirst
                        )
                    )
                )
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("MessageAttachmentsView")
    }
}

/// Bubble styling configuration for stacked attachments.
enum MessageAttachmentsBubbleConfiguration {
    @MainActor static func isBubbleShown(for message: ChatMessage) -> Bool {
        if message.hasSingleMediaAttachmentWithoutCaption {
            return false
        }
        return true
    }
    
    @MainActor static func bubbleContentPadding(for message: ChatMessage) -> CGFloat {
        guard isBubbleShown(for: message) else { return 0 }
        // Single voice and file don't have extra padding
        if message.hasSingleFileOrVoiceAttachmentWithoutCaption {
            return 0
        }
        @Injected(\.tokens) var tokens
        return tokens.spacingXs
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
