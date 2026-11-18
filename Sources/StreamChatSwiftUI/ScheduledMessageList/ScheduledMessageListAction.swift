//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import UIKit

/// An action of a scheduled message, shown in the sheet which opens when the message is tapped in the list.
public final class ScheduledMessageListAction: Identifiable, Sendable {
    /// The id of the action. The default actions use the ids of ``ScheduledMessageListActionId``.
    public let id: String
    public let title: String
    public let icon: UIImage
    /// A Boolean value indicating whether the action removes something, which shows it in the error color.
    public let isDestructive: Bool
    public let action: @MainActor () -> Void

    public init(
        id: String,
        title: String,
        icon: UIImage,
        destructive: Bool = false,
        action: @escaping @MainActor () -> Void
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        isDestructive = destructive
        self.action = action
    }
}

/// The ids of the default actions of a scheduled message.
public enum ScheduledMessageListActionId {
    public static let copyText = "copy_text_scheduled_message_action"
    public static let delete = "delete_scheduled_message_action"
    public static let sendNow = "send_now_scheduled_message_action"
}

extension ScheduledMessageListAction {
    /// Returns the default actions of a scheduled message: sending it now and deleting it.
    ///
    /// A failed message can only be deleted, and so can a message which quotes a deleted message. The text of
    /// a message whose channel was deleted can be copied as well, unless it has no text.
    @MainActor public static func defaultActions(
        for options: SupportedScheduledMessageListActionsOptions
    ) -> [ScheduledMessageListAction] {
        let images = InjectedValues[\.images]
        let scheduledMessage = options.scheduledMessage
        let delete = ScheduledMessageListAction(
            id: ScheduledMessageListActionId.delete,
            title: L10n.Alert.Actions.delete,
            icon: images.messageActionDelete,
            destructive: true,
            action: options.onDelete
        )
        if scheduledMessage.isChannelDeleted {
            let copyText = ScheduledMessageListAction(
                id: ScheduledMessageListActionId.copyText,
                title: L10n.ScheduledMessages.Actions.copyText,
                icon: images.messageActionCopy,
                action: options.onCopyText
            )
            return scheduledMessage.message.text.isEmpty ? [delete] : [copyText, delete]
        }
        if scheduledMessage.status == .failed || scheduledMessage.quotesDeletedMessage {
            return [delete]
        }
        let sendNow = ScheduledMessageListAction(
            id: ScheduledMessageListActionId.sendNow,
            title: L10n.ScheduledMessages.Actions.sendNow,
            icon: images.composerSend,
            action: options.onSendNow
        )
        return [sendNow, delete]
    }
}
