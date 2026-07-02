//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// A quoted message view with a dismiss button overlay.
///
/// This is a convenience wrapper around `QuotedMessageView` that adds a dismiss button
/// in the top-trailing corner. Use this in the composer to display quoted messages with
/// the ability to dismiss/cancel the quote.
public struct ComposerQuotedMessageView<Factory: ViewFactory>: View {
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens

    /// The baseline height of the quoted message bubble. The bubble grows beyond
    /// this when the quoted content needs more space (e.g. at large text sizes).
    static var minimumHeight: CGFloat { 56 }

    private let factory: Factory
    private let quotedMessage: ChatMessage
    private let onDismiss: () -> Void
    
    /// Creates a composer quoted message view.
    /// - Parameters:
    ///   - factory: The view factory to create the quoted message view.
    ///   - quotedMessage: The quoted message to display.
    ///   - onDismiss: Action called when the dismiss button is tapped.
    public init(
        factory: Factory,
        quotedMessage: ChatMessage,
        onDismiss: @escaping () -> Void
    ) {
        self.factory = factory
        self.quotedMessage = quotedMessage
        self.onDismiss = onDismiss
    }

    public var body: some View {
        factory.makeQuotedMessageView(
            options: QuotedMessageViewOptions(
                quotedMessage: quotedMessage,
                outgoing: quotedMessage.isSentByCurrentUser,
                padding: .init(
                    top: tokens.spacingXs,
                    leading: tokens.spacingXs,
                    bottom: tokens.spacingXs,
                    trailing: tokens.spacingXs
                )
            )
        )
        .modifier(ReferenceMessageViewBackgroundModifier(
            backgroundColor: Color(
                quotedMessage.isSentByCurrentUser
                    ? colors.chatBackgroundOutgoing
                    : colors.chatBackgroundIncoming
            )
        ))
        .fixedSize(horizontal: false, vertical: true)
        .frame(minHeight: Self.minimumHeight)
        .dismissButtonOverlayModifier(onDismiss: onDismiss)
        .padding(.top, tokens.spacingSm)
        .padding(.trailing, tokens.spacingSm)
        .padding(.leading, tokens.spacingSm)
        .padding(.bottom, tokens.spacingXxs)
    }
}
