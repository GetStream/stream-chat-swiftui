//
// Copyright © 2026 Stream.io Inc. All rights reserved.
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

    func clearCache() {
        log.debug("Clearing cached message data")
        scrollOffset = 0
        messageThreadShown = false
    }
}
