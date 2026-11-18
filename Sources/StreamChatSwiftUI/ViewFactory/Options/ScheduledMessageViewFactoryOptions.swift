//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Options for creating the sheet with the actions of a scheduled message.
public final class ScheduledMessageActionsSheetOptions: Sendable {
    /// The scheduled message the actions belong to.
    public let scheduledMessage: ScheduledMessage
    /// Copies the text of the scheduled message.
    public let onCopyText: @MainActor () -> Void
    /// Deletes the scheduled message, after asking for confirmation.
    public let onDelete: @MainActor () -> Void
    /// Opens the sheet for picking a new time. `nil` hides the action, for example when the channel of the message isn't
    /// stored locally, because the sheet needs its config.
    public let onReschedule: (@MainActor () -> Void)?
    /// Sends the scheduled message right away.
    public let onSendNow: @MainActor () -> Void
    /// Dismisses the sheet.
    public let onDismiss: @MainActor () -> Void

    public init(
        scheduledMessage: ScheduledMessage,
        onCopyText: @escaping @MainActor () -> Void,
        onDelete: @escaping @MainActor () -> Void,
        onReschedule: (@MainActor () -> Void)?,
        onSendNow: @escaping @MainActor () -> Void,
        onDismiss: @escaping @MainActor () -> Void
    ) {
        self.scheduledMessage = scheduledMessage
        self.onCopyText = onCopyText
        self.onDelete = onDelete
        self.onReschedule = onReschedule
        self.onSendNow = onSendNow
        self.onDismiss = onDismiss
    }
}

/// Options for creating the empty scheduled messages view.
public final class ScheduledMessageListEmptyViewOptions: Sendable {
    public init() {}
}

/// Options for creating the view shown when loading the scheduled messages failed.
public final class ScheduledMessageListErrorViewOptions: Sendable {
    /// Called when the retry button is tapped.
    public let onRetry: @MainActor () -> Void

    public init(onRetry: @escaping @MainActor () -> Void) {
        self.onRetry = onRetry
    }
}

/// Options for creating the scheduled message list item.
public final class ScheduledMessageListItemOptions: Sendable {
    /// The scheduled message to display.
    public let scheduledMessage: ScheduledMessage
    /// The channel of the scheduled message, when it is known.
    public let channel: ChatChannel?

    public init(scheduledMessage: ScheduledMessage, channel: ChatChannel?) {
        self.scheduledMessage = scheduledMessage
        self.channel = channel
    }
}

/// Options for creating the scheduled message list loading view.
public final class ScheduledMessageListLoadingViewOptions: Sendable {
    public init() {}
}

/// Options for creating the list of actions in the sheet of a scheduled message.
public final class SupportedScheduledMessageListActionsOptions: Sendable {
    /// The scheduled message the actions belong to.
    public let scheduledMessage: ScheduledMessage
    /// Copies the text of the scheduled message.
    public let onCopyText: @MainActor () -> Void
    /// Deletes the scheduled message, after asking for confirmation.
    public let onDelete: @MainActor () -> Void
    /// Opens the sheet for picking a new time. `nil` hides the action, for example when the channel of the message isn't
    /// stored locally, because the sheet needs its config.
    public let onReschedule: (@MainActor () -> Void)?
    /// Sends the scheduled message right away.
    public let onSendNow: @MainActor () -> Void

    public init(
        scheduledMessage: ScheduledMessage,
        onCopyText: @escaping @MainActor () -> Void,
        onDelete: @escaping @MainActor () -> Void,
        onReschedule: (@MainActor () -> Void)?,
        onSendNow: @escaping @MainActor () -> Void
    ) {
        self.scheduledMessage = scheduledMessage
        self.onCopyText = onCopyText
        self.onDelete = onDelete
        self.onReschedule = onReschedule
        self.onSendNow = onSendNow
    }
}
