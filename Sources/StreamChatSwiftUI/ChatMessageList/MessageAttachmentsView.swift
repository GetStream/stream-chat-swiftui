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
    @Binding var scrolledId: String?

    public init(
        factory: Factory,
        message: ChatMessage,
        width: CGFloat,
        isFirst: Bool,
        scrolledId: Binding<String?>,
        translationLanguage: TranslationLanguage? = nil
    ) {
        self.factory = factory
        self.message = message
        self.width = width
        self.isFirst = isFirst
        self.translationLanguage = translationLanguage
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
            factory.styles.makeMessageStackedAttachmentsBubbleModifier(
                options: MessageStackedAttachmentsBubbleModifierOptions(
                    message: message,
                    isFirst: isFirst
                )
            )
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("MessageAttachmentsView")
    }
}
