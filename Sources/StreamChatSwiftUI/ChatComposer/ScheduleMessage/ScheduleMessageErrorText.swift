//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

enum ScheduleMessageErrorText {
    static func text(for error: Error, config: ChannelConfig) -> String {
        let texts = L10n.Composer.ScheduleMessage.Error.self
        switch error {
        case is ClientError.ScheduledMessageHasACommand:
            return texts.command
        case is ClientError.ScheduledMessageIsTooFarAhead:
            return texts.tooFar
        case is ClientError.ScheduledMessageQuotesADeletedMessage:
            return texts.quoteDeleted
        case is ClientError.ScheduledMessagesChannelLimitReached:
            return config.scheduledMessagesMaxPerChannel.map { texts.channelLimit($0) } ?? texts.generic
        case is ClientError.ScheduledMessagesUserLimitReached:
            return config.scheduledMessagesMaxPerUser.map { texts.userLimit($0) } ?? texts.generic
        default:
            return texts.generic
        }
    }

    // Scheduling again can't fix these while the sheet is open, because the message and the limits stay the same.
    static func canRetry(_ error: Error) -> Bool {
        switch error {
        case is ClientError.ScheduledMessageHasACommand,
             is ClientError.ScheduledMessageQuotesADeletedMessage,
             is ClientError.ScheduledMessagesChannelLimitReached,
             is ClientError.ScheduledMessagesUserLimitReached:
            false
        default:
            true
        }
    }
}
