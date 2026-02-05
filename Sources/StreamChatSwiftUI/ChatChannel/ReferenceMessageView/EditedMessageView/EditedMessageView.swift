//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// A view that shows a preview of the message that is being edited.
public struct EditedMessageView<Factory: ViewFactory>: View {
    @Injected(\.tokens) private var tokens

    private let factory: Factory
    private let viewModel: EditedMessageViewModel
    private let padding: EdgeInsets?
    private let onDismiss: () -> Void

    /// Creates an edited message view from a view model.
    /// - Parameters:
    ///   - factory: The view factory to create customizable subviews.
    ///   - viewModel: The view model containing the edited message data.
    ///   - padding: The padding to apply around the edited message view.
    ///   - onDismiss: The action to perform when the dismiss button is tapped.
    public init(
        factory: Factory,
        viewModel: EditedMessageViewModel,
        padding: EdgeInsets? = nil,
        onDismiss: @escaping () -> Void
    ) {
        self.factory = factory
        self.viewModel = viewModel
        self.padding = padding
        self.onDismiss = onDismiss
    }

    public var body: some View {
        referenceMessageView
            .padding(tokens.spacingXs)
            .modifier(ReferenceMessageViewBackgroundModifier(
                isSentByCurrentUser: true
            ))
            .modifier(DismissButtonOverlayModifier(onDismiss: onDismiss))
            .frame(height: 56)
            .padding(.top, tokens.spacingSm)
            .padding(.trailing, tokens.spacingSm)
            .padding(.leading, tokens.spacingSm)
            .padding(.bottom, tokens.spacingXxs)
            .accessibilityIdentifier("EditedMessageView")
    }

    @ViewBuilder
    private var referenceMessageView: some View {
        ReferenceMessageView(
            title: viewModel.title,
            subtitle: viewModel.subtitle,
            subtitleIcon: viewModel.subtitleIcon?.image,
            isSentByCurrentUser: true
        )
    }
}
