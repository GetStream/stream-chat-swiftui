//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

class MessageListDateUtils {

    private let messageListConfig: MessageListConfig

    init(messageListConfig: MessageListConfig) {
        self.messageListConfig = messageListConfig
    }

    /// Returns index for a message, only if .messageList date indicator placement is enabled.
    /// - Parameters:
    ///   - message, the message whose index is searched for.
    ///   - messages: the list of messages.
    ///  - Returns: optional index.
    func indexForMessageDate(
        message: ChatMessage,
        in messages: LazyCachedMapCollection<ChatMessage>
    ) -> Int? {
        if messageListConfig.dateIndicatorPlacement != .messageList {
            // Index computation will be done onAppear.
            return nil
        }

        return index(for: message, in: messages)
    }

    /// Returns index for a message, if it exists.
    /// - Parameters:
    ///   - message, the message whose index is searched for.
    ///   - messages: the list of messages.
    ///  - Returns: optional index.
    func index(
        for message: ChatMessage,
        in messages: LazyCachedMapCollection<ChatMessage>
    ) -> Int? {
        let index = messages.firstIndex { msg in
            msg.id == message.id
        }

        return index
    }

    /// Returns whether a date should be presented above a message.
    /// - Parameters:
    ///   - index, the index of a message.
    ///   - messages: the list of messages.
    ///  - Returns: optional date, shown above a message.
    func showMessageDate(
        for index: Int?,
        in messages: LazyCachedMapCollection<ChatMessage>
    ) -> Date? {
        guard let index = index else {
            return nil
        }

        let message = messages[index]
        let previousIndex = index + 1
        if previousIndex < messages.count {
            let previous = messages[previousIndex]
            return messageListConfig
                .messageDisplayOptions
                .dateSeparator(message, previous)
        } else {
            return message.createdAt
        }
    }
}
