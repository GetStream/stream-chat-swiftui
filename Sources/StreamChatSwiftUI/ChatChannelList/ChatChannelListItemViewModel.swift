//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// The view model for the channel list item view.
///
/// It contains the default presentation logic for the channel list item data.
/// Subclass and override the `open` properties to customize what the channel
/// list item displays.
///
/// Derived values that are expensive to compute (message preview formatting,
/// timestamps, the accessibility label) are computed once per instance and
/// cached. This is safe because the view model wraps an immutable channel
/// snapshot; a new instance is created whenever the channel data changes.
/// Overriding an `open` property in a subclass bypasses the corresponding
/// cache entirely.
@MainActor open class ChatChannelListItemViewModel {
    @Injected(\.utils) private var utils
    @Injected(\.chatClient) private var chatClient

    /// The channel represented by this item.
    public let channel: ChatChannel

    public init(channel: ChatChannel, channelName: String) {
        self.channel = channel
        providedChannelName = channelName
    }

    // MARK: - Title row

    /// The display name of the channel.
    ///
    /// The default implementation returns the channel name passed to the
    /// initializer. Subclasses can override this to provide a custom display
    /// name (for example, derived from custom channel data) and may call
    /// `super.channelName` to fall back to the initializer value.
    open var channelName: String { providedChannelName }

    /// The formatted timestamp of the last message in the channel.
    open var timestampText: String {
        cachedTimestampText
    }

    /// The number of unread messages in the channel.
    public var unreadCount: Int {
        channel.unreadCount.messages
    }

    /// A boolean value indicating whether the channel has any unread content.
    public var hasUnread: Bool {
        channel.unreadCount != .noUnread
    }

    /// A boolean value indicating whether the muted icon should be rendered
    /// inline next to the channel name.
    public var showInlineMutedIcon: Bool {
        isMuted && mutedLayoutStyle == .afterChannelName
    }

    /// A boolean value indicating whether the muted icon should be rendered
    /// in the trailing bottom corner of the item.
    public var showMutedTrailingIcon: Bool {
        isMuted && mutedLayoutStyle == .bottomRightCorner
    }

    // MARK: - Read indicator

    /// A boolean value indicating whether the read events indicator should be shown.
    public var showReadEvents: Bool {
        if shouldShowTypingIndicator || lastMessageFailedToSend {
            return false
        }
        if utils.messageListConfig.draftMessagesEnabled && draftMessageText != nil {
            return false
        }
        if let message = previewMessage,
           message.isSentByCurrentUser,
           !message.isDeleted {
            return channel.config.readEventsEnabled
        }
        return false
    }

    /// The users that have read the preview message.
    public var readUsers: [ChatUser] {
        cachedReadUsers
    }

    /// A boolean value indicating whether the read indicator should
    /// show the delivered state.
    public var showDelivered: Bool {
        previewMessage?.deliveryStatus(for: channel) == .delivered
    }

    /// The local message state of the preview message.
    public var previewMessageLocalState: LocalMessageState? {
        previewMessage?.localState
    }

    // MARK: - Preview

    /// The preview variant to render for the channel list item.
    ///
    /// Pass it to ``ChannelItemPreviewView``. The default
    /// implementation picks the first applicable variant in this order of
    /// precedence: failed-to-send, typing, draft, deleted, then a regular
    /// message.
    public var preview: ChannelItemPreview {
        cachedPreview
    }

    /// The text shown in the regular message preview variant.
    ///
    /// When ``messagePreviewAuthorName`` is non-`nil` the view already
    /// renders that author label as a prefix, so this returns just the
    /// formatted content of the preview message to avoid duplicating the
    /// author name. When ``messagePreviewAuthorName`` is `nil` (direct
    /// message channels with two members, poll previews, empty channels)
    /// the formatter is allowed to include its own author prefix where it
    /// makes sense, or falls back to the empty channel placeholder.
    open var messagePreviewText: String {
        cachedMessagePreviewText
    }

    /// The formatted text of the pending draft message in the channel, or
    /// `nil` when no draft exists. Used by ``preview`` to render the `.draft`
    /// variant.
    open var draftMessageText: String? {
        cachedDraftMessageText
    }

    /// The author prefix shown before the message preview text. Returns
    /// `"You"` when the current user sent the latest message, the author's
    /// display name in group channels, and `nil` for direct message channels
    /// with two members and for poll previews.
    open var messagePreviewAuthorName: String? {
        guard let previewMessage,
              previewMessage.poll == nil,
              !(channel.isDirectMessageChannel && channel.memberCount == 2) else {
            return nil
        }
        if previewMessage.isSentByCurrentUser {
            return L10n.Channel.Item.you
        }
        return previewMessage.author.name ?? previewMessage.author.id
    }

    /// The leading attachment glyph for the latest message's first
    /// attachment, or `nil` when the message has no attachments to preview.
    open var previewAttachmentIconImage: UIImage? {
        cachedPreviewAttachmentIconImage
    }

    // MARK: - Accessibility

    /// A combined VoiceOver label that describes the whole channel list item as
    /// a single element: name, conversation type, member count, unread state and
    /// a contextual summary of the latest activity (message, draft or deleted).
    open var accessibilityLabel: String {
        cachedAccessibilityLabel
    }

    private var isDirectMessageChannel: Bool {
        channel.isDirectMessageChannel && channel.memberCount == 2
    }

    private var memberCountText: String {
        L10n.Channel.Item.Accessibility.memberCount(channel.memberCount)
    }

    private var unreadText: String {
        L10n.Channel.Item.Accessibility.unreadCount(unreadCount)
    }

    private var previewAccessibilitySentences: [String] {
        if lastMessageFailedToSend {
            return [L10n.Channel.Item.messageFailedToSend]
        }
        if isDraftMessagesEnabled, let draftText = draftMessageText {
            var sentences = [L10n.Channel.Item.Accessibility.draft(draftText)]
            if !timestampText.isEmpty {
                sentences.append(L10n.Channel.Item.Accessibility.lastMessageTime(timestampText))
            }
            return sentences
        }
        guard let previewMessage else {
            return [L10n.Channel.Item.emptyMessages]
        }
        if previewMessage.isDeleted {
            return [L10n.Message.deletedMessagePlaceholder]
        }
        let sender = previewMessage.isSentByCurrentUser
            ? L10n.Channel.Item.Accessibility.you
            : (previewMessage.author.name ?? previewMessage.author.id)
        let preview = cachedFormattedPreviewMessageContent ?? ""
        if showReadEvents {
            let status = readUsers.isEmpty
                ? L10n.Channel.Item.Accessibility.sent
                : L10n.Channel.Item.Accessibility.sentAndRead
            return [L10n.Channel.Item.Accessibility.lastMessageWithStatus(sender, timestampText, status, preview)]
        }
        return [L10n.Channel.Item.Accessibility.lastMessage(sender, timestampText, preview)]
    }

    // MARK: - Equatable

    /// Determines whether two view model instances represent the same rendered content.
    ///
    /// Used via the `Equatable` conformance so SwiftUI (through `.equatable()`) can skip
    /// re-rendering a channel list item when nothing relevant to its content has changed,
    /// which meaningfully improves scroll performance for large channel lists.
    ///
    /// The default implementation compares the channel and the display name, which is what
    /// the default rendering depends on. If your subclass overrides properties that derive
    /// from additional state, override this method to also compare that state, otherwise
    /// changes to it may not trigger a re-render.
    open func isEqual(to other: ChatChannelListItemViewModel) -> Bool {
        channel == other.channel && channelName == other.channelName
    }

    // MARK: - Private

    private let providedChannelName: String

    private var isMuted: Bool {
        channel.isMuted
    }

    private var mutedLayoutStyle: ChannelItemMutedLayoutStyle {
        utils.channelListConfig.channelItemMutedStyle
    }

    private lazy var previewMessage: ChatMessage? = channel.latestMessages
        .first(where: { $0.type != .ephemeral })

    // MARK: - Cached derived values

    //
    // Rendering a single row reads several of the properties above, and many of
    // them depend on the same expensive building blocks (the preview message
    // lookup, the preview formatter, the timestamp formatter, localized string
    // lookups). Since the channel snapshot is immutable, each value is computed
    // at most once per instance. The lazy initializers call the `open`
    // properties where relevant, so subclass overrides are still honored.

    private lazy var cachedTimestampText: String = {
        guard let lastMessageAt = channel.lastMessageAt else { return "" }
        return utils.messageTimestampFormatter.format(lastMessageAt)
    }()

    private lazy var cachedReadUsers: [ChatUser] = channel.readUsers(
        currentUserId: chatClient.currentUserId,
        message: previewMessage
    )

    private lazy var cachedPreview: ChannelItemPreview = {
        if lastMessageFailedToSend {
            return .failedToSend(.init())
        }
        if shouldShowTypingIndicator {
            return .typing(.init(channel: channel))
        }
        if isDraftMessagesEnabled, let draftText = draftMessageText {
            return .draft(.init(text: draftText))
        }
        if isPreviewMessageDeleted {
            return .deleted(.init(isSentByCurrentUser: isPreviewMessageSentByCurrentUser))
        }
        return .message(
            .init(
                text: messagePreviewText,
                authorName: messagePreviewAuthorName,
                attachmentIcon: previewAttachmentIconImage
            )
        )
    }()

    private lazy var cachedMessagePreviewText: String = {
        guard let previewMessage else { return L10n.Channel.Item.emptyMessages }
        if messagePreviewAuthorName != nil, let content = cachedFormattedPreviewMessageContent {
            return content
        }
        return utils.messagePreviewFormatter.format(previewMessage, in: channel)
    }()

    private lazy var cachedDraftMessageText: String? = {
        guard let draftMessage = channel.draftMessage else { return nil }
        return utils.messagePreviewFormatter.formatContent(for: ChatMessage(draftMessage), in: channel)
    }()

    private lazy var cachedPreviewAttachmentIconImage: UIImage? = {
        guard let message = previewMessage else { return nil }
        let resolver = MessageAttachmentPreviewResolver(message: message)
        guard let previewIcon = resolver.previewIcon else { return nil }
        return utils.messageAttachmentPreviewIconProvider.image(for: previewIcon)
    }()

    /// The formatted content of the preview message, shared between the visible
    /// message preview and the accessibility label so the formatter runs once.
    private lazy var cachedFormattedPreviewMessageContent: String? = previewMessage.map { message in
        utils.messagePreviewFormatter.formatContent(for: message, in: channel)
    }

    private lazy var cachedAccessibilityLabel: String = {
        var sentences: [String] = []

        var header = [channelName]
        if isDirectMessageChannel {
            header.append(L10n.Channel.Item.Accessibility.directMessage)
        } else {
            header.append(L10n.Channel.Item.Accessibility.groupChat)
            header.append(memberCountText)
        }
        sentences.append(header.joined(separator: ", "))

        if isMuted {
            sentences.append(L10n.Channel.Item.Accessibility.muted)
        }

        if hasUnread, unreadCount > 0 {
            sentences.append(unreadText)
        }

        sentences.append(contentsOf: previewAccessibilitySentences)

        return sentences.joined(separator: ". ")
    }()

    private var lastMessageFailedToSend: Bool {
        previewMessage?.localState == .sendingFailed
    }

    private var shouldShowTypingIndicator: Bool {
        !channel.currentlyTypingUsersFiltered(
            currentUserId: chatClient.currentUserId
        ).isEmpty && channel.config.typingEventsEnabled
    }

    private var isDraftMessagesEnabled: Bool {
        utils.messageListConfig.draftMessagesEnabled
    }

    private var isPreviewMessageDeleted: Bool {
        previewMessage?.isDeleted == true
    }

    private var isPreviewMessageSentByCurrentUser: Bool {
        previewMessage?.isSentByCurrentUser == true
    }
}

extension ChatChannelListItemViewModel: @MainActor Equatable {
    public static func == (lhs: ChatChannelListItemViewModel, rhs: ChatChannelListItemViewModel) -> Bool {
        lhs.isEqual(to: rhs)
    }
}
