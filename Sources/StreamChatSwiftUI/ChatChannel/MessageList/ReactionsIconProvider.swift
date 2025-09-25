//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

class ReactionsIconProvider {
    @MainActor static var colors: ColorPalette = InjectedValues[\.colors]
    @MainActor static var images: Images = InjectedValues[\.images]
    
    @MainActor static func icon(for reaction: MessageReactionType, useLargeIcons: Bool) -> UIImage? {
        if useLargeIcons {
            images.availableReactions[reaction]?.largeIcon
        } else {
            images.availableReactions[reaction]?.smallIcon
        }
    }

    @MainActor static func color(for reaction: MessageReactionType, userReactionIDs: Set<MessageReactionType>) -> Color? {
        let containsUserReaction = userReactionIDs.contains(reaction)
        let color = containsUserReaction ? colors.reactionCurrentUserColor : colors.reactionOtherUserColor

        if let color {
            return Color(color)
        } else {
            return nil
        }
    }
}
