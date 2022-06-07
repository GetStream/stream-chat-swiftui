//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import CoreGraphics
import StreamChat
import SwiftUI

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
        messagePopoverEnabled: Bool = true,
        doubleTapOverlayEnabled: Bool = false,
        becomesFirstResponderOnOpen: Bool = false,
        updateChannelsFromMessageList: Bool = false,
        maxTimeIntervalBetweenMessagesInGroup: TimeInterval = 60
    ) {
        self.messageListType = messageListType
        self.typingIndicatorPlacement = typingIndicatorPlacement
        self.groupMessages = groupMessages
        self.messageDisplayOptions = messageDisplayOptions
        self.messagePaddings = messagePaddings
        self.dateIndicatorPlacement = dateIndicatorPlacement
        self.pageSize = pageSize
        self.messagePopoverEnabled = messagePopoverEnabled
        self.doubleTapOverlayEnabled = doubleTapOverlayEnabled
        self.becomesFirstResponderOnOpen = becomesFirstResponderOnOpen
        self.updateChannelsFromMessageList = updateChannelsFromMessageList
        self.maxTimeIntervalBetweenMessagesInGroup = maxTimeIntervalBetweenMessagesInGroup
    }
    
    public let messageListType: MessageListType
    public let typingIndicatorPlacement: TypingIndicatorPlacement
    public let groupMessages: Bool
    public let messageDisplayOptions: MessageDisplayOptions
    public let messagePaddings: MessagePaddings
    public let dateIndicatorPlacement: DateIndicatorPlacement
    public let pageSize: Int
    public let messagePopoverEnabled: Bool
    public let doubleTapOverlayEnabled: Bool
    public let becomesFirstResponderOnOpen: Bool
    public let updateChannelsFromMessageList: Bool
    public let maxTimeIntervalBetweenMessagesInGroup: TimeInterval
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
    case messageList
}

/// Used to show and hide different helper views around the message.
public struct MessageDisplayOptions {
        
    let showAvatars: Bool
    let showMessageDate: Bool
    let showAuthorName: Bool
    let animateChanges: Bool
    let dateLabelSize: CGFloat
    let minimumSwipeGestureDistance: CGFloat
    let currentUserMessageTransition: AnyTransition
    let otherUserMessageTransition: AnyTransition
    var messageLinkDisplayResolver: (ChatMessage) -> [NSAttributedString.Key: Any]
    
    public init(
        showAvatars: Bool = true,
        showMessageDate: Bool = true,
        showAuthorName: Bool = true,
        animateChanges: Bool = true,
        overlayDateLabelSize: CGFloat = 40,
        minimumSwipeGestureDistance: CGFloat = 15,
        currentUserMessageTransition: AnyTransition = .identity,
        otherUserMessageTransition: AnyTransition = .identity,
        messageLinkDisplayResolver: @escaping (ChatMessage) -> [NSAttributedString.Key: Any] = MessageDisplayOptions
            .defaultLinkDisplay
    ) {
        self.showAvatars = showAvatars
        self.showAuthorName = showAuthorName
        self.showMessageDate = showMessageDate
        self.animateChanges = animateChanges
        dateLabelSize = overlayDateLabelSize
        self.minimumSwipeGestureDistance = minimumSwipeGestureDistance
        self.currentUserMessageTransition = currentUserMessageTransition
        self.otherUserMessageTransition = otherUserMessageTransition
        self.messageLinkDisplayResolver = messageLinkDisplayResolver
    }
    
    public static var defaultLinkDisplay: (ChatMessage) -> [NSAttributedString.Key: Any] {
        { _ in
            [
                NSAttributedString.Key.foregroundColor: UIColor(InjectedValues[\.colors].tintColor)
            ]
        }
    }
}

/// Type of message list. Currently only `messaging` is supported.
public enum MessageListType {
    case messaging
    case team
    case livestream
    case commerce
}
