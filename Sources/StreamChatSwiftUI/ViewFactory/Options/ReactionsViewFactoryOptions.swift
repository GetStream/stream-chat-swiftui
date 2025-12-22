//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat
import SwiftUI

// MARK: - Reactions Options

/// Options for creating the reactions users view.
public final class ReactionsUsersViewOptions: Sendable {
    /// The message to show reactions for.
    public let message: ChatMessage
    /// The maximum height for the view.
    public let maxHeight: CGFloat
    
    public init(message: ChatMessage, maxHeight: CGFloat) {
        self.message = message
        self.maxHeight = maxHeight
    }
}

/// Options for creating the bottom reactions view.
public final class ReactionsBottomViewOptions: Sendable {
    /// The message to show reactions for.
    public let message: ChatMessage
    /// Whether to show all information.
    public let showsAllInfo: Bool
    /// Callback when the reactions are tapped.
    public let onTap: @MainActor () -> Void
    /// Callback when the reactions are long pressed.
    public let onLongPress: @MainActor () -> Void
    
    public init(
        message: ChatMessage,
        showsAllInfo: Bool,
        onTap: @escaping @MainActor () -> Void,
        onLongPress: @escaping @MainActor () -> Void
    ) {
        self.message = message
        self.showsAllInfo = showsAllInfo
        self.onTap = onTap
        self.onLongPress = onLongPress
    }
}

/// Options for creating the message reaction view.
public final class MessageReactionViewOptions: Sendable {
    /// The message to show reactions for.
    public let message: ChatMessage
    /// Callback when the reaction is tapped.
    public let onTapGesture: @MainActor () -> Void
    /// Callback when the reaction is long pressed.
    public let onLongPressGesture: @MainActor () -> Void
    
    public init(
        message: ChatMessage,
        onTapGesture: @escaping @MainActor () -> Void,
        onLongPressGesture: @escaping @MainActor () -> Void
    ) {
        self.message = message
        self.onTapGesture = onTapGesture
        self.onLongPressGesture = onLongPressGesture
    }
}

/// Options for creating the reactions overlay view.
public final class ReactionsOverlayViewOptions: Sendable {
    /// The channel containing the message.
    public let channel: ChatChannel
    /// The current snapshot image.
    public let currentSnapshot: UIImage
    /// Information about the message display.
    public let messageDisplayInfo: MessageDisplayInfo
    /// Callback when the background is tapped.
    public let onBackgroundTap: @MainActor () -> Void
    /// Callback when an action is executed.
    public let onActionExecuted: @MainActor (MessageActionInfo) -> Void
    
    public init(
        channel: ChatChannel,
        currentSnapshot: UIImage,
        messageDisplayInfo: MessageDisplayInfo,
        onBackgroundTap: @escaping @MainActor () -> Void,
        onActionExecuted: @escaping @MainActor (MessageActionInfo) -> Void
    ) {
        self.channel = channel
        self.currentSnapshot = currentSnapshot
        self.messageDisplayInfo = messageDisplayInfo
        self.onBackgroundTap = onBackgroundTap
        self.onActionExecuted = onActionExecuted
    }
}

/// Options for creating the reactions background view.
public final class ReactionsBackgroundOptions: Sendable {
    /// The current snapshot image.
    public let currentSnapshot: UIImage
    /// Whether the pop-in animation is in progress.
    public let popInAnimationInProgress: Bool
    
    public init(currentSnapshot: UIImage, popInAnimationInProgress: Bool) {
        self.currentSnapshot = currentSnapshot
        self.popInAnimationInProgress = popInAnimationInProgress
    }
}

/// Options for creating the reactions content view.
public final class ReactionsContentViewOptions: Sendable {
    /// The message to show reactions for.
    public let message: ChatMessage
    /// The content rectangle.
    public let contentRect: CGRect
    /// Callback when a reaction is tapped.
    public let onReactionTap: @MainActor (MessageReactionType) -> Void
    /// Callback when the more reactions button is tapped.
    public let onMoreReactionsTap: @MainActor () -> Void
    
    public init(
        message: ChatMessage,
        contentRect: CGRect,
        onReactionTap: @escaping @MainActor (MessageReactionType) -> Void,
        onMoreReactionsTap: @escaping @MainActor () -> Void
    ) {
        self.message = message
        self.contentRect = contentRect
        self.onReactionTap = onReactionTap
        self.onMoreReactionsTap = onMoreReactionsTap
    }
}
