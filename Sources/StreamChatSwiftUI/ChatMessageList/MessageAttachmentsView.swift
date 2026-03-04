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

    private var showsBubble: Bool {
        if !message.text.isEmpty {
            return true
        }
        let imageCount = message.imageAttachments.count
        let videoCount = message.videoAttachments.count
        let totalMedia = imageCount + videoCount
        if totalMedia == 1
            && !messageTypeResolver.hasFileAttachment(message: message)
            && !messageTypeResolver.hasVoiceRecording(message: message) {
            return false
        }
        return true
    }

    public var body: some View {
        VStack(
            alignment: message.alignmentInBubble,
            spacing: tokens.spacingXs
        ) {
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

            // Giphy
            if messageTypeResolver.hasGiphyAttachment(message: message) {
                factory.makeGiphyAttachmentView(
                    options: GiphyAttachmentViewOptions(
                        message: message,
                        isFirst: isFirst,
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

            // Text caption
            if !message.text.isEmpty {
                AttachmentTextView(factory: factory, message: message)
            }
        }
        .if(showsBubble) { view in
            view
                .padding(tokens.spacingXs)
                .modifier(
                    factory.styles.makeMessageViewModifier(
                        for: MessageModifierInfo(
                            message: message,
                            isFirst: isFirst
                        )
                    )
                )
        }
        .accessibilityIdentifier("MessageAttachmentsView")
    }
}
