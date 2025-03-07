//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat
import UIKit

/// Caches messages related data.
/// Cleared on chat channel view dismiss or memory warning.
class MessageCachingUtils {
    var scrollOffset: CGFloat = 0
    var messageThreadShown = false {
        didSet {
            if !messageThreadShown {
                jumpToReplyId = nil
            }
        }
    }
    
    var jumpToReplyId: String?
    var channelTranslationLanguages = [ChannelId: TranslationLanguage?]()
    
    // ChatMessage.adjustedText is used everywhere, but there is no easy way to get the
    // language used in the channel. Therefore, it is cached here.
    func translationLanguage(for cid: ChannelId) -> TranslationLanguage? {
        if let language = channelTranslationLanguages[cid] {
            return language
        }
        let language = InjectedValues[\.chatClient].channelController(for: cid).channel?.membership?.language
        channelTranslationLanguages[cid] = language
        return language
    }

    func clearCache() {
        log.debug("Clearing cached message data")
        channelTranslationLanguages.removeAll()
        scrollOffset = 0
        messageThreadShown = false
    }
}

/// Contains display information for the user.
public struct UserDisplayInfo {
    public let id: String
    public let name: String
    public let imageURL: URL?
    public let role: UserRole?
    public let size: CGSize?

    public init(
        id: String,
        name: String,
        imageURL: URL?,
        role: UserRole? = nil,
        size: CGSize? = nil
    ) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.role = role
        self.size = size
    }
}

extension ChatMessage {

    public var authorDisplayInfo: UserDisplayInfo {
        UserDisplayInfo(
            id: author.id,
            name: author.name ?? author.id,
            imageURL: author.imageURL,
            role: author.userRole
        )
    }

    @available(*, deprecated, message: """
    User display info is not cached anymore and this method returned 
    cached data only. Use `ChatMessage.authorDisplayInfo` instead
    """)
    public func userDisplayInfo(from id: String) -> UserDisplayInfo? {
        nil
    }
}
