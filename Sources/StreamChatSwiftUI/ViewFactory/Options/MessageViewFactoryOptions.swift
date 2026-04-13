//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat
import SwiftUI

// MARK: - Message List Options

/// Options for creating the empty messages view.
public final class EmptyMessagesViewOptions: Sendable {
    /// The channel to display empty state for.
    public let channel: ChatChannel
    
    public init(channel: ChatChannel) {
        self.channel = channel
    }
}

/// Options for creating the message list background.
public final class MessageListBackgroundOptions: Sendable {
    /// Whether the view is in a thread.
    public let isInThread: Bool
    
    public init(isInThread: Bool) {
        self.isInThread = isInThread
    }
}

// MARK: - User Avatar Options

/// Options for creating the message avatar view.
public final class UserAvatarViewOptions: Sendable {
    /// Information about the user to display.
    public let user: ChatUser
    /// The size of the avatar.
    public let size: CGFloat
    /// Whether to show the online presence indicator.
    public let showsIndicator: Bool
    /// Whether to show a circular border around the avatar.
    public let showsBorder: Bool

    public init(
        user: ChatUser,
        size: CGFloat,
        showsIndicator: Bool,
        showsBorder: Bool = true
    ) {
        self.size = size
        self.showsBorder = showsBorder
        self.showsIndicator = showsIndicator
        self.user = user
    }
}

// MARK: - Message Thread Options

/// Options for creating the message thread header view modifier.
public final class MessageThreadHeaderViewModifierOptions: Sendable {
    public init() {}
}

// MARK: - Message Item Options

/// Options for creating the message item view.
public final class MessageItemViewOptions: Sendable {
    /// The channel containing the message.
    public let channel: ChatChannel
    /// The message to display.
    public let message: ChatMessage
    /// The available width for the message.
    public let width: CGFloat?
    /// Optional fixed content width used to preserve an existing message layout.
    public let fixedContentWidth: CGFloat?
    /// Whether to show all message information.
    public let showsAllInfo: Bool
    /// Whether the message is shown as a preview (e.g. in the reactions overlay).
    public let shownAsPreview: Bool
    /// Whether the view is in a thread.
    public let isInThread: Bool
    /// Binding to the currently scrolled message ID.
    public let scrolledId: Binding<String?>
    /// Binding to the quoted message.
    public let quotedMessage: Binding<ChatMessage?>
    /// Callback when the message is long pressed.
    public let onLongPress: @MainActor (MessageDisplayInfo) -> Void
    /// Whether this is the last message.
    public let isLast: Bool
    /// An optional pre-existing view model to reuse instead of creating a new one.
    public let viewModel: MessageViewModel?
    
    public init(
        channel: ChatChannel,
        message: ChatMessage,
        width: CGFloat?,
        fixedContentWidth: CGFloat? = nil,
        showsAllInfo: Bool,
        shownAsPreview: Bool = false,
        isInThread: Bool,
        scrolledId: Binding<String?>,
        quotedMessage: Binding<ChatMessage?>,
        onLongPress: @escaping @MainActor (MessageDisplayInfo) -> Void,
        isLast: Bool,
        viewModel: MessageViewModel? = nil
    ) {
        self.channel = channel
        self.message = message
        self.width = width
        self.fixedContentWidth = fixedContentWidth
        self.showsAllInfo = showsAllInfo
        self.shownAsPreview = shownAsPreview
        self.isInThread = isInThread
        self.scrolledId = scrolledId
        self.quotedMessage = quotedMessage
        self.onLongPress = onLongPress
        self.isLast = isLast
        self.viewModel = viewModel
    }
}

// MARK: - Message Text Options

/// Options for creating the message text view.
public final class MessageTextViewOptions: Sendable {
    /// The message to display.
    public let message: ChatMessage
    /// Whether this is the first message in a group.
    public let isFirst: Bool
    /// The available width for the message.
    public let availableWidth: CGFloat
    /// Binding to the currently scrolled message ID.
    public let scrolledId: Binding<String?>
    /// The resolved text content to display (translated or original, with markdown / link attributes applied).
    public let formattedText: MessageFormattedText

    public init(
        message: ChatMessage,
        formattedText: MessageFormattedText,
        isFirst: Bool,
        availableWidth: CGFloat,
        scrolledId: Binding<String?>
    ) {
        self.message = message
        self.isFirst = isFirst
        self.availableWidth = availableWidth
        self.scrolledId = scrolledId
        self.formattedText = formattedText
    }
}

/// Options for the reusable stream text view.
///
/// Used by ``ViewFactory/makeStreamTextView(options:)`` which is shared
/// across standalone text messages and attachment text captions.
public class StreamTextViewOptions {
    /// The message whose text should be displayed.
    public let message: ChatMessage
    /// The resolved text content to display (translated or original, with markdown / link attributes applied).
    public let formattedText: MessageFormattedText

    public init(message: ChatMessage, formattedText: MessageFormattedText) {
        self.message = message
        self.formattedText = formattedText
    }
}

/// Options for the attachment text caption view shown inside ``MessageAttachmentsView``.
public class AttachmentTextViewOptions {
    /// The message whose text caption should be displayed.
    public let message: ChatMessage
    /// The maximum width available for the text caption.
    public let availableWidth: CGFloat
    /// The resolved text content to display (translated or original, with markdown / link attributes applied).
    public let formattedText: MessageFormattedText

    public init(
        message: ChatMessage,
        formattedText: MessageFormattedText,
        availableWidth: CGFloat
    ) {
        self.message = message
        self.availableWidth = availableWidth
        self.formattedText = formattedText
    }
}

// MARK: - Message Date Options

/// Options for creating the message date view.
public final class MessageDateViewOptions: Sendable {
    /// The message to display the date for.
    public let message: ChatMessage
    /// When true, the `textOnAccent` color is used instead of the default darker text color.
    public let usesInvertedStyle: Bool
    
    public init(message: ChatMessage, usesInvertedStyle: Bool = false) {
        self.message = message
        self.usesInvertedStyle = usesInvertedStyle
    }
}

/// Options for creating the message author and date view.
public final class MessageAuthorAndDateViewOptions: Sendable {
    /// The message to display the author and date for.
    public let message: ChatMessage
    /// When true, the `textOnAccent` color is used instead of the default darker text color.
    public let usesInvertedStyle: Bool
    
    public init(message: ChatMessage, usesInvertedStyle: Bool = false) {
        self.message = message
        self.usesInvertedStyle = usesInvertedStyle
    }
}

/// Options for creating the message annotations stack view.
public final class MessageTopViewOptions: Sendable {
    /// The message to display annotations for.
    public let message: ChatMessage
    /// The channel containing the message.
    public let channel: ChatChannel
    /// The view model for the message.
    public let messageViewModel: MessageViewModel
    /// When true, the `textOnAccent` color is used instead of the default darker text color.
    public let usesInvertedStyle: Bool
    
    public init(
        message: ChatMessage,
        channel: ChatChannel,
        messageViewModel: MessageViewModel,
        usesInvertedStyle: Bool = false
    ) {
        self.message = message
        self.channel = channel
        self.messageViewModel = messageViewModel
        self.usesInvertedStyle = usesInvertedStyle
    }
}

/// Options for creating the last in group header view.
public final class LastInGroupHeaderViewOptions: Sendable {
    /// The message to display the header for.
    public let message: ChatMessage
    
    public init(message: ChatMessage) {
        self.message = message
    }
}

// MARK: - Message Type Options

/// Options for creating the deleted message view.
public final class DeletedMessageViewOptions: Sendable {
    /// The deleted message to display.
    public let message: ChatMessage
    /// Whether this is the first message in a group.
    public let isFirst: Bool
    /// The available width for the message.
    public let availableWidth: CGFloat
    
    public init(message: ChatMessage, isFirst: Bool, availableWidth: CGFloat) {
        self.message = message
        self.isFirst = isFirst
        self.availableWidth = availableWidth
    }
}

/// Options for creating the system message view.
public final class SystemMessageViewOptions: Sendable {
    /// The system message to display.
    public let message: ChatMessage
    
    public init(message: ChatMessage) {
        self.message = message
    }
}

/// Options for creating the emoji text view.
public final class EmojiTextViewOptions: Sendable {
    /// The message containing emojis.
    public let message: ChatMessage
    /// Binding to the currently scrolled message ID.
    public let scrolledId: Binding<String?>
    /// Whether this is the first message in a group.
    public let isFirst: Bool
    
    public init(message: ChatMessage, scrolledId: Binding<String?>, isFirst: Bool) {
        self.message = message
        self.scrolledId = scrolledId
        self.isFirst = isFirst
    }
}

// MARK: - Message Indicator Options

/// Options for creating the scroll to bottom button.
public final class ScrollToBottomButtonOptions: Sendable {
    /// The number of unread messages.
    public let unreadCount: Int
    /// Callback when the scroll to bottom button is tapped.
    public let onScrollToBottom: @MainActor () -> Void
    
    public init(unreadCount: Int, onScrollToBottom: @escaping @MainActor () -> Void) {
        self.unreadCount = unreadCount
        self.onScrollToBottom = onScrollToBottom
    }
}

/// Options for creating the date indicator view.
public final class DateIndicatorViewOptions: Sendable {
    /// The date string to display.
    public let dateString: String
    
    public init(dateString: String) {
        self.dateString = dateString
    }
}

/// Options for creating the message list date indicator.
public final class MessageListDateIndicatorViewOptions: Sendable {
    /// The date to display.
    public let date: Date
    
    public init(date: Date) {
        self.date = date
    }
}

/// Options for creating the typing indicator view.
public final class TypingIndicatorViewOptions: Sendable {
    /// The channel to show typing indicators for.
    public let channel: ChatChannel
    /// The current user ID.
    public let currentUserId: UserId?
    
    public init(channel: ChatChannel, currentUserId: UserId?) {
        self.channel = channel
        self.currentUserId = currentUserId
    }
}

// MARK: - Message Replies Options

/// Options for creating the message replies view.
public final class MessageRepliesViewOptions: Sendable {
    /// The channel containing the message.
    public let channel: ChatChannel
    /// The message to show replies for.
    public let message: ChatMessage
    /// The number of replies.
    public let replyCount: Int
    /// When true, the `textOnAccent` color is used instead of the default darker text color.
    public let usesInvertedStyle: Bool
    
    public init(channel: ChatChannel, message: ChatMessage, replyCount: Int, usesInvertedStyle: Bool = false) {
        self.channel = channel
        self.message = message
        self.replyCount = replyCount
        self.usesInvertedStyle = usesInvertedStyle
    }
}

// MARK: - Message Actions Options

/// Options for getting supported message actions.
public final class SupportedMessageActionsOptions: Sendable {
    /// The message to get actions for.
    public let message: ChatMessage
    /// The channel containing the message.
    public let channel: ChatChannel
    /// Callback when an action is finished.
    public let onFinish: @MainActor (MessageActionInfo) -> Void
    /// Callback when an error occurs.
    public let onError: @MainActor (Error) -> Void
    
    public init(
        message: ChatMessage,
        channel: ChatChannel,
        onFinish: @escaping @MainActor (MessageActionInfo) -> Void,
        onError: @escaping @MainActor (Error) -> Void
    ) {
        self.message = message
        self.channel = channel
        self.onFinish = onFinish
        self.onError = onError
    }
}

/// Options for creating the message actions view.
public final class MessageActionsViewOptions: Sendable {
    /// The message to show actions for.
    public let message: ChatMessage
    /// The channel containing the message.
    public let channel: ChatChannel
    /// Callback when an action is finished.
    public let onFinish: @MainActor (MessageActionInfo) -> Void
    /// Callback when an error occurs.
    public let onError: @MainActor (Error) -> Void
    
    public init(
        message: ChatMessage,
        channel: ChatChannel,
        onFinish: @escaping @MainActor (MessageActionInfo) -> Void,
        onError: @escaping @MainActor (Error) -> Void
    ) {
        self.message = message
        self.channel = channel
        self.onFinish = onFinish
        self.onError = onError
    }
}

// MARK: - Message Read Indicator Options

/// Options for creating the message read indicator view.
public final class MessageReadIndicatorViewOptions: Sendable {
    /// The channel containing the message.
    public let channel: ChatChannel
    /// The message to show read indicators for.
    public let message: ChatMessage
    /// When true, the `textOnAccent` color is used instead of the default darker text color.
    public let usesInvertedStyle: Bool
    
    public init(channel: ChatChannel, message: ChatMessage, usesInvertedStyle: Bool = false) {
        self.channel = channel
        self.message = message
        self.usesInvertedStyle = usesInvertedStyle
    }
}

/// Options for creating the new messages divider view.
public final class NewMessagesDividerViewOptions: Sendable {
    /// Binding to the new messages start ID.
    public let newMessagesStartId: Binding<String?>
    /// The number of new messages.
    public let count: Int
    
    public init(newMessagesStartId: Binding<String?>, count: Int) {
        self.newMessagesStartId = newMessagesStartId
        self.count = count
    }
}

/// Options for creating the thread replies divider view.
public final class ThreadRepliesDividerViewOptions: Sendable {
    /// The number of replies in the thread.
    public let replyCount: Int

    public init(replyCount: Int) {
        self.replyCount = replyCount
    }
}

/// Options for creating the jump to unread button overlay.
public final class JumpToUnreadButtonOptions: Sendable {
    /// Whether the button should be shown.
    public let isShown: Bool
    /// The channel to jump to unread messages in.
    public let channel: ChatChannel
    /// Callback when the jump to message button is tapped.
    public let onJumpToMessage: @MainActor () -> Void
    /// Callback when the close button is tapped.
    public let onClose: @MainActor () -> Void
    
    public init(
        isShown: Bool = true,
        channel: ChatChannel,
        onJumpToMessage: @escaping @MainActor () -> Void,
        onClose: @escaping @MainActor () -> Void
    ) {
        self.isShown = isShown
        self.channel = channel
        self.onJumpToMessage = onJumpToMessage
        self.onClose = onClose
    }
}

// MARK: - Send in Channel Options

/// Options for creating the send in channel view.
public final class SendInChannelViewOptions: Sendable {
    /// Binding to whether to show reply in channel.
    public let showReplyInChannel: Binding<Bool>
    
    public init(showReplyInChannel: Binding<Bool>) {
        self.showReplyInChannel = showReplyInChannel
    }
}
