//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// The preview view used by the channel list item.
///
/// Renders one of the preview variants described by the provided
/// ``ChannelItemPreview`` value. Variants include: failed-to-send,
/// typing, draft, deleted, and a regular message (with optional author
/// prefix and attachment icon).
///
/// The typing variant is always routed through the view factory's
/// ``ViewFactory/makeSubtitleTypingIndicatorView(options:)``, so customers that
/// override that factory method see their custom typing view inside the
/// channel item.
public struct ChannelItemPreviewView<Factory: ViewFactory>: View {
    /// The preview variant to render.
    public let preview: ChannelItemPreview

    private let factory: Factory

    /// Renders the provided preview. The typing variant is routed through
    /// `factory.makeSubtitleTypingIndicatorView(options:)`, so customer
    /// overrides of the factory method are honored. Defaults to
    /// ``DefaultViewFactory``.
    public init(
        factory: Factory = DefaultViewFactory.shared,
        preview: ChannelItemPreview
    ) {
        self.factory = factory
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
        switch preview.content {
        case is ChannelItemPreview.FailedToSendContent:
            ChannelItemFailedToSendView()
        case let typing as ChannelItemPreview.TypingContent:
            factory.makeSubtitleTypingIndicatorView(
                options: SubtitleTypingIndicatorViewOptions(channel: typing.channel)
            )
        case let draft as ChannelItemPreview.DraftContent:
            ChannelItemDraftPreviewView(draftMessageText: draft.text)
        case let deleted as ChannelItemPreview.DeletedContent:
            ChannelItemDeletedPreviewView(
                isPreviewMessageSentByCurrentUser: deleted.isSentByCurrentUser
            )
        case let message as ChannelItemPreview.MessageContent:
            ChannelItemMessagePreviewView(message)
        default:
            EmptyView()
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
    @ScaledMetric(relativeTo: .subheadline) private var iconScale: CGFloat = 1

    public init() {}

    public var body: some View {
        HStack(spacing: tokens.spacingXxs) {
            Image(uiImage: images.messageListErrorIndicator)
                .customizable()
                .frame(width: tokens.iconSizeSm * iconScale, height: tokens.iconSizeSm * iconScale)
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
    @ScaledMetric(relativeTo: .subheadline) private var iconScale: CGFloat = 1

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
                .frame(width: tokens.iconSizeSm * iconScale, height: tokens.iconSizeSm * iconScale)
                .accessibilityHidden(true)
            Text(L10n.Message.deletedMessagePlaceholder)
        }
        .lineLimit(1)
        .font(fonts.subheadline)
        .foregroundColor(Color(colors.textTertiary))
    }
}

/// Regular message preview variant for the channel list item: renders the
/// preview text, optionally prefixed by an "Author:" label and an inline
/// attachment icon.
///
/// Both decorations are optional. Pass a ``ChannelItemPreview/MessageContent``
/// with `authorName` and `attachmentIcon` set to `nil` to render the plain
/// preview text on its own (the shape used for direct message channels
/// without attachments).
public struct ChannelItemMessagePreviewView: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens

    /// The message content to render.
    public let content: ChannelItemPreview.MessageContent

    public init(_ content: ChannelItemPreview.MessageContent) {
        self.content = content
    }

    public var body: some View {
        HStack(spacing: tokens.spacingXxs) {
            if let authorName = content.authorName {
                LabelWithColon(text: authorName, weight: .semibold)
                    .foregroundColor(Color(colors.textTertiary))
            }
            ChannelItemAttachmentIcon(image: content.attachmentIcon)
            Text(content.text)
        }
        .lineLimit(1)
        .font(fonts.subheadline)
        .foregroundColor(Color(colors.textSecondary))
    }
}

/// The attachment icon used by the channel list item message preview variants
/// that display an attachment glyph before the text.
public struct ChannelItemAttachmentIcon: View {
    @Injected(\.tokens) private var tokens
    @ScaledMetric(relativeTo: .subheadline) private var iconScale: CGFloat = 1

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
                .frame(width: tokens.iconSizeSm * iconScale, height: tokens.iconSizeSm * iconScale)
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

// MARK: - ChannelItemPreview

/// Describes which variant the channel list item preview should render.
///
/// The preview is the second line of the row that summarises the channel's
/// latest activity: the most recent message (with author prefix, attachment
/// glyph, or deleted placeholder), a pending draft, a typing indicator, or
/// a "failed to send" status.
///
/// Use ``ChatChannelListItemViewModel/preview`` to obtain the default value
/// for a given channel, or construct one of the variants explicitly when
/// rendering ``ChannelItemPreviewView`` in a custom layout.
public struct ChannelItemPreview: Sendable {
    /// Failed-to-send variant: shown when the last message failed to send.
    public static func failedToSend(_ content: FailedToSendContent) -> ChannelItemPreview {
        .init(content: content)
    }

    /// Typing-indicator variant: shown while other users in the channel are
    /// typing. The provided channel is forwarded to the view factory so
    /// `makeSubtitleTypingIndicatorView(options:)` can derive the typing text
    /// from `channel.currentlyTypingUsers`.
    public static func typing(_ content: TypingContent) -> ChannelItemPreview {
        .init(content: content)
    }

    /// Draft variant: shown when there is a pending draft message in the channel.
    public static func draft(_ content: DraftContent) -> ChannelItemPreview {
        .init(content: content)
    }

    /// Deleted variant: shown when the preview message has been deleted.
    public static func deleted(_ content: DeletedContent) -> ChannelItemPreview {
        .init(content: content)
    }

    /// Regular message variant: shown when the latest channel activity is a
    /// regular message. The provided ``ChannelItemPreview/MessageContent``
    /// controls whether an author prefix and/or attachment icon are rendered
    /// alongside the preview text.
    public static func message(_ content: MessageContent) -> ChannelItemPreview {
        .init(content: content)
    }

    /// The content describing which variant to render.
    public let content: any Content

    /// Wraps the provided content. Use this to render a custom variant by
    /// passing your own ``ChannelItemPreview/Content`` conforming type.
    public init(content: any Content) {
        self.content = content
    }

    /// A type that provides the data for a channel item preview variant.
    ///
    /// The built-in variants are ``ChannelItemPreview/FailedToSendContent``,
    /// ``ChannelItemPreview/TypingContent``, ``ChannelItemPreview/DraftContent``,
    /// ``ChannelItemPreview/DeletedContent`` and ``ChannelItemPreview/MessageContent``.
    /// Conform your own type to render a custom variant: wrap it in a
    /// ``ChannelItemPreview`` via ``ChannelItemPreview/init(content:)`` and match
    /// it (with `as`) in a custom preview view.
    public protocol Content: Sendable {}

    /// The data needed to render the failed-to-send variant.
    ///
    /// Carries no data, but exists so the variant has a value type like the
    /// others and can be matched (with `as`) against ``ChannelItemPreview/content``.
    public struct FailedToSendContent: Content {
        public init() {}
    }

    /// The data needed to render the typing variant.
    public struct TypingContent: Content {
        /// The channel whose typing users drive the indicator text.
        public let channel: ChatChannel

        public init(channel: ChatChannel) {
            self.channel = channel
        }
    }

    /// The data needed to render the draft variant.
    public struct DraftContent: Content {
        /// The formatted draft message text.
        public let text: String

        public init(text: String) {
            self.text = text
        }
    }

    /// The data needed to render the deleted variant.
    public struct DeletedContent: Content {
        /// Whether the deleted message was sent by the current user.
        public let isSentByCurrentUser: Bool

        public init(isSentByCurrentUser: Bool) {
            self.isSentByCurrentUser = isSentByCurrentUser
        }
    }

    /// The data needed to render the regular message variant.
    ///
    /// Renders as an optional leading attachment icon, an optional `Author:`
    /// prefix, and the preview text. Pass `nil` for any decoration you want
    /// to omit.
    public struct MessageContent: Content {
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
}
