//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

class MessageCachingUtils {
    
    private var messageAuthorMapping = [String: UserDisplayInfo]()
    private var messageAttachments = [String: Bool]()
    private var checkedMessageIds = Set<String>()
    private var quotedMessageMapping = [String: ChatMessage]()
    
    func authorId(for message: ChatMessage) -> String {
        if let userDisplayInfo = messageAuthorMapping[message.id] {
            return userDisplayInfo.id
        }
        
        let userDisplayInfo = saveUserDisplayInfo(for: message)
        return userDisplayInfo.id
    }
    
    func authorName(for message: ChatMessage) -> String {
        if let userDisplayInfo = messageAuthorMapping[message.id] {
            return userDisplayInfo.name
        }
        
        let userDisplayInfo = saveUserDisplayInfo(for: message)
        return userDisplayInfo.name
    }
    
    func authorImageURL(for message: ChatMessage) -> URL? {
        if let userDisplayInfo = messageAuthorMapping[message.id] {
            return userDisplayInfo.imageURL
        }
        
        let userDisplayInfo = saveUserDisplayInfo(for: message)
        return userDisplayInfo.imageURL
    }
    
    func quotedMessage(for message: ChatMessage) -> ChatMessage? {
        if checkedMessageIds.contains(message.id) {
            return nil
        }
        
        if let quoted = quotedMessageMapping[message.id] {
            return quoted
        }
        
        let quoted = message.quotedMessage
        if quoted == nil {
            checkedMessageIds.insert(message.id)
        } else {
            quotedMessageMapping[message.id] = quoted
        }
        
        return quoted
    }
    
    private func saveUserDisplayInfo(for message: ChatMessage) -> UserDisplayInfo {
        let user = message.author
        let userDisplayInfo = UserDisplayInfo(
            id: user.id,
            name: user.name ?? user.id,
            imageURL: user.imageURL
        )
        messageAuthorMapping[message.id] = userDisplayInfo
        
        return userDisplayInfo
    }
    
    private func checkAttachments(for message: ChatMessage) -> Bool {
        let hasAttachments = !message.attachmentCounts.isEmpty
        messageAttachments[message.id] = hasAttachments
        return hasAttachments
    }
}

struct UserDisplayInfo {
    let id: String
    let name: String
    let imageURL: URL?
}
