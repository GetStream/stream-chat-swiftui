//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Describes which variant the channel list item subtitle should render.
///
/// Built with the provided static factory methods. The underlying representation
/// is intentionally hidden so new variants can be added in the future without
/// breaking source compatibility for clients that switch on it.
///
/// Use ``ChatChannelListItemViewModel/subtitle`` to obtain the default value
/// for a given channel, or construct one of the variants explicitly when
/// customizing the subtitle in a custom view.
public struct ChatChannelListItemSubtitle {
    enum Kind {
        case failedToSend
        case typing(text: String)
        case draft(text: String)
        case deleted(isSentByCurrentUser: Bool)
        case authorPreview(authorName: String, contentText: String, attachmentIcon: UIImage?)
        case attachmentPreview(text: String, attachmentIcon: UIImage?)
        case plain(text: String)
    }

    let kind: Kind

    private init(_ kind: Kind) {
        self.kind = kind
    }

    /// Failed-to-send variant: shown when the last message failed to send.
    public static func failedToSend() -> ChatChannelListItemSubtitle {
        .init(.failedToSend)
    }

    /// Typing-indicator variant: shown while other users in the channel are typing.
    /// The provided text is rendered as-is alongside the animated typing dots.
    public static func typing(text: String) -> ChatChannelListItemSubtitle {
        .init(.typing(text: text))
    }

    /// Draft variant: shown when there is a pending draft message in the channel.
    public static func draft(text: String) -> ChatChannelListItemSubtitle {
        .init(.draft(text: text))
    }

    /// Deleted variant: shown when the preview message has been deleted.
    public static func deleted(isSentByCurrentUser: Bool) -> ChatChannelListItemSubtitle {
        .init(.deleted(isSentByCurrentUser: isSentByCurrentUser))
    }

    /// Author-prefixed preview variant: shown when the author name needs to
    /// precede the message preview (group channels, current user prefix, etc).
    public static func authorPreview(
        authorName: String,
        contentText: String,
        attachmentIcon: UIImage?
    ) -> ChatChannelListItemSubtitle {
        .init(.authorPreview(
            authorName: authorName,
            contentText: contentText,
            attachmentIcon: attachmentIcon
        ))
    }

    /// Attachment-only preview variant: shown when there is no author prefix
    /// but the preview message has an attachment.
    public static func attachmentPreview(
        text: String,
        attachmentIcon: UIImage?
    ) -> ChatChannelListItemSubtitle {
        .init(.attachmentPreview(text: text, attachmentIcon: attachmentIcon))
    }

    /// Plain subtitle text variant: used as the fallback when no other variant applies.
    public static func plain(text: String) -> ChatChannelListItemSubtitle {
        .init(.plain(text: text))
    }
}

/// The subtitle view used by the channel list item.
///
/// Renders one of the channel preview variants described by the provided
/// ``ChatChannelListItemSubtitle`` value. Variants include: failed-to-send,
/// typing, draft, deleted, author-prefixed preview, attachment-only preview,
/// and plain subtitle text.
public struct ChatChannelListItemSubtitleView: View {
    /// The subtitle variant to render.
    public let subtitle: ChatChannelListItemSubtitle

    public init(subtitle: ChatChannelListItemSubtitle) {
        self.subtitle = subtitle
    }

    public var body: some View {
        HStack(spacing: 4) {
            content
        }
        .accessibilityIdentifier("subtitleView")
    }

    @ViewBuilder
    private var content: some View {
        switch subtitle.kind {
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
        case let .authorPreview(authorName, contentText, attachmentIcon):
            ChatChannelListItemAuthorPreviewView(
                subtitleAuthorName: authorName,
                previewContentText: contentText,
                previewAttachmentIconImage: attachmentIcon
            )
        case let .attachmentPreview(text, attachmentIcon):
            ChatChannelListItemAttachmentPreviewView(
                subtitleText: text,
                previewAttachmentIconImage: attachmentIcon
            )
        case let .plain(text):
            SubtitleText(text: text)
        }
    }
}
