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
        messagePaddings: MessagePaddings = MessagePaddings(),
        dateIndicatorPlacement: DateIndicatorPlacement = .overlay,
        pageSize: Int = 50,
        messagePopoverEnabled: Bool = true
    ) {
        self.messageListType = messageListType
        self.typingIndicatorPlacement = typingIndicatorPlacement
        self.groupMessages = groupMessages
        self.messageDisplayOptions = messageDisplayOptions
        self.messagePaddings = messagePaddings
        self.dateIndicatorPlacement = dateIndicatorPlacement
        self.pageSize = pageSize
        self.messagePopoverEnabled = messagePopoverEnabled
    }
    
    let messageListType: MessageListType
    let typingIndicatorPlacement: TypingIndicatorPlacement
    let groupMessages: Bool
    let messageDisplayOptions: MessageDisplayOptions
    let messagePaddings: MessagePaddings
    let dateIndicatorPlacement: DateIndicatorPlacement
    let pageSize: Int
    let messagePopoverEnabled: Bool
}

/// Contains information about the message paddings.
public struct MessagePaddings {
    
    /// Horizontal padding for messages.
    let horizontal: CGFloat
    
    public init(horizontal: CGFloat = 8) {
        self.horizontal = horizontal
    }
}

/// Defines where the date indicator in the message list is placed.
public enum DateIndicatorPlacement {
    case none
    case overlay
    case messageList // Not supported yet.
}

/// Used to show and hide different helper views around the message.
public struct MessageDisplayOptions {
    
    let showAvatars: Bool
    let showMessageDate: Bool
    let animateChanges: Bool
    
    public init(
        showAvatars: Bool = true,
        showMessageDate: Bool = true,
        animateChanges: Bool = true
    ) {
        self.showAvatars = showAvatars
        self.showMessageDate = showMessageDate
        self.animateChanges = animateChanges
    }
}

/// Type of message list. Currently only `messaging` is supported.
public enum MessageListType {
    case messaging
    case team
    case livestream
    case commerce
}
