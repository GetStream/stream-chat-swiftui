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
/// rendering ``ChatChannelListItemPreviewView`` in a custom layout.
public struct ChatChannelListItemPreview {
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
    public static func failedToSend() -> ChatChannelListItemPreview {
        .init(.failedToSend)
    }

    /// Typing-indicator variant: shown while other users in the channel are typing.
    /// The provided text is rendered as-is alongside the animated typing dots.
    public static func typing(text: String) -> ChatChannelListItemPreview {
        .init(.typing(text: text))
    }

    /// Draft variant: shown when there is a pending draft message in the channel.
    public static func draft(text: String) -> ChatChannelListItemPreview {
        .init(.draft(text: text))
    }

    /// Deleted variant: shown when the preview message has been deleted.
    public static func deleted(isSentByCurrentUser: Bool) -> ChatChannelListItemPreview {
        .init(.deleted(isSentByCurrentUser: isSentByCurrentUser))
    }

    /// Regular message variant: shown when the latest channel activity is a
    /// regular message. The provided ``MessageContent`` controls whether an
    /// author prefix and/or attachment icon are rendered alongside the
    /// preview text.
    public static func message(_ content: MessageContent) -> ChatChannelListItemPreview {
        .init(.message(content))
    }
}

/// The preview view used by the channel list item.
///
/// Renders one of the preview variants described by the provided
/// ``ChatChannelListItemPreview`` value. Variants include: failed-to-send,
/// typing, draft, deleted, and a regular message (with optional author
/// prefix and attachment icon).
public struct ChatChannelListItemPreviewView: View {
    /// The preview variant to render.
    public let preview: ChatChannelListItemPreview

    public init(_ preview: ChatChannelListItemPreview) {
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
            ChatChannelListItemFailedToSendView()
        case let .typing(text):
            SubtitleTypingIndicatorView(text: text)
        case let .draft(text):
            ChatChannelListItemDraftPreviewView(draftMessageText: text)
        case let .deleted(isSentByCurrentUser):
            ChatChannelListItemDeletedPreviewView(
                isPreviewMessageSentByCurrentUser: isSentByCurrentUser
            )
        case let .message(content):
            messageView(for: content)
        }
    }

    @ViewBuilder
    private func messageView(
        for content: ChatChannelListItemPreview.MessageContent
    ) -> some View {
        if let authorName = content.authorName {
            ChatChannelListItemAuthorPreviewView(
                messagePreviewAuthorName: authorName,
                previewContentText: content.text,
                previewAttachmentIconImage: content.attachmentIcon
            )
        } else if let attachmentIcon = content.attachmentIcon {
            ChatChannelListItemAttachmentPreviewView(
                messagePreviewText: content.text,
                previewAttachmentIconImage: attachmentIcon
            )
        } else {
            SubtitleText(text: content.text)
        }
    }
}
