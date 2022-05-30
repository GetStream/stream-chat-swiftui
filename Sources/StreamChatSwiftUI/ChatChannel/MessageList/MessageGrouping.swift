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
        for (index, message) in messages.enumerated() {
            let date = message.createdAt
            if index == 0 {
                // not grouped
            }
            
            let previous = index - 1
            let previousMessage = messages[previous]
            let currentAuthorId = messageCachingUtils.authorId(for: message)
            let previousAuthorId = messageCachingUtils.authorId(for: previousMessage)
            
            if currentAuthorId != previousAuthorId {
                // not grouped
            }
            
            if previousMessage.type == .error
                || previousMessage.type == .ephemeral
                || previousMessage.type == .system {
                // not grouped
            }
            
            let delay = previousMessage.createdAt.timeIntervalSince(date)
            
            if delay > 30 {
                // not grouped
            } else {
                // grouped
            }
            
            let dateString = messagesDateFormatter.string(from: message.createdAt)
            let prefix = messageCachingUtils.authorId(for: message)
            let key = "\(prefix)-\(dateString)"
            if temp[key] == nil {
                temp[key] = [message.id]
            } else {
                // check if the previous message is not sent by the same user.
                let previousIndex = index - 1
                if previousIndex >= 0 {
                    let previous = messages[previousIndex]
                    let previousAuthorId = messageCachingUtils.authorId(for: previous)
                    let shouldAddKey = prefix != previousAuthorId
                    if shouldAddKey {
                        temp[key]?.append(message.id)
                    }
                }
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
