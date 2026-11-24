//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

enum ScheduleMessageErrorText {
    static func text(for error: Error, config: ChannelConfig, editing: Bool = false) -> String {
        let texts = L10n.Composer.ScheduleMessage.Error.self
        switch error {
        case is ClientError.ScheduledMessageHasACommand:
            return texts.command
        case is ClientError.ScheduledMessageIsTooSoon where editing:
            return texts.tooSoonEdit
        case is ClientError.ScheduledMessageIsTooSoon:
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.day, .hour, .minute]
            formatter.unitsStyle = .full
            return texts.tooSoon(formatter.string(from: config.scheduledMessagesMinLeadTime ?? 60) ?? "")
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
}
