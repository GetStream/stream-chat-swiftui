//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChatCommonUI
import SwiftUI

/// A quoted message view with a dismiss button overlay.
///
/// This is a convenience wrapper around `ReferenceMessageView` that adds a dismiss button
/// in the top-trailing corner. Use this in the composer to display quoted messages with
/// the ability to dismiss/cancel the quote.
///
/// Example usage:
/// ```swift
/// ComposerQuotedMessageView(
///     title: "Reply to John",
///     subtitle: "Check out this photo!",
///     isSentByCurrentUser: true,
///     onDismiss: { quotedMessage = nil }
/// )
/// ```
public struct ComposerQuotedMessageView<AttachmentPreview: View>: View {
    @Injected(\.tokens) private var tokens

    /// The title text displayed at the top (e.g., "Reply to Emma Chen").
    public let title: String
    /// The subtitle text displayed below the title (e.g., message preview or attachment description).
    public let subtitle: String
    /// An optional icon displayed before the subtitle (e.g., attachment type icon).
    public let subtitleIcon: UIImage?
    /// Whether the referenced message was sent by the current user. Affects the indicator color.
    public let isSentByCurrentUser: Bool
    /// An optional attachment preview displayed on the trailing edge.
    public let attachmentPreview: AttachmentPreview?
    /// Action called when the dismiss button is tapped. If nil, no dismiss button is shown.
    public let onDismiss: (() -> Void)?

    /// Creates a quoted message view with an attachment preview and optional dismiss button.
    /// - Parameters:
    ///   - title: The title text (e.g., "Reply to [Author]").
    ///   - subtitle: The subtitle text (e.g., message preview).
    ///   - subtitleIcon: An optional icon displayed before the subtitle.
    ///   - isSentByCurrentUser: Whether the referenced message was sent by the current user.
    ///   - onDismiss: Action called when the dismiss button is tapped. Pass nil to hide the button.
    ///   - attachmentPreview: A view builder for the attachment preview.
    public init(
        title: String,
        subtitle: String,
        subtitleIcon: UIImage? = nil,
        isSentByCurrentUser: Bool,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder attachmentPreview: () -> AttachmentPreview
    ) {
        self.title = title
        self.subtitle = subtitle
        self.subtitleIcon = subtitleIcon
        self.isSentByCurrentUser = isSentByCurrentUser
        self.onDismiss = onDismiss
        self.attachmentPreview = attachmentPreview()
    }

    public var body: some View {
        chatQuotedMessageView
            .dismissButtonOverlayModifier(onDismiss: onDismiss)
    }

    @ViewBuilder
    private var chatQuotedMessageView: some View {
        if let attachmentPreview {
            ChatQuotedMessageView(
                title: title,
                subtitle: subtitle,
                subtitleIcon: subtitleIcon,
                isSentByCurrentUser: isSentByCurrentUser
            ) {
                attachmentPreview
            }
        } else {
            ChatQuotedMessageView(
                title: title,
                subtitle: subtitle,
                subtitleIcon: subtitleIcon,
                isSentByCurrentUser: isSentByCurrentUser
            )
        }
    }
}

extension ComposerQuotedMessageView where AttachmentPreview == EmptyView {
    /// Creates a quoted message view without an attachment preview.
    /// - Parameters:
    ///   - title: The title text (e.g., "Reply to [Author]").
    ///   - subtitle: The subtitle text (e.g., message preview).
    ///   - subtitleIcon: An optional icon displayed before the subtitle.
    ///   - isSentByCurrentUser: Whether the referenced message was sent by the current user.
    ///   - onDismiss: Action called when the dismiss button is tapped. Pass nil to hide the button.
    public init(
        title: String,
        subtitle: String,
        subtitleIcon: UIImage? = nil,
        isSentByCurrentUser: Bool,
        onDismiss: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.subtitleIcon = subtitleIcon
        self.isSentByCurrentUser = isSentByCurrentUser
        self.onDismiss = onDismiss
        self.attachmentPreview = nil
    }
}
