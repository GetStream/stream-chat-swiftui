//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Modifier that enables message bubble container.
public struct ReactionsBubbleModifier: ViewModifier {
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens

    var message: ChatMessage

    var borderColor: Color?
    var injectedBackground: UIColor?

    public func body(content: Content) -> some View {
        content
            .background(Color(backgroundColor))
            .overlay(
                BubbleBackgroundShape(
                    cornerRadius: tokens.radiusMax, corners: corners
                )
                .stroke(
                    borderColor ?? Color(colors.reactionBorder),
                    lineWidth: 1.0
                )
            )
            .clipShape(
                BubbleBackgroundShape(
                    cornerRadius: tokens.radiusMax,
                    corners: corners
                )
            )
    }

    private var corners: UIRectCorner {
        [.topLeft, .topRight, .bottomLeft, .bottomRight]
    }

    private var backgroundColor: UIColor {
        if let injectedBackground {
            return injectedBackground
        }

        return colors.reactionBackground
    }
}

extension View {
    public func reactionsBubble(for message: ChatMessage, background: UIColor? = nil) -> some View {
        modifier(ReactionsBubbleModifier(message: message, injectedBackground: background))
    }
}
