//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Describes which variant the channel list item preview should render.
///
/// The preview is the second line of the row that summarises the channel's
/// latest activity: the most recent message (with author prefix, attachment
/// glyph, or deleted placeholder), a pending draft, a typing indicator, or
/// a "failed to send" status.
///
/// Built with the provided static factory methods. The underlying representation
/// is intentionally hidden so new variants can be added in the future without
/// breaking source compatibility for clients that switch on it.
///
/// Use ``ChatChannelListItemViewModel/preview`` to obtain the default value
/// for a given channel, or construct one of the variants explicitly when
/// rendering ``ChannelItemPreviewView`` in a custom layout.
public struct ChannelItemPreview {
    /// The content of a regular message preview row.
    ///
    /// Renders as an optional leading attachment icon, an optional `Author:`
    /// prefix, and the preview text. Pass `nil` for any decoration you want
    /// to omit.
    public struct MessageContent {
        /// The preview text shown after the optional author prefix.
        public let text: String

        /// The author name displayed before the preview text (group channels,
        /// current user prefix, etc). Pass `nil` to omit the author prefix
        /// (for example, in direct message channels).
        public let authorName: String?

        /// The attachment icon displayed at the leading edge of the row.
        /// Pass `nil` when there is no attachment to preview.
        public let attachmentIcon: UIImage?

        public init(
            text: String,
            authorName: String? = nil,
            attachmentIcon: UIImage? = nil
        ) {
            self.text = text
            self.authorName = authorName
            self.attachmentIcon = attachmentIcon
        }
    }

    enum Kind {
        case failedToSend
        case typing(text: String)
        case draft(text: String)
        case deleted(isSentByCurrentUser: Bool)
        case message(MessageContent)
    }

    let kind: Kind

    private init(_ kind: Kind) {
        self.kind = kind
    }

    /// Failed-to-send variant: shown when the last message failed to send.
    public static func failedToSend() -> ChannelItemPreview {
        .init(.failedToSend)
    }

    /// Typing-indicator variant: shown while other users in the channel are typing.
    /// The provided text is rendered as-is alongside the animated typing dots.
    public static func typing(text: String) -> ChannelItemPreview {
        .init(.typing(text: text))
    }

    /// Draft variant: shown when there is a pending draft message in the channel.
    public static func draft(text: String) -> ChannelItemPreview {
        .init(.draft(text: text))
    }

    /// Deleted variant: shown when the preview message has been deleted.
    public static func deleted(isSentByCurrentUser: Bool) -> ChannelItemPreview {
        .init(.deleted(isSentByCurrentUser: isSentByCurrentUser))
    }

    /// Regular message variant: shown when the latest channel activity is a
    /// regular message. The provided ``MessageContent`` controls whether an
    /// author prefix and/or attachment icon are rendered alongside the
    /// preview text.
    public static func message(_ content: MessageContent) -> ChannelItemPreview {
        .init(.message(content))
    }
}

/// The preview view used by the channel list item.
///
/// Renders one of the preview variants described by the provided
/// ``ChannelItemPreview`` value. Variants include: failed-to-send,
/// typing, draft, deleted, and a regular message (with optional author
/// prefix and attachment icon).
public struct ChannelItemPreviewView: View {
    /// The preview variant to render.
    public let preview: ChannelItemPreview

    public init(_ preview: ChannelItemPreview) {
        self.preview = preview
    }

    public var body: some View {
        HStack(spacing: 4) {
            content
        }
        .accessibilityIdentifier("previewView")
    }

    @ViewBuilder
    private var content: some View {
        switch preview.kind {
        case .failedToSend:
            ChannelItemFailedToSendView()
        case let .typing(text):
            SubtitleTypingIndicatorView(text: text)
        case let .draft(text):
            ChannelItemDraftPreviewView(draftMessageText: text)
        case let .deleted(isSentByCurrentUser):
            ChannelItemDeletedPreviewView(
                isPreviewMessageSentByCurrentUser: isSentByCurrentUser
            )
        case let .message(content):
            messageView(for: content)
        }
    }

    @ViewBuilder
    private func messageView(
        for content: ChannelItemPreview.MessageContent
    ) -> some View {
        if let authorName = content.authorName {
            ChannelItemAuthorPreviewView(
                messagePreviewAuthorName: authorName,
                previewContentText: content.text,
                previewAttachmentIconImage: content.attachmentIcon
            )
        } else if let attachmentIcon = content.attachmentIcon {
            ChannelItemAttachmentPreviewView(
                messagePreviewText: content.text,
                previewAttachmentIconImage: attachmentIcon
            )
        } else {
            SubtitleText(text: content.text)
        }
    }
}

// MARK: - Preview variants

/// Failed-to-send message preview variant for the channel list item: an error
/// icon followed by the "message failed to send" label.
public struct ChannelItemFailedToSendView: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images
    @Injected(\.tokens) private var tokens

    public init() {}

    public var body: some View {
        HStack(spacing: tokens.spacingXxs) {
            Image(uiImage: images.messageListErrorIndicator)
                .customizable()
                .frame(width: tokens.iconSizeSm, height: tokens.iconSizeSm)
                .foregroundColor(Color(colors.badgeBackgroundError))
                .accessibilityHidden(true)
            Text(L10n.Channel.Item.messageFailedToSend)
        }
        .font(fonts.subheadline)
        .foregroundColor(Color(colors.accentError))
        .lineLimit(1)
    }
}

/// Draft message preview variant for the channel list item: a "Draft:" prefix
/// followed by the draft message text.
public struct ChannelItemDraftPreviewView: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors

    /// The formatted draft message text.
    public let draftMessageText: String

    public init(draftMessageText: String) {
        self.draftMessageText = draftMessageText
    }

    public var body: some View {
        HStack(spacing: 2) {
            LabelWithColon(text: L10n.Message.Preview.draft, weight: .semibold, trailingSpace: true)
                .font(fonts.subheadline)
                .foregroundColor(Color(colors.accentPrimary))
            SubtitleText(text: draftMessageText)
        }
    }
}

/// Deleted message preview variant for the channel list item: an optional
/// "You:" prefix when the deleted message was sent by the current user,
/// followed by a "nosign" icon and the deleted placeholder text.
public struct ChannelItemDeletedPreviewView: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens

    /// Whether the deleted preview message was sent by the current user.
    public let isPreviewMessageSentByCurrentUser: Bool

    public init(isPreviewMessageSentByCurrentUser: Bool) {
        self.isPreviewMessageSentByCurrentUser = isPreviewMessageSentByCurrentUser
    }

    public var body: some View {
        HStack(spacing: tokens.spacingXxs) {
            if isPreviewMessageSentByCurrentUser {
                LabelWithColon(text: L10n.Channel.Item.you, weight: .semibold)
                    .font(fonts.subheadline)
            }
            Image(systemName: "nosign")
                .resizable()
                .scaledToFit()
                .frame(width: tokens.iconSizeSm, height: tokens.iconSizeSm)
                .accessibilityHidden(true)
            Text(L10n.Message.deletedMessagePlaceholder)
        }
        .lineLimit(1)
        .font(fonts.subheadline)
        .foregroundColor(Color(colors.textTertiary))
    }
}

/// Author-prefixed message preview variant for the channel list item:
/// "Author:" followed by an optional attachment icon and the preview content
/// text.
public struct ChannelItemAuthorPreviewView: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens

    /// The author name shown before the preview content.
    public let messagePreviewAuthorName: String
    /// The preview message content text.
    public let previewContentText: String
    /// The icon image for the preview message attachment, when present.
    public let previewAttachmentIconImage: UIImage?

    public init(
        messagePreviewAuthorName: String,
        previewContentText: String,
        previewAttachmentIconImage: UIImage?
    ) {
        self.messagePreviewAuthorName = messagePreviewAuthorName
        self.previewContentText = previewContentText
        self.previewAttachmentIconImage = previewAttachmentIconImage
    }

    public var body: some View {
        HStack(spacing: tokens.spacingXxs) {
            LabelWithColon(text: messagePreviewAuthorName, weight: .semibold)
                .font(fonts.subheadline)
                .foregroundColor(Color(colors.textTertiary))
            ChatChannelListItemAttachmentIcon(image: previewAttachmentIconImage)
            Text(previewContentText)
        }
        .lineLimit(1)
        .font(fonts.subheadline)
        .foregroundColor(Color(colors.textSecondary))
    }
}

/// Attachment-only message preview variant for the channel list item: an
/// attachment icon followed by the preview text (used when there is no author
/// prefix to show).
public struct ChannelItemAttachmentPreviewView: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens

    /// The formatted message preview text shown next to the attachment icon.
    public let messagePreviewText: String
    /// The icon image for the preview message attachment, when present.
    public let previewAttachmentIconImage: UIImage?

    public init(
        messagePreviewText: String,
        previewAttachmentIconImage: UIImage?
    ) {
        self.messagePreviewText = messagePreviewText
        self.previewAttachmentIconImage = previewAttachmentIconImage
    }

    public var body: some View {
        HStack(spacing: tokens.spacingXxs) {
            ChatChannelListItemAttachmentIcon(image: previewAttachmentIconImage)
            Text(messagePreviewText)
        }
        .lineLimit(1)
        .font(fonts.subheadline)
        .foregroundColor(Color(colors.textSecondary))
    }
}

/// The attachment icon used by the channel list item message preview variants
/// that display an attachment glyph before the text.
public struct ChatChannelListItemAttachmentIcon: View {
    @Injected(\.tokens) private var tokens

    /// The image to render as the attachment icon. Renders nothing when `nil`.
    public let image: UIImage?

    public init(image: UIImage?) {
        self.image = image
    }

    @ViewBuilder
    public var body: some View {
        if let image {
            Image(uiImage: image)
                .customizable()
                .frame(width: tokens.iconSizeSm, height: tokens.iconSizeSm)
                .accessibilityHidden(true)
        }
    }
}

/// A label followed by a colon (and optional trailing space). Used as the
/// author / draft / "You" prefix inside the message preview variants.
private struct LabelWithColon: View {
    let text: String
    let weight: Font.Weight
    let trailingSpace: Bool

    init(text: String, weight: Font.Weight = .regular, trailingSpace: Bool = false) {
        self.text = text
        self.weight = weight
        self.trailingSpace = trailingSpace
    }

    var body: some View {
        HStack(spacing: 0) {
            Text(text).fontWeight(weight)
            Text(verbatim: trailingSpace ? ": " : ":").fontWeight(weight)
        }
    }
}
