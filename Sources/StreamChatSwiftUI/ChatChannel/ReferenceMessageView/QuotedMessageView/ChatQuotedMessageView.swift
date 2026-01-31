//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// A quoted message view used to display a reference to another message within a chat.
public struct ChatQuotedMessageView: View {
    @Injected(\.tokens) private var tokens

    private let viewModel: QuotedMessageViewModel
    private let padding: EdgeInsets?

    /// Creates a quoted message view from a view model.
    /// - Parameter viewModel: The view model containing the quoted message data.
    /// - Parameter padding: The padding to apply around the quoted message view.
    public init(
        viewModel: QuotedMessageViewModel,
        padding: EdgeInsets? = nil
    ) {
        self.viewModel = viewModel
        self.padding = padding
    }
    
    /// Creates a quoted message view from a `ChatMessage`.
    /// - Parameter message: The quoted message to display.
    /// - Parameter padding: The padding to apply around the quoted message view.
    public init(
        message: ChatMessage,
        padding: EdgeInsets? = nil
    ) {
        self.viewModel = QuotedMessageViewModel(message: message)
        self.padding = padding
    }

    public var body: some View {
        referenceMessageView
            .padding(padding ?? defaultPadding)
            .modifier(ReferenceMessageViewBackgroundModifier(
                isSentByCurrentUser: viewModel.isSentByCurrentUser
            ))
            .frame(height: 56)
    }

    /// The default padding applied to the quoted message view when used in the message list (chat).
    private var defaultPadding: EdgeInsets {
        .init(
            top: tokens.spacingXs,
            leading: tokens.spacingSm,
            bottom: tokens.spacingXs,
            trailing: tokens.spacingSm
        )
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
