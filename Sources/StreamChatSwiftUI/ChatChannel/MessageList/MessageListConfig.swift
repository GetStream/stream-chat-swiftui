//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamChat

/// Configuration for the message list.
public struct MessageListConfig {
    public init(
        messageListType: MessageListType = .messaging,
        typingIndicatorPlacement: TypingIndicatorPlacement = .bottomOverlay,
        groupMessages: Bool = true
    ) {
        self.messageListType = messageListType
        self.typingIndicatorPlacement = typingIndicatorPlacement
        self.groupMessages = groupMessages
    }
    
    let messageListType: MessageListType
    let typingIndicatorPlacement: TypingIndicatorPlacement
    let groupMessages: Bool
}

/// Type of message list. Currently only `messaging` is supported.
public enum MessageListType {
    case messaging
    case team
    case livestream
    case commerce
}
