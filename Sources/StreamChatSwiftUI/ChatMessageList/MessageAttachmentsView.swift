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
    @Binding var scrolledId: String?

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
                    options: AttachmentTextViewOptions(message: message)
                )
            }
        }
        .frame(width: width, alignment: message.isRightAligned ? .trailing : .leading)
        .if(MessageAttachmentsBubbleConfiguration.isBubbleShown(for: message)) { view in
            view
                .padding(MessageAttachmentsBubbleConfiguration.bubbleContentPadding(for: message))
                .modifier(
                    factory.styles.makeMessageViewModifier(
                        for: MessageModifierInfo(
                            message: message,
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
}

private extension ChatMessage {
    var hasSingleFileOrVoiceAttachmentWithoutCaption: Bool {
        guard text.isEmpty else { return false }
        return attachmentCounts.count == 1 && (attachmentCounts[.file] == 1 || attachmentCounts[.voiceRecording] == 1)
    }
    
    var hasSingleMediaAttachmentWithoutCaption: Bool {
        guard text.isEmpty else { return false }
        return attachmentCounts.count == 1 && (attachmentCounts[.image] == 1 || attachmentCounts[.video] == 1)
    }
}
