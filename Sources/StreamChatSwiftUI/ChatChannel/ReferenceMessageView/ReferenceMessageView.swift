//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// A reusable view for displaying a reference to another message.
///
/// This component is designed to be used in various contexts where a message reference needs to be shown,
/// such as quoted messages in the composer or edited message references.
public struct ReferenceMessageView<AttachmentPreview: View>: View {
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    @Injected(\.images) var images
    @Injected(\.tokens) var tokens

    /// The title text displayed at the top, usually the author.
    public let title: String
    /// The subtitle text displayed below the title (e.g., message preview or attachment description).
    public let subtitle: String
    /// An optional icon displayed before the subtitle (e.g., attachment type icon).
    public let subtitleIcon: UIImage?
    /// Whether the referenced message was sent by the current user. Affects the indicator color.
    public let isSentByCurrentUser: Bool
    /// An optional attachment preview displayed on the trailing edge.
    public let attachmentPreview: AttachmentPreview?

    /// Creates a message reference view with an attachment preview.
    /// - Parameters:
    ///   - title: The title text (e.g., "Reply to [Author]").
    ///   - subtitle: The subtitle text (e.g., message preview).
    ///   - subtitleIcon: An optional icon displayed before the subtitle.
    ///   - isSentByCurrentUser: Whether the referenced message was sent by the current user.
    ///   - attachmentPreview: A view builder for the attachment preview.
    public init(
        title: String,
        subtitle: String,
        subtitleIcon: UIImage? = nil,
        isSentByCurrentUser: Bool,
        @ViewBuilder attachmentPreview: () -> AttachmentPreview
    ) {
        self.title = title
        self.subtitle = subtitle
        self.subtitleIcon = subtitleIcon
        self.isSentByCurrentUser = isSentByCurrentUser
        self.attachmentPreview = attachmentPreview()
    }

    public var body: some View {
        HStack(spacing: tokens.spacingXs) {
            ReferenceIndicatorView(
                tintColor: isSentByCurrentUser
                    ? colors.chatReplyIndicatorOutgoing
                    : colors.chatReplyIndicatorIncoming
            )

            VStack(alignment: .leading, spacing: 2) {
                titleView
                subtitleView
            }

            Spacer()

            if let attachmentPreview {
                attachmentPreview
            }
        }
    }

    var titleView: some View {
        Text(title)
            .font(fonts.subheadlineBold)
            .foregroundColor(Color(colors.chatTextMessage))
            .lineLimit(1)
    }

    var subtitleView: some View {
        HStack(spacing: tokens.spacingXxs) {
            if let subtitleIcon {
                Image(uiImage: subtitleIcon)
                    .renderingMode(.template)
                    .resizable()
                    .foregroundColor(Color(colors.chatTextMessage))
                    .aspectRatio(contentMode: .fit)
                    .frame(
                        width: tokens.iconSizeXs,
                        height: tokens.iconSizeXs
                    )
                    .accessibilityHidden(true)
            }

            Text(subtitle)
                .font(fonts.footnote)
                .foregroundColor(Color(colors.chatTextMessage))
                .lineLimit(1)
        }
    }
}

extension ReferenceMessageView where AttachmentPreview == EmptyView {
    /// Creates a message reference view without an attachment preview.
    /// - Parameters:
    ///   - title: The title text (e.g., "Reply to [Author]").
    ///   - subtitle: The subtitle text (e.g., message preview).
    ///   - subtitleIcon: An optional icon displayed before the subtitle.
    ///   - isSentByCurrentUser: Whether the referenced message was sent by the current user.
    public init(
        title: String,
        subtitle: String,
        subtitleIcon: UIImage? = nil,
        isSentByCurrentUser: Bool
    ) {
        self.title = title
        self.subtitle = subtitle
        self.subtitleIcon = subtitleIcon
        self.isSentByCurrentUser = isSentByCurrentUser
        self.attachmentPreview = nil
    }
}

// MARK: - ReferenceIndicatorView

/// A vertical indicator bar used in message references.
struct ReferenceIndicatorView: View {
    let tintColor: UIColor

    var body: some View {
        Rectangle()
            .fill(Color(tintColor))
            .frame(width: 2)
            .clipShape(RoundedRectangle(cornerRadius: 2))
            .accessibilityIdentifier("QuoteIndicatorView")
            .accessibilityHidden(true)
    }
}
