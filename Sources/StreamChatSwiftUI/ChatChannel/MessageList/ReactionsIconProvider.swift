//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatCommonUI
import SwiftUI
import UIKit

class ReactionsIconProvider {
    @MainActor static var colors: Appearance.ColorPalette = InjectedValues[\.colors]
    @MainActor static var images: Appearance.Images = InjectedValues[\.images]
    
    @MainActor static func icon(for reaction: MessageReactionType, useLargeIcons: Bool) -> UIImage? {
        var icon: UIImage?
        if useLargeIcons {
            icon = images.availableReactions[reaction]?.largeIcon
        } else {
            icon = images.availableReactions[reaction]?.smallIcon
        }
        if let icon {
            return icon
        }
        guard let emoji = emojiString(from: reaction.rawValue) else {
            return nil
        }

        return image(from: emoji, useLargeIcons: useLargeIcons)
    }

    @MainActor static func color(for reaction: MessageReactionType, userReactionIDs: Set<MessageReactionType>) -> Color? {
        let containsUserReaction = userReactionIDs.contains(reaction)
        let color = containsUserReaction ? colors.reactionCurrentUserColor : colors.reactionOtherUserColor
        return Color(color)
    }
}

private extension ReactionsIconProvider {
    @MainActor static func emojiString(from identifier: String) -> String? {
        let components = identifier.split(separator: "-")
        guard components.allSatisfy({ $0.lowercased().hasPrefix("u") }) else {
            return nil
        }

        var scalars = String.UnicodeScalarView()
        for component in components {
            let hex = component.drop { $0 == "u" || $0 == "U" }
            guard let value = UInt32(hex, radix: 16), let scalar = UnicodeScalar(value) else {
                return nil
            }
            scalars.append(scalar)
        }

        return String(scalars)
    }

    @MainActor static func image(from emoji: String, useLargeIcons: Bool) -> UIImage? {
        let fontSize: CGFloat = useLargeIcons ? 28 : 22
        let font = UIFont.systemFont(ofSize: fontSize)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let text = emoji as NSString
        var size = text.size(withAttributes: attributes)
        size.width = ceil(size.width)
        size.height = ceil(size.height)

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            UIColor.clear.set()
            text.draw(at: .zero, withAttributes: attributes)
        }
    }
}
