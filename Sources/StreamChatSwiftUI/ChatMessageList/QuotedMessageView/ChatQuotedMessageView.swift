//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// A container view for displaying quoted messages in the message list.
/// This view handles the tap gesture to scroll to the original message.
public struct ChatQuotedMessageView<Factory: ViewFactory>: View {
    /// The baseline height of the quoted message bubble. The bubble grows beyond
    /// this when the quoted content needs more space (e.g. at large text sizes).
    static var minimumHeight: CGFloat { 56 }

    private let factory: Factory
    private let quotedMessage: ChatMessage
    private let parentMessage: ChatMessage
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
        self.parentMessage = parentMessage
        self.availableWidth = availableWidth
        self._scrolledId = scrolledId
    }

    public var body: some View {
        factory.makeQuotedMessageView(
            options: QuotedMessageViewOptions(
                quotedMessage: quotedMessage,
                outgoing: parentMessage.isSentByCurrentUser
            )
        )
        .modifier(
            factory.styles.makeMessageAttachmentItemViewModifier(
                options: MessageAttachmentItemViewModifierOptions(
                    message: parentMessage,
                    isFirst: true
                )
            )
        )
        // Size the bubble to its content height (with a baseline minimum) instead
        // of a fixed height, so it grows to fit the quoted content at larger
        // Dynamic Type sizes without clipping. `fixedSize` lets the bubble hug the
        // text while keeping the quote indicator stretched to the full height and
        // preserving the internal padding.
        .fixedSize(horizontal: false, vertical: true)
        .frame(width: availableWidth)
        .frame(minHeight: Self.minimumHeight)
        .onTapGesture {
            scrolledId = quotedMessage.messageId
        }
        .accessibilityAction {
            scrolledId = quotedMessage.messageId
        }
        .accessibilityIdentifier("ChatQuotedMessageView")
    }
}
