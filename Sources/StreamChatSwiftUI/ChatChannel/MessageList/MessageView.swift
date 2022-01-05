//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct MessageView<Factory: ViewFactory>: View {
    @Injected(\.utils) private var utils
    
    private var messageTypeResolver: MessageTypeResolving {
        utils.messageTypeResolver
    }
    
    var factory: Factory
    var message: ChatMessage
    var contentWidth: CGFloat
    var isFirst: Bool
    @Binding var scrolledId: String?
    
    var body: some View {
        VStack {
            if messageTypeResolver.hasCustomAttachment(message: message) {
                factory.makeCustomAttachmentViewType(
                    for: message,
                    isFirst: isFirst,
                    availableWidth: contentWidth,
                    scrolledId: $scrolledId
                )
            } else if messageTypeResolver.isDeleted(message: message) {
                factory.makeDeletedMessageView(
                    for: message,
                    isFirst: isFirst,
                    availableWidth: contentWidth
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
            } else {
                if message.shouldRenderAsJumbomoji {
                    EmojiTextView(message: message)
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

public struct MessageTextView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    
    var message: ChatMessage
    var isFirst: Bool
    @Binding var scrolledId: String?
    
    public var body: some View {
        VStack(
            alignment: message.alignmentInBubble,
            spacing: 0
        ) {
            if let quotedMessage = message.quotedMessage {
                QuotedMessageViewContainer(
                    quotedMessage: quotedMessage,
                    fillAvailableSpace: !message.attachmentCounts.isEmpty,
                    scrolledId: $scrolledId
                )
            }
            
            Text(message.text)
                .standardPadding()
                .foregroundColor(Color(colors.text))
                .font(fonts.body)
        }
        .messageBubble(for: message, isFirst: isFirst)
    }
}

public struct EmojiTextView: View {
    var message: ChatMessage
    
    @Injected(\.fonts) private var fonts
    
    public var body: some View {
        Text(message.text)
            .font(fonts.emoji)
    }
}
