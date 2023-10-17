//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

class ReactionsIconProvider {
    static var colors: ColorPalette = InjectedValues[\.colors]
    static var images: Images = InjectedValues[\.images]
    
    static func icon(for reaction: MessageReactionType, useLargeIcons: Bool) -> UIImage? {
        if useLargeIcons {
            return images.availableReactions[reaction]?.largeIcon
        } else {
            return images.availableReactions[reaction]?.smallIcon
        }
    }

    static func color(for reaction: MessageReactionType, userReactionIDs: Set<MessageReactionType>) -> Color? {
        let containsUserReaction = userReactionIDs.contains(reaction)
        let color = containsUserReaction ? colors.reactionCurrentUserColor : colors.reactionOtherUserColor

        if let color = color {
            return Color(color)
        } else {
            return nil
        }
    }
}
