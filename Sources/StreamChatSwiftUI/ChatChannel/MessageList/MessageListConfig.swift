//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import CoreGraphics
import StreamChat

/// Configuration for the message list.
public struct MessageListConfig {
    public init(
        messageListType: MessageListType = .messaging,
        typingIndicatorPlacement: TypingIndicatorPlacement = .bottomOverlay,
        groupMessages: Bool = true,
        messageDisplayOptions: MessageDisplayOptions = MessageDisplayOptions(),
        messagePaddings: MessagePaddings = MessagePaddings()
    ) {
        self.messageListType = messageListType
        self.typingIndicatorPlacement = typingIndicatorPlacement
        self.groupMessages = groupMessages
        self.messageDisplayOptions = messageDisplayOptions
        self.messagePaddings = messagePaddings
    }
    
    let messageListType: MessageListType
    let typingIndicatorPlacement: TypingIndicatorPlacement
    let groupMessages: Bool
    let messageDisplayOptions: MessageDisplayOptions
    let messagePaddings: MessagePaddings
}

/// Contains information about the message paddings.
public struct MessagePaddings {
    
    /// Horizontal padding for messages.
    let horizontal: CGFloat
    
    public init(horizontal: CGFloat = 8) {
        self.horizontal = horizontal
    }
}

/// Used to show and hide different helper views around the message.
public struct MessageDisplayOptions {
    
    let showAvatars: Bool
    let showMessageDate: Bool
    
    public init(showAvatars: Bool = true, showMessageDate: Bool = true) {
        self.showAvatars = showAvatars
        self.showMessageDate = showMessageDate
    }
}

/// Type of message list. Currently only `messaging` is supported.
public enum MessageListType {
    case messaging
    case team
    case livestream
    case commerce
}
