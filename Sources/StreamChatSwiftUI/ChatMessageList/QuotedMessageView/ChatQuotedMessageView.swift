//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// A container view for displaying quoted messages in the message list.
/// This view handles the tap gesture to scroll to the original message.
public struct ChatQuotedMessageView<Factory: ViewFactory>: View {
    @Injected(\.tokens) private var tokens
    
    private let factory: Factory
    private let quotedMessage: ChatMessage
    private let parentMessageSentByCurrentUser: Bool
    @Binding private var scrolledId: String?

    /// Creates a chat quoted message view.
    /// - Parameters:
    ///   - factory: The view factory to create the quoted message view.
    ///   - quotedMessage: The quoted message to display.
    ///   - scrolledId: A binding to the scrolled message ID for navigation to the quoted message.
    public init(
        factory: Factory,
        quotedMessage: ChatMessage,
        parentMessage: ChatMessage,
        scrolledId: Binding<String?>
    ) {
        self.factory = factory
        self.quotedMessage = quotedMessage
        parentMessageSentByCurrentUser = parentMessage.isSentByCurrentUser
        self._scrolledId = scrolledId
    }

    public var body: some View {
        factory.makeQuotedMessageView(
            options: QuotedMessageViewOptions(
                quotedMessage: quotedMessage,
                quotedByCurrentUser: parentMessageSentByCurrentUser,
                shownInMessageList: true
            )
        )
        .padding(tokens.spacingXs)
        .onTapGesture {
            scrolledId = quotedMessage.messageId
        }
        .accessibilityAction {
            scrolledId = quotedMessage.messageId
        }
        .accessibilityIdentifier("ChatQuotedMessageView")
    }
}
