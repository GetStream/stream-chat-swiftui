//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatCommonUI
import SwiftUI

/// A quoted message view with a dismiss button overlay.
///
/// This is a convenience wrapper around `ChatQuotedMessageView` that adds a dismiss button
/// in the top-trailing corner. Use this in the composer to display quoted messages with
/// the ability to dismiss/cancel the quote.
public struct ComposerQuotedMessageView: View {
    @Injected(\.tokens) private var tokens

    private let viewModel: QuotedMessageViewModel
    private let onDismiss: () -> Void
    
    /// Creates a composer quoted message view from a view model.
    /// - Parameters:
    ///   - viewModel: The view model containing the quoted message data.
    ///   - onDismiss: Action called when the dismiss button is tapped.
    public init(
        viewModel: QuotedMessageViewModel,
        onDismiss: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.onDismiss = onDismiss
    }

    public var body: some View {
        ChatQuotedMessageView(
            viewModel: viewModel,
            padding: .init(
                top: tokens.spacingXs,
                leading: tokens.spacingXs,
                bottom: tokens.spacingXs,
                trailing: tokens.spacingXs
            )
        )
        .dismissButtonOverlayModifier(onDismiss: onDismiss)
    }
}
