//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

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
