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
        maxTimeIntervalBetweenMessagesInGroup: TimeInterval = 60,
        cacheSizeOnChatDismiss: Int = 1024 * 1024 * 100
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
        self.cacheSizeOnChatDismiss = cacheSizeOnChatDismiss
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
    public let cacheSizeOnChatDismiss: Int
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
        
    public let showAvatarsInDirectMessages: Bool
    public let showAvatarsInGroups: Bool
    public let showMessageDate: Bool
    public let showAuthorName: Bool
    public let animateChanges: Bool
    public let dateLabelSize: CGFloat
    public let lastInGroupHeaderSize: CGFloat
    public let minimumSwipeGestureDistance: CGFloat
    public let currentUserMessageTransition: AnyTransition
    public let otherUserMessageTransition: AnyTransition
    public let shouldAnimateReactions: Bool
    public let messageLinkDisplayResolver: (ChatMessage) -> [NSAttributedString.Key: Any]
    public let spacerWidth: (CGFloat) -> CGFloat
    
    public init(
        showAvatarsInDirectMessages: Bool = true,
        showAvatarsInGroups: Bool = true,
        showMessageDate: Bool = true,
        showAuthorName: Bool = true,
        animateChanges: Bool = true,
        overlayDateLabelSize: CGFloat = 40,
        lastInGroupHeaderSize: CGFloat = 0,
        minimumSwipeGestureDistance: CGFloat = 10,
        currentUserMessageTransition: AnyTransition = .identity,
        otherUserMessageTransition: AnyTransition = .identity,
        shouldAnimateReactions: Bool = true,
        messageLinkDisplayResolver: @escaping (ChatMessage) -> [NSAttributedString.Key: Any] = MessageDisplayOptions
            .defaultLinkDisplay,
        spacerWidth: @escaping (CGFloat) -> CGFloat = MessageDisplayOptions.defaultSpacerWidth
    ) {
        self.showAvatarsInDirectMessages = showAvatarsInDirectMessages
        self.showAvatarsInGroups = showAvatarsInGroups
        self.showAuthorName = showAuthorName
        self.showMessageDate = showMessageDate
        self.animateChanges = animateChanges
        self.dateLabelSize = overlayDateLabelSize
        self.minimumSwipeGestureDistance = minimumSwipeGestureDistance
        self.currentUserMessageTransition = currentUserMessageTransition
        self.otherUserMessageTransition = otherUserMessageTransition
        self.messageLinkDisplayResolver = messageLinkDisplayResolver
        self.lastInGroupHeaderSize = lastInGroupHeaderSize
        self.shouldAnimateReactions = shouldAnimateReactions
        self.spacerWidth = spacerWidth
    }
    
    public static var defaultLinkDisplay: (ChatMessage) -> [NSAttributedString.Key: Any] {
        { _ in
            [
                NSAttributedString.Key.foregroundColor: UIColor(InjectedValues[\.colors].tintColor)
            ]
        }
    }
    
    public static var defaultSpacerWidth: (CGFloat) -> (CGFloat) {
        { availableWidth in
            if isIPad {
                return 2 * availableWidth / 3
            } else {
                return availableWidth / 4
            }
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
