//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// A view that shows a preview of the message that is being edited.
public struct EditedMessageView<Factory: ViewFactory>: View {
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens

    /// The baseline height of the edited message bubble. The bubble grows beyond
    /// this when the referenced content needs more space (e.g. at large text sizes).
    static var minimumHeight: CGFloat { 56 }

    private let factory: Factory
    private let viewModel: EditedMessageViewModel
    private let onDismiss: () -> Void

    /// Creates an edited message view from a view model.
    /// - Parameters:
    ///   - factory: The view factory to create customizable subviews.
    ///   - viewModel: The view model containing the edited message data.
    ///   - onDismiss: The action to perform when the dismiss button is tapped.
    public init(
        factory: Factory,
        viewModel: EditedMessageViewModel,
        onDismiss: @escaping () -> Void
    ) {
        self.factory = factory
        self.viewModel = viewModel
        self.onDismiss = onDismiss
    }

    public var body: some View {
        referenceMessageView
            .padding(tokens.spacingXs)
            .modifier(ReferenceMessageViewBackgroundModifier(
                backgroundColor: colors.chatBackgroundOutgoing.toColor
            ))
            .fixedSize(horizontal: false, vertical: true)
            .frame(minHeight: Self.minimumHeight)
            .modifier(DismissButtonOverlayModifier(onDismiss: onDismiss))
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
            outgoing: true,
            iconPreview: {
                if let icon = viewModel.subtitleIcon {
                    factory.makeMessageAttachmentPreviewIconView(
                        options: MessageAttachmentPreviewIconViewOptions(icon: icon)
                    )
                }
            },
            attachmentPreview: {
                factory.makeMessageAttachmentPreviewThumbnailView(
                    options: MessageAttachmentPreviewViewOptions(
                        thumbnail: viewModel.thumbnail
                    )
                )
            }
        )
    }
}
