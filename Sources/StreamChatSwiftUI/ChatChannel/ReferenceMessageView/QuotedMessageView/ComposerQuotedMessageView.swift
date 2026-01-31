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
    private let onDismiss: (() -> Void)?
    
    /// Creates a composer quoted message view from a view model.
    /// - Parameters:
    ///   - viewModel: The view model containing the quoted message data.
    ///   - onDismiss: Action called when the dismiss button is tapped. Pass nil to hide the button.
    public init(
        viewModel: QuotedMessageViewModel,
        onDismiss: (() -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.onDismiss = onDismiss
    }
    
    /// Creates a composer quoted message view from a `ChatMessage`.
    /// - Parameters:
    ///   - message: The quoted message to display.
    ///   - onDismiss: Action called when the dismiss button is tapped. Pass nil to hide the button.
    public init(
        message: ChatMessage,
        onDismiss: (() -> Void)? = nil
    ) {
        self.viewModel = QuotedMessageViewModel(message: message)
        self.onDismiss = onDismiss
    }

    public var body: some View {
        referenceMessageView
            .padding(.horizontal, tokens.spacingXs)
            .padding(.vertical, tokens.spacingXs)
            .frame(height: 56)
            .modifier(ReferenceMessageViewBackgroundModifier(
                isSentByCurrentUser: viewModel.isSentByCurrentUser
            ))
            .dismissButtonOverlayModifier(onDismiss: onDismiss)
    }

    @ViewBuilder
    private var referenceMessageView: some View {
        ReferenceMessageView(
            title: viewModel.title,
            subtitle: viewModel.subtitle,
            subtitleIcon: subtitleIcon,
            isSentByCurrentUser: viewModel.isSentByCurrentUser
        ) {
            QuotedMessageAttachmentPreviewView(viewModel: viewModel)
        }
    }

    private var subtitleIcon: UIImage? {
        guard let iconName = viewModel.subtitleIconName else {
            return nil
        }
        return UIImage(
            systemName: iconName,
            withConfiguration: UIImage.SymbolConfiguration(weight: .regular)
        )
    }
}
