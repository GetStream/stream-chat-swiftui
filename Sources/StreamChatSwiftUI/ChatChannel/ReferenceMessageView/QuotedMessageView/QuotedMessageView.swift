//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// A quoted message view used to display a reference to another message.
public struct QuotedMessageView<Factory: ViewFactory>: View {
    @Injected(\.tokens) private var tokens

    private let factory: Factory
    private let viewModel: QuotedMessageViewModel
    private let padding: EdgeInsets?

    /// Creates a quoted message view from a view model.
    /// - Parameters:
    ///   - factory: The view factory to create customizable subviews.
    ///   - viewModel: The view model containing the quoted message data.
    ///   - padding: The padding to apply around the quoted message view.
    public init(
        factory: Factory,
        viewModel: QuotedMessageViewModel,
        padding: EdgeInsets? = nil
    ) {
        self.factory = factory
        self.viewModel = viewModel
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

    /// The default padding applied to the quoted message view.
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
            isSentByCurrentUser: viewModel.isSentByCurrentUser,
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
