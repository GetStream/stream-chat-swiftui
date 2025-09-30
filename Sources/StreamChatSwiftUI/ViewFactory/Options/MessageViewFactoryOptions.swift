//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat
import SwiftUI

// MARK: - Message List Options

/// Options for creating the empty messages view.
public class EmptyMessagesViewOptions {
    /// The channel to display empty state for.
    public let channel: ChatChannel
    /// The color palette to use.
    public let colors: ColorPalette
    
    public init(channel: ChatChannel, colors: ColorPalette) {
        self.channel = channel
        self.colors = colors
    }
}

/// Options for creating the message list background.
public class MessageListBackgroundOptions {
    /// The color palette to use.
    public let colors: ColorPalette
    /// Whether the view is in a thread.
    public let isInThread: Bool
    
    public init(colors: ColorPalette, isInThread: Bool) {
        self.colors = colors
        self.isInThread = isInThread
    }
}

// MARK: - Message Avatar Options

/// Options for creating the message avatar view.
public class MessageAvatarViewOptions {
    /// Information about the user to display.
    public let userDisplayInfo: UserDisplayInfo
    
    public init(userDisplayInfo: UserDisplayInfo) {
        self.userDisplayInfo = userDisplayInfo
    }
}

/// Options for creating the quoted message avatar view.
public class QuotedMessageAvatarViewOptions {
    /// Information about the user to display.
    public let userDisplayInfo: UserDisplayInfo
    /// The size of the avatar.
    public let size: CGSize
    
    public init(userDisplayInfo: UserDisplayInfo, size: CGSize) {
        self.userDisplayInfo = userDisplayInfo
        self.size = size
    }
}

// MARK: - Message Thread Options

/// Options for creating the message thread header view modifier.
public class MessageThreadHeaderViewModifierOptions {
    public init() {}
}

// MARK: - Message Container Options

/// Options for creating the message container view.
public class MessageContainerViewOptions {
    /// The channel containing the message.
    public let channel: ChatChannel
    /// The message to display.
    public let message: ChatMessage
    /// The available width for the message.
    public let width: CGFloat?
    /// Whether to show all message information.
    public let showsAllInfo: Bool
    /// Whether the view is in a thread.
    public let isInThread: Bool
    /// Binding to the currently scrolled message ID.
    public let scrolledId: Binding<String?>
    /// Binding to the quoted message.
    public let quotedMessage: Binding<ChatMessage?>
    /// Callback when the message is long pressed.
    public let onLongPress: @MainActor(MessageDisplayInfo) -> Void
    /// Whether this is the last message.
    public let isLast: Bool
    
    public init(
        channel: ChatChannel,
        message: ChatMessage,
        width: CGFloat?,
        showsAllInfo: Bool,
        isInThread: Bool,
        scrolledId: Binding<String?>,
        quotedMessage: Binding<ChatMessage?>,
        onLongPress: @escaping @MainActor(MessageDisplayInfo) -> Void,
        isLast: Bool
    ) {
        self.channel = channel
        self.message = message
        self.width = width
        self.showsAllInfo = showsAllInfo
        self.isInThread = isInThread
        self.scrolledId = scrolledId
        self.quotedMessage = quotedMessage
        self.onLongPress = onLongPress
        self.isLast = isLast
    }
}

// MARK: - Message Text Options

/// Options for creating the message text view.
public class MessageTextViewOptions {
    /// The message to display.
    public let message: ChatMessage
    /// Whether this is the first message in a group.
    public let isFirst: Bool
    /// The available width for the message.
    public let availableWidth: CGFloat
    /// Binding to the currently scrolled message ID.
    public let scrolledId: Binding<String?>
    
    public init(
        message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat,
        scrolledId: Binding<String?>
    ) {
        self.message = message
        self.isFirst = isFirst
        self.availableWidth = availableWidth
        self.scrolledId = scrolledId
    }
}

// MARK: - Message Date Options

/// Options for creating the message date view.
public class MessageDateViewOptions {
    /// The message to display the date for.
    public let message: ChatMessage
    
    public init(message: ChatMessage) {
        self.message = message
    }
}

/// Options for creating the message author and date view.
public class MessageAuthorAndDateViewOptions {
    /// The message to display the author and date for.
    public let message: ChatMessage
    
    public init(message: ChatMessage) {
        self.message = message
    }
}

/// Options for creating the message translation footer view.
public class MessageTranslationFooterViewOptions {
    /// The view model for the message.
    public let messageViewModel: MessageViewModel
    
    public init(messageViewModel: MessageViewModel) {
        self.messageViewModel = messageViewModel
    }
}

/// Options for creating the last in group header view.
public class LastInGroupHeaderViewOptions {
    /// The message to display the header for.
    public let message: ChatMessage
    
    public init(message: ChatMessage) {
        self.message = message
    }
}

// MARK: - Message Type Options

/// Options for creating the deleted message view.
public class DeletedMessageViewOptions {
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
public class SystemMessageViewOptions {
    /// The system message to display.
    public let message: ChatMessage
    
    public init(message: ChatMessage) {
        self.message = message
    }
}

/// Options for creating the emoji text view.
public class EmojiTextViewOptions {
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
public class ScrollToBottomButtonOptions {
    /// The number of unread messages.
    public let unreadCount: Int
    /// Callback when the scroll to bottom button is tapped.
    public let onScrollToBottom: @MainActor() -> Void
    
    public init(unreadCount: Int, onScrollToBottom: @escaping @MainActor() -> Void) {
        self.unreadCount = unreadCount
        self.onScrollToBottom = onScrollToBottom
    }
}

/// Options for creating the date indicator view.
public class DateIndicatorViewOptions {
    /// The date string to display.
    public let dateString: String
    
    public init(dateString: String) {
        self.dateString = dateString
    }
}

/// Options for creating the message list date indicator.
public class MessageListDateIndicatorViewOptions {
    /// The date to display.
    public let date: Date
    
    public init(date: Date) {
        self.date = date
    }
}

/// Options for creating the typing indicator bottom view.
public class TypingIndicatorBottomViewOptions {
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
public class MessageRepliesViewOptions {
    /// The channel containing the message.
    public let channel: ChatChannel
    /// The message to show replies for.
    public let message: ChatMessage
    /// The number of replies.
    public let replyCount: Int
    
    public init(channel: ChatChannel, message: ChatMessage, replyCount: Int) {
        self.channel = channel
        self.message = message
        self.replyCount = replyCount
    }
}

/// Options for creating the message replies shown in channel view.
public class MessageRepliesShownInChannelViewOptions {
    /// The channel containing the message.
    public let channel: ChatChannel
    /// The message to show replies for.
    public let message: ChatMessage
    /// The parent message.
    public let parentMessage: ChatMessage
    /// The number of replies.
    public let replyCount: Int
    
    public init(
        channel: ChatChannel,
        message: ChatMessage,
        parentMessage: ChatMessage,
        replyCount: Int
    ) {
        self.channel = channel
        self.message = message
        self.parentMessage = parentMessage
        self.replyCount = replyCount
    }
}

// MARK: - Message Actions Options

/// Options for getting supported message actions.
public class SupportedMessageActionsOptions {
    /// The message to get actions for.
    public let message: ChatMessage
    /// The channel containing the message.
    public let channel: ChatChannel
    /// Callback when an action is finished.
    public let onFinish: @MainActor(MessageActionInfo) -> Void
    /// Callback when an error occurs.
    public let onError: @MainActor(Error) -> Void
    
    public init(
        message: ChatMessage,
        channel: ChatChannel,
        onFinish: @escaping @MainActor(MessageActionInfo) -> Void,
        onError: @escaping @MainActor(Error) -> Void
    ) {
        self.message = message
        self.channel = channel
        self.onFinish = onFinish
        self.onError = onError
    }
}

/// Options for creating the message actions view.
public class MessageActionsViewOptions {
    /// The message to show actions for.
    public let message: ChatMessage
    /// The channel containing the message.
    public let channel: ChatChannel
    /// Callback when an action is finished.
    public let onFinish: @MainActor(MessageActionInfo) -> Void
    /// Callback when an error occurs.
    public let onError: @MainActor(Error) -> Void
    
    public init(
        message: ChatMessage,
        channel: ChatChannel,
        onFinish: @escaping @MainActor(MessageActionInfo) -> Void,
        onError: @escaping @MainActor(Error) -> Void
    ) {
        self.message = message
        self.channel = channel
        self.onFinish = onFinish
        self.onError = onError
    }
}

// MARK: - Message Read Indicator Options

/// Options for creating the message read indicator view.
public class MessageReadIndicatorViewOptions {
    /// The channel containing the message.
    public let channel: ChatChannel
    /// The message to show read indicators for.
    public let message: ChatMessage
    
    public init(channel: ChatChannel, message: ChatMessage) {
        self.channel = channel
        self.message = message
    }
}

/// Options for creating the new messages indicator view.
public class NewMessagesIndicatorViewOptions {
    /// Binding to the new messages start ID.
    public let newMessagesStartId: Binding<String?>
    /// The number of new messages.
    public let count: Int
    
    public init(newMessagesStartId: Binding<String?>, count: Int) {
        self.newMessagesStartId = newMessagesStartId
        self.count = count
    }
}

/// Options for creating the jump to unread button.
public class JumpToUnreadButtonOptions {
    /// The channel to jump to unread messages in.
    public let channel: ChatChannel
    /// Callback when the jump to message button is tapped.
    public let onJumpToMessage: @MainActor() -> Void
    /// Callback when the close button is tapped.
    public let onClose: @MainActor() -> Void
    
    public init(
        channel: ChatChannel,
        onJumpToMessage: @escaping @MainActor() -> Void,
        onClose: @escaping @MainActor() -> Void
    ) {
        self.channel = channel
        self.onJumpToMessage = onJumpToMessage
        self.onClose = onClose
    }
}

// MARK: - Send in Channel Options

/// Options for creating the send in channel view.
public class SendInChannelViewOptions {
    /// Binding to whether to show reply in channel.
    public let showReplyInChannel: Binding<Bool>
    /// Whether this is a direct message.
    public let isDirectMessage: Bool
    
    public init(showReplyInChannel: Binding<Bool>, isDirectMessage: Bool) {
        self.showReplyInChannel = showReplyInChannel
        self.isDirectMessage = isDirectMessage
    }
}
