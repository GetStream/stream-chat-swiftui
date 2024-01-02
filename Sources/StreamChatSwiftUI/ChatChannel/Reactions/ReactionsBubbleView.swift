//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Modifier that enables message bubble container.
public struct ReactionsBubbleModifier: ViewModifier {
    @Injected(\.colors) private var colors

    var message: ChatMessage

    var borderColor: Color? = nil
    var injectedBackground: UIColor? = nil

    private let cornerRadius: CGFloat = 18

    public func body(content: Content) -> some View {
        content
            .background(Color(backgroundColor))
            .overlay(
                BubbleBackgroundShape(
                    cornerRadius: cornerRadius, corners: corners
                )
                .stroke(
                    borderColor ?? Color(colors.innerBorder),
                    lineWidth: 1.0
                )
            )
            .clipShape(
                BubbleBackgroundShape(
                    cornerRadius: cornerRadius,
                    corners: corners
                )
            )
    }

    private var corners: UIRectCorner {
        [.topLeft, .topRight, .bottomLeft, .bottomRight]
    }

    private var backgroundColor: UIColor {
        if let injectedBackground = injectedBackground {
            return injectedBackground
        }

        if message.isSentByCurrentUser {
            return colors.background8
        } else {
            return colors.background6
        }
    }
}

extension View {
    public func reactionsBubble(for message: ChatMessage, background: UIColor? = nil) -> some View {
        modifier(ReactionsBubbleModifier(message: message, injectedBackground: background))
    }
}
