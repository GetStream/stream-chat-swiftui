//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// A reusable view for displaying a reference to another message.
///
/// This component is designed to be used in various contexts where a message reference
/// needs to be shown, such as quoted messages in the composer or edited message references.
public struct ReferenceMessageView<IconPreview: View, AttachmentPreview: View>: View {
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    @Injected(\.tokens) var tokens

    /// The title text displayed at the top, usually the author.
    public let title: String
    /// The subtitle text displayed below the title (e.g., message preview or attachment description).
    public let subtitle: String
    /// An optional icon preview displayed before the subtitle (e.g., attachment type icon).
    public let iconPreview: IconPreview?
    /// Whether the referenced message was sent by the current user. Affects the indicator color.
    public let isSentByCurrentUser: Bool
    /// An optional attachment preview displayed on the trailing edge.
    public let attachmentPreview: AttachmentPreview?

    /// Creates a message reference view with both icon and attachment previews.
    /// - Parameters:
    ///   - title: The title text (e.g., "Reply to [Author]").
    ///   - subtitle: The subtitle text (e.g., message preview).
    ///   - isSentByCurrentUser: Whether the referenced message was sent by the current user.
    ///   - iconPreview: A view builder for the icon preview displayed before the subtitle.
    ///   - attachmentPreview: A view builder for the attachment preview.
    public init(
        title: String,
        subtitle: String,
        isSentByCurrentUser: Bool,
        @ViewBuilder iconPreview: () -> IconPreview,
        @ViewBuilder attachmentPreview: () -> AttachmentPreview
    ) {
        self.title = title
        self.subtitle = subtitle
        self.isSentByCurrentUser = isSentByCurrentUser
        self.iconPreview = iconPreview()
        self.attachmentPreview = attachmentPreview()
    }

    public var body: some View {
        HStack(spacing: tokens.spacingXs) {
            ReferenceIndicatorView(
                tintColor: isSentByCurrentUser
                    ? colors.chatReplyIndicatorOutgoing
                    : colors.chatReplyIndicatorIncoming
            )

            VStack(alignment: .leading, spacing: tokens.spacingXxxs) {
                titleView
                subtitleView
            }

            Spacer()

            if let attachmentPreview {
                attachmentPreview
            }
        }
        .accessibilityElement(children: .contain)
    }

    var titleView: some View {
        Text(title)
            .font(fonts.subheadlineBold)
            .foregroundColor(Color(isSentByCurrentUser ? colors.chatTextOutgoing : colors.chatTextIncoming))
            .lineLimit(1)
    }

    @ViewBuilder
    var subtitleView: some View {
        HStack(spacing: tokens.spacingXxs) {
            if let iconPreview {
                iconPreview
            }

            Text(subtitle)
                .font(fonts.footnote)
                .foregroundColor(Color(isSentByCurrentUser ? colors.chatTextOutgoing : colors.chatTextIncoming))
                .lineLimit(1)
                .accessibilityIdentifier("referenceMessageSubtitle")
        }
    }
}

// MARK: - Convenience Initializers

extension ReferenceMessageView where IconPreview == EmptyView, AttachmentPreview == EmptyView {
    /// Creates a message reference view without icon or attachment previews.
    /// - Parameters:
    ///   - title: The title text (e.g., "Reply to [Author]").
    ///   - subtitle: The subtitle text (e.g., message preview).
    ///   - isSentByCurrentUser: Whether the referenced message was sent by the current user.
    public init(
        title: String,
        subtitle: String,
        isSentByCurrentUser: Bool
    ) {
        self.title = title
        self.subtitle = subtitle
        self.isSentByCurrentUser = isSentByCurrentUser
        self.iconPreview = nil
        self.attachmentPreview = nil
    }
}

// MARK: - ReferenceIndicatorView

/// A vertical indicator bar used in message references.
public struct ReferenceIndicatorView: View {
    let tintColor: UIColor

    public var body: some View {
        Rectangle()
            .fill(Color(tintColor))
            .frame(width: 2)
            .clipShape(RoundedRectangle(cornerRadius: 2))
            .accessibilityIdentifier("QuoteIndicatorView")
            .accessibilityHidden(true)
    }
}
