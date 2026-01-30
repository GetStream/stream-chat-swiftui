//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
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
/// ChatQuotedMessageView(
///     title: "Reply to John",
///     subtitle: "Check out this photo!",
///     isSentByCurrentUser: true,
///     onDismiss: { quotedMessage = nil }
/// )
/// ```
public struct ChatQuotedMessageView<AttachmentPreview: View>: View {
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

    @ViewBuilder
    public var body: some View {
        referenceMessageView
            .padding(.horizontal, tokens.spacingXs)
            .padding(.vertical, tokens.spacingXs)
            .modifier(ReferenceMessageViewBackgroundModifier(
                isSentByCurrentUser: isSentByCurrentUser
            ))
            .dismissButtonOverlayModifier(onDismiss: onDismiss)
    }

    @ViewBuilder
    private var referenceMessageView: some View {
        if let attachmentPreview {
            ReferenceMessageView(
                title: title,
                subtitle: subtitle,
                subtitleIcon: subtitleIcon,
                isSentByCurrentUser: isSentByCurrentUser
            ) {
                attachmentPreview
            }
        } else {
            ReferenceMessageView(
                title: title,
                subtitle: subtitle,
                subtitleIcon: subtitleIcon,
                isSentByCurrentUser: isSentByCurrentUser
            )
        }
    }
}

extension ChatQuotedMessageView where AttachmentPreview == EmptyView {
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

// MARK: - Previews

#Preview {
    ScrollView {
        VStack(alignment: .leading, spacing: 16) {
            Text("Outgoing").font(.title3).bold()
            ChatQuotedMessageView(
                title: "Reply to Emma Chen",
                subtitle: "I think this one could work. Took a short clip…",
                isSentByCurrentUser: true
            )
            .frame(maxHeight: 56)

            Text("Incoming").font(.title3).bold()
            ChatQuotedMessageView(
                title: "Reply to Emma Chen",
                subtitle: "I think this one could work. Took a short clip…",
                isSentByCurrentUser: false
            )
            .frame(maxHeight: 56)

            Text("Link").font(.title3).bold()
            ChatQuotedMessageView(
                title: "Reply to Emma Chen",
                subtitle: "Looks cozy, right? https://bloomh...",
                subtitleIcon: Appearance().images.attachmentLinkIcon,
                isSentByCurrentUser: false
            )
            .frame(maxHeight: 56)

            Text("Image - Single").font(.title3).bold()
            ChatQuotedMessageView(
                title: "Reply to Emma Chen",
                subtitle: "I think this one could work. Took a short clip…",
                subtitleIcon: Appearance().images.attachmentImageIcon,
                isSentByCurrentUser: false
            )
            .frame(maxHeight: 56)

            Text("Image - Single - No Caption").font(.title3).bold()
            ChatQuotedMessageView(
                title: "Reply to Emma Chen",
                subtitle: "Photo",
                subtitleIcon: Appearance().images.attachmentImageIcon,
                isSentByCurrentUser: false
            )
            .frame(maxHeight: 56)

            Text("Image - Multiple").font(.title3).bold()
            ChatQuotedMessageView(
                title: "Reply to Emma Chen",
                subtitle: "I love these mountains",
                subtitleIcon: Appearance().images.attachmentImageIcon,
                isSentByCurrentUser: false
            )
            .frame(maxHeight: 56)

            Text("Image - Multiple - No Caption").font(.title3).bold()
            ChatQuotedMessageView(
                title: "Reply to Emma Chen",
                subtitle: "6 photos",
                subtitleIcon: Appearance().images.attachmentImageIcon,
                isSentByCurrentUser: false
            )
            .frame(maxHeight: 56)

            Text("Video - Single").font(.title3).bold()
            ChatQuotedMessageView(
                title: "Reply to Emma Chen",
                subtitle: "I took a short clip earlier",
                subtitleIcon: Appearance().images.attachmentVideoIcon,
                isSentByCurrentUser: false
            )
            .frame(maxHeight: 56)

            Text("Video - Single - No Caption").font(.title3).bold()
            ChatQuotedMessageView(
                title: "Reply to Emma Chen",
                subtitle: "Video",
                subtitleIcon: Appearance().images.attachmentVideoIcon,
                isSentByCurrentUser: false
            )
            .frame(maxHeight: 56)

            Text("Video - Multiple").font(.title3).bold()
            ChatQuotedMessageView(
                title: "Reply to Emma Chen",
                subtitle: "I took some videos today",
                subtitleIcon: Appearance().images.attachmentVideoIcon,
                isSentByCurrentUser: false
            )
            .frame(maxHeight: 56)

            Text("Video - Multiple - No Caption").font(.title3).bold()
            ChatQuotedMessageView(
                title: "Reply to Emma Chen",
                subtitle: "6 videos",
                subtitleIcon: Appearance().images.attachmentVideoIcon,
                isSentByCurrentUser: false
            )
            .frame(maxHeight: 56)

            Text("Mixed").font(.title3).bold()
            ChatQuotedMessageView(
                title: "Reply to Emma Chen",
                subtitle: "I'm sending you some photos and files",
                subtitleIcon: Appearance().images.attachmentDocIcon,
                isSentByCurrentUser: false
            )
            .frame(maxHeight: 56)

            Text("Mixed - No Caption").font(.title3).bold()
            ChatQuotedMessageView(
                title: "Reply to Emma Chen",
                subtitle: "6 files",
                subtitleIcon: Appearance().images.attachmentDocIcon,
                isSentByCurrentUser: false
            )
            .frame(maxHeight: 56)

            Text("Voice Recording").font(.title3).bold()
            ChatQuotedMessageView(
                title: "Reply to Emma Chen",
                subtitle: "I took a short voice message",
                subtitleIcon: Appearance().images.attachmentVoiceIcon,
                isSentByCurrentUser: false
            )
            .frame(maxHeight: 56)

            Text("Voice Recording - No Caption").font(.title3).bold()
            ChatQuotedMessageView(
                title: "Reply to Emma Chen",
                subtitle: "Voice message (0:12)",
                subtitleIcon: Appearance().images.attachmentVoiceIcon,
                isSentByCurrentUser: false
            )
            .frame(maxHeight: 56)

            Text("File").font(.title3).bold()
            ChatQuotedMessageView(
                title: "Reply to Emma Chen",
                subtitle: "Here is the Q4 report",
                subtitleIcon: Appearance().images.attachmentDocIcon,
                isSentByCurrentUser: false
            )
            .frame(maxHeight: 56)

            Text("File - No Caption").font(.title3).bold()
            ChatQuotedMessageView(
                title: "Reply to Emma Chen",
                subtitle: "bloom-and-harbor-cafe-menu-su...",
                subtitleIcon: Appearance().images.attachmentDocIcon,
                isSentByCurrentUser: false
            )
            .frame(maxHeight: 56)

            Text("Poll").font(.title3).bold()
            ChatQuotedMessageView(
                title: "Reply to Emma Chen",
                subtitle: "Where should we host the next team offsite...",
                subtitleIcon: Appearance().images.attachmentPollIcon,
                isSentByCurrentUser: false
            )
            .frame(maxHeight: 56)

            Spacer()
        }
        .padding()
    }
}
