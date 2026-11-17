//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChatCommonUI

/// A configuration for scheduled messages.
///
/// - Important: Scheduled messages are disabled by default and need to be requested for your app.
/// See [Enabling scheduled messages](https://getstream.io/chat/docs/ios-swift/scheduled-messages/#enabling-scheduled-messages).
@MainActor public final class ScheduledMessagesConfig {
    /// A formatter that converts the date a scheduled message is sent at to textual representation.
    public var dateFormatter: ScheduledMessageDateFormatter

    /// A formatter that converts the failure of a scheduled message to textual representation.
    public var failureFormatter: ScheduledMessageFailureFormatter

    /// Returns the actions shown in the schedule message sheet, which opens with a long press on the send message button.
    public var supportedScheduleMessageActions: @MainActor (SupportedScheduleMessageActionsOptions) -> [ScheduleMessageAction]

    public init(
        dateFormatter: ScheduledMessageDateFormatter = DefaultScheduledMessageDateFormatter(),
        failureFormatter: ScheduledMessageFailureFormatter = DefaultScheduledMessageFailureFormatter(),
        supportedScheduleMessageActions: @escaping @MainActor (SupportedScheduleMessageActionsOptions) -> [ScheduleMessageAction] = ScheduleMessageAction.defaultActions(for:)
    ) {
        self.dateFormatter = dateFormatter
        self.failureFormatter = failureFormatter
        self.supportedScheduleMessageActions = supportedScheduleMessageActions
    }
}
