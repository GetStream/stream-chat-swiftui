//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

public protocol MessageGrouping {
    
    func group(messages: LazyCachedMapCollection<ChatMessage>) -> [String: [String]]
}

public class DefaultMessageGrouping: MessageGrouping {
    
    @Injected(\.utils) private var utils
    
    public init() { /* Public init */ }
    
    public func group(messages: LazyCachedMapCollection<ChatMessage>) -> [String: [String]] {
        var temp = [String: [String]]()
        let notGrouped = "notGrouped"
        for (index, message) in messages.enumerated() {
            let date = message.createdAt
            if index == 0 {
                // not grouped
                temp[message.id] = [notGrouped]
                continue
            }
            
            let previous = index - 1
            let previousMessage = messages[previous]
            let currentAuthorId = messageCachingUtils.authorId(for: message)
            let previousAuthorId = messageCachingUtils.authorId(for: previousMessage)
            
            if currentAuthorId != previousAuthorId {
                // not grouped
                temp[message.id] = [notGrouped]
                continue
            }
            
            if previousMessage.type == .error
                || previousMessage.type == .ephemeral
                || previousMessage.type == .system {
                // not grouped
                temp[message.id] = [notGrouped]
                continue
            }
            
            let delay = previousMessage.createdAt.timeIntervalSince(date)
            
            if delay > 60 {
                // not grouped
                temp[message.id] = [notGrouped]
            }
        }

        return temp
    }
    
    private var messagesDateFormatter: DateFormatter {
        utils.dateFormatter
    }
    
    private var messageCachingUtils: MessageCachingUtils {
        utils.messageCachingUtils
    }
}
