//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// A container view for displaying quoted messages in the message list.
/// This view handles the tap gesture to scroll to the original message.
public struct ChatQuotedMessageView<Factory: ViewFactory>: View {
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens
    
    private let factory: Factory
    private let quotedMessage: ChatMessage
    private let parentMessageSentByCurrentUser: Bool
    private let availableWidth: CGFloat?
    @Binding private var scrolledId: String?

    /// Creates a chat quoted message view.
    /// - Parameters:
    ///   - factory: The view factory to create the quoted message view.
    ///   - quotedMessage: The quoted message to display.
    ///   - availableWidth: The available width for the quoted message view.
    ///   - scrolledId: A binding to the scrolled message ID for navigation to the quoted message.
    public init(
        factory: Factory,
        quotedMessage: ChatMessage,
        parentMessage: ChatMessage,
        availableWidth: CGFloat? = nil,
        scrolledId: Binding<String?>
    ) {
        self.factory = factory
        self.quotedMessage = quotedMessage
        parentMessageSentByCurrentUser = parentMessage.isSentByCurrentUser
        self.availableWidth = availableWidth
        self._scrolledId = scrolledId
    }

    public var body: some View {
        factory.makeQuotedMessageView(
            options: QuotedMessageViewOptions(
                quotedMessage: quotedMessage,
                outgoing: parentMessageSentByCurrentUser
            )
        )
        .modifier(ReferenceMessageViewBackgroundModifier(
            backgroundColor: Color(
                parentMessageSentByCurrentUser
                    ? colors.chatBackgroundAttachmentOutgoing
                    : colors.chatBackgroundAttachmentIncoming
            )
        ))
        .frame(width: availableWidth, height: 56)
        .onTapGesture {
            scrolledId = quotedMessage.messageId
        }
        .accessibilityAction {
            scrolledId = quotedMessage.messageId
        }
        .accessibilityIdentifier("ChatQuotedMessageView")
    }
}
