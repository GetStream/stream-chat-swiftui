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

    private var showsBubble: Bool {
        if !message.text.isEmpty {
            return true
        }
        let totalAttachments = message.imageAttachments.count
            + message.videoAttachments.count
        if totalAttachments == 1 {
            return false
        }
        return true
    }
    
    private var padding: CGFloat {
        guard showsBubble else { return 0 }
        // Single voice and file don't have extra padding
        let attachmentCounts = message.attachmentCounts
        if message.text.isEmpty, attachmentCounts.count == 1, attachmentCounts[.file] == 1 || attachmentCounts[.voiceRecording] == 1 {
            return 0
        }
        return tokens.spacingXs
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
                
                // Media (images and/or videos)
                if messageTypeResolver.hasImageAttachment(message: message) || messageTypeResolver.hasVideoAttachment(message: message) {
                    factory.makeMediaAttachmentsView(
                        options: MediaAttachmentsViewOptions(
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
                AttachmentTextView(factory: factory, message: message)
            }
        }
        .if(showsBubble) { view in
            view
                .padding(padding)
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
