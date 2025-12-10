//
// Copyright © 2025 Stream.io Inc. All rights reserved.
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
        pageSize: Int = 25,
        messagePopoverEnabled: Bool = true,
        doubleTapOverlayEnabled: Bool = false,
        becomesFirstResponderOnOpen: Bool = false,
        resignsFirstResponderOnScrollDown: Bool = true,
        updateChannelsFromMessageList: Bool = false,
        maxTimeIntervalBetweenMessagesInGroup: TimeInterval = 60,
        cacheSizeOnChatDismiss: Int = 1024 * 1024 * 100,
        iPadSplitViewEnabled: Bool = true,
        scrollingAnchor: UnitPoint = .center,
        showNewMessagesSeparator: Bool = true,
        highlightMessageWhenJumping: Bool = true,
        handleTabBarVisibility: Bool = true,
        messageListAlignment: MessageListAlignment = .standard,
        uniqueReactionsEnabled: Bool = false,
        localLinkDetectionEnabled: Bool = true,
        isMessageEditedLabelEnabled: Bool = true,
        markdownSupportEnabled: Bool = true,
        userBlockingEnabled: Bool = false,
        bouncedMessagesAlertActionsEnabled: Bool = true,
        skipEditedMessageLabel: @escaping (ChatMessage) -> Bool = { _ in false },
        draftMessagesEnabled: Bool = false,
        downloadFileAttachmentsEnabled: Bool = false,
        hidesCommandsOverlayOnMessageListTap: Bool = true,
        hidesAttachmentsPickersOnMessageListTap: Bool = true
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
        self.resignsFirstResponderOnScrollDown = resignsFirstResponderOnScrollDown
        self.updateChannelsFromMessageList = updateChannelsFromMessageList
        self.maxTimeIntervalBetweenMessagesInGroup = maxTimeIntervalBetweenMessagesInGroup
        self.cacheSizeOnChatDismiss = cacheSizeOnChatDismiss
        self.iPadSplitViewEnabled = iPadSplitViewEnabled
        self.scrollingAnchor = scrollingAnchor
        self.showNewMessagesSeparator = showNewMessagesSeparator
        self.highlightMessageWhenJumping = highlightMessageWhenJumping
        self.handleTabBarVisibility = handleTabBarVisibility
        self.messageListAlignment = messageListAlignment
        self.uniqueReactionsEnabled = uniqueReactionsEnabled
        self.localLinkDetectionEnabled = localLinkDetectionEnabled
        self.isMessageEditedLabelEnabled = isMessageEditedLabelEnabled
        self.markdownSupportEnabled = markdownSupportEnabled
        self.userBlockingEnabled = userBlockingEnabled
        self.bouncedMessagesAlertActionsEnabled = bouncedMessagesAlertActionsEnabled
        self.skipEditedMessageLabel = skipEditedMessageLabel
        self.draftMessagesEnabled = draftMessagesEnabled
        self.downloadFileAttachmentsEnabled = downloadFileAttachmentsEnabled
        self.hidesCommandsOverlayOnMessageListTap = hidesCommandsOverlayOnMessageListTap
        self.hidesAttachmentsPickersOnMessageListTap = hidesAttachmentsPickersOnMessageListTap
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
    public let resignsFirstResponderOnScrollDown: Bool
    public let updateChannelsFromMessageList: Bool
    public let maxTimeIntervalBetweenMessagesInGroup: TimeInterval
    public let cacheSizeOnChatDismiss: Int
    public let iPadSplitViewEnabled: Bool
    public let scrollingAnchor: UnitPoint
    public let showNewMessagesSeparator: Bool
    public let handleTabBarVisibility: Bool
    public let messageListAlignment: MessageListAlignment
    public let uniqueReactionsEnabled: Bool
    public let localLinkDetectionEnabled: Bool
    public let isMessageEditedLabelEnabled: Bool
    public let markdownSupportEnabled: Bool
    public let userBlockingEnabled: Bool

    /// A boolean to enable hiding the commands overlay when tapping the message list.
    ///
    /// It is enabled by default.
    public let hidesCommandsOverlayOnMessageListTap: Bool

    /// A boolean to enable hiding the attachments keyboard picker when tapping the message list.
    ///
    /// It is enabled by default.
    public let hidesAttachmentsPickersOnMessageListTap: Bool

    /// A boolean to enable the alert actions for bounced messages.
    ///
    /// By default it is true and the bounced actions are displayed as an alert instead of a context menu.
    public let bouncedMessagesAlertActionsEnabled: Bool

    public let skipEditedMessageLabel: (ChatMessage) -> Bool

    /// A boolean value indicating if draft messages should be enabled.
    ///
    /// If enabled, the SDK will save the message content as a draft when the user navigates away from the composer.
    public let draftMessagesEnabled: Bool

    /// A boolean value that determines if download action is shown for file attachments.
    public let downloadFileAttachmentsEnabled: Bool

    /// Highlights the message background when jumping to a message.
    ///
    /// By default it is enabled and it uses the color from `ColorPalette.messageCellHighlightBackground`.
    public let highlightMessageWhenJumping: Bool
}

/// Contains information about the message paddings.
public struct MessagePaddings {
    /// Horizontal padding for messages.
    public let horizontal: CGFloat
    public let quotedViewPadding: CGFloat
    public let singleBottom: CGFloat
    public let groupBottom: CGFloat

    public init(
        horizontal: CGFloat = 8,
        quotedViewPadding: CGFloat = 8,
        singleBottom: CGFloat = 8,
        groupBottom: CGFloat = 2
    ) {
        self.horizontal = horizontal
        self.quotedViewPadding = quotedViewPadding
        self.singleBottom = singleBottom
        self.groupBottom = groupBottom
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
    public let showAvatars: Bool
    public let showAvatarsInGroups: Bool
    public let showMessageDate: Bool
    public let showAuthorName: Bool
    public let animateChanges: Bool
    public let dateLabelSize: CGFloat
    public let lastInGroupHeaderSize: CGFloat
    public let newMessagesSeparatorSize: CGFloat
    public let minimumSwipeGestureDistance: CGFloat
    public let currentUserMessageTransition: AnyTransition
    public let otherUserMessageTransition: AnyTransition
    public let shouldAnimateReactions: Bool
    public let reactionsPlacement: ReactionsPlacement
    public let showOriginalTranslatedButton: Bool
    public let messageLinkDisplayResolver: (ChatMessage) -> [NSAttributedString.Key: Any]
    public let spacerWidth: (CGFloat) -> CGFloat
    public let reactionsTopPadding: (ChatMessage) -> CGFloat
    public let dateSeparator: (ChatMessage, ChatMessage) -> Date?

    public init(
        showAvatars: Bool = true,
        showAvatarsInGroups: Bool? = nil,
        showMessageDate: Bool = true,
        showAuthorName: Bool = true,
        animateChanges: Bool = true,
        overlayDateLabelSize: CGFloat = 40,
        lastInGroupHeaderSize: CGFloat = 0,
        newMessagesSeparatorSize: CGFloat = 50,
        minimumSwipeGestureDistance: CGFloat = 20,
        currentUserMessageTransition: AnyTransition = .identity,
        otherUserMessageTransition: AnyTransition = .identity,
        shouldAnimateReactions: Bool = true,
        reactionsPlacement: ReactionsPlacement = .top,
        showOriginalTranslatedButton: Bool = false,
        messageLinkDisplayResolver: @escaping (ChatMessage) -> [NSAttributedString.Key: Any] = MessageDisplayOptions
            .defaultLinkDisplay,
        spacerWidth: @escaping (CGFloat) -> CGFloat = MessageDisplayOptions.defaultSpacerWidth,
        reactionsTopPadding: @escaping (ChatMessage) -> CGFloat = MessageDisplayOptions.defaultReactionsTopPadding,
        dateSeparator: @escaping (ChatMessage, ChatMessage) -> Date? = MessageDisplayOptions.defaultDateSeparator
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
        self.lastInGroupHeaderSize = lastInGroupHeaderSize
        self.shouldAnimateReactions = shouldAnimateReactions
        self.spacerWidth = spacerWidth
        self.showAvatarsInGroups = showAvatarsInGroups ?? showAvatars
        self.reactionsTopPadding = reactionsTopPadding
        self.newMessagesSeparatorSize = newMessagesSeparatorSize
        self.dateSeparator = dateSeparator
        self.reactionsPlacement = reactionsPlacement
        self.showOriginalTranslatedButton = showOriginalTranslatedButton
    }

    public func showAvatars(for channel: ChatChannel) -> Bool {
        channel.isDirectMessageChannel ? showAvatars : showAvatarsInGroups
    }
    
    public static func defaultDateSeparator(message: ChatMessage, previous: ChatMessage) -> Date? {
        let isDifferentDay = !Calendar.current.isDate(
            message.createdAt,
            equalTo: previous.createdAt,
            toGranularity: .day
        )
        if isDifferentDay {
            return message.createdAt
        } else {
            return nil
        }
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
            if isIPad && availableWidth > 500 {
                return 2 * availableWidth / 3
            } else {
                return availableWidth / 4
            }
        }
    }
    
    public static var defaultReactionsTopPadding: (ChatMessage) -> CGFloat {
        { _ in 24 }
    }
}

/// Type of message list. Currently only `messaging` is supported.
public enum MessageListType {
    case messaging
    case team
    case livestream
    case commerce
}

public enum ReactionsPlacement {
    case top
    case bottom
}

/// The alignment of the messages in the message list.
public enum MessageListAlignment {
    /// Standard message alignment.
    /// The current user's messages are on the right.
    /// The other users' messages are on the left.
    case standard
    /// Everything is left aligned.
    case leftAligned
}
