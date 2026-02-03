//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatCommonUI
import SwiftUI

/// A quoted message view with a dismiss button overlay.
///
/// This is a convenience wrapper around `QuotedMessageView` that adds a dismiss button
/// in the top-trailing corner. Use this in the composer to display quoted messages with
/// the ability to dismiss/cancel the quote.
public struct ComposerQuotedMessageView<Factory: ViewFactory>: View {
    @Injected(\.tokens) private var tokens

    private let factory: Factory
    private let quotedMessage: ChatMessage
    private let channel: ChatChannel?
    private let onDismiss: () -> Void
    
    /// Creates a composer quoted message view.
    /// - Parameters:
    ///   - factory: The view factory to create the quoted message view.
    ///   - quotedMessage: The quoted message to display.
    ///   - channel: The channel where the quoted message belongs.
    ///   - onDismiss: Action called when the dismiss button is tapped.
    public init(
        factory: Factory,
        quotedMessage: ChatMessage,
        channel: ChatChannel?,
        onDismiss: @escaping () -> Void
    ) {
        self.factory = factory
        self.quotedMessage = quotedMessage
        self.channel = channel
        self.onDismiss = onDismiss
    }

    public var body: some View {
        factory.makeQuotedMessageView(
            options: QuotedMessageViewOptions(
                quotedMessage: quotedMessage,
                channel: channel,
                padding: .init(
                    top: tokens.spacingXs,
                    leading: tokens.spacingXs,
                    bottom: tokens.spacingXs,
                    trailing: tokens.spacingXs
                )
            )
        )
        .dismissButtonOverlayModifier(onDismiss: onDismiss)
        .padding(.top, tokens.spacingSm)
        .padding(.trailing, tokens.spacingSm)
        .padding(.leading, tokens.spacingSm)
        .padding(.bottom, tokens.spacingXxs)
    }
}
