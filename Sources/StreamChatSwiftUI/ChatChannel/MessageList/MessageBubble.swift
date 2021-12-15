//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Modifier that enables message bubble container.
public struct MessageBubbleModifier: ViewModifier {
    @Injected(\.colors) private var colors
        
    var message: ChatMessage
    var isFirst: Bool
    var injectedBackgroundColor: UIColor?
    var cornerRadius: CGFloat = 18
    var forceLeftToRight = false
    
    public func body(content: Content) -> some View {
        content
            .modifier(
                BubbleModifier(
                    corners: corners,
                    backgroundColor: Color(backgroundColor),
                    cornerRadius: cornerRadius
                )
            )
    }
    
    private var corners: UIRectCorner {
        if !isFirst {
            return [.topLeft, .topRight, .bottomLeft, .bottomRight]
        }
        
        if message.isSentByCurrentUser && !forceLeftToRight {
            return [.topLeft, .topRight, .bottomLeft]
        } else {
            return [.topLeft, .topRight, .bottomRight]
        }
    }
    
    private var backgroundColor: UIColor {
        if let injectedBackgroundColor = injectedBackgroundColor {
            return injectedBackgroundColor
        }
        
        if message.isSentByCurrentUser {
            if message.type == .ephemeral {
                return colors.background8
            } else {
                return colors.background6
            }
        } else {
            return colors.background8
        }
    }
}

/// Modifier that enables bubble container.
public struct BubbleModifier: ViewModifier {
    @Injected(\.colors) private var colors
    
    var corners: UIRectCorner
    var backgroundColor: Color
    var borderColor: Color? = nil
    var cornerRadius: CGFloat = 18
    
    public func body(content: Content) -> some View {
        content
            .background(backgroundColor)
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
}

/// Shape that allows rounding of arbitrary corners.
public struct BubbleBackgroundShape: Shape {
    var cornerRadius: CGFloat
    var corners: UIRectCorner

    public func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        )
        
        return Path(path.cgPath)
    }
}

extension View {
    /// Applies the message bubble modifier to a view.
    /// - Parameters:
    ///  - message: the chat message.
    ///  - isFirst: whether it's the first message in a group of messages.
    ///  - backgroundColor: optional injected background color.
    public func messageBubble(
        for message: ChatMessage,
        isFirst: Bool,
        backgroundColor: UIColor? = nil,
        cornerRadius: CGFloat = 18,
        forceLeftToRight: Bool = false
    ) -> some View {
        modifier(
            MessageBubbleModifier(
                message: message,
                isFirst: isFirst,
                injectedBackgroundColor: backgroundColor,
                cornerRadius: cornerRadius,
                forceLeftToRight: forceLeftToRight
            )
        )
    }
    
    /// Applies bubble modifier to a view.
    /// - Parameters:
    ///  - background: the bubble's background.
    ///  - corners: which corners to be rounded.
    ///  - borderColor: optional border color.
    public func bubble(
        with background: Color,
        corners: UIRectCorner,
        borderColor: Color? = nil
    ) -> some View {
        modifier(
            BubbleModifier(
                corners: corners,
                backgroundColor: background,
                borderColor: borderColor
            )
        )
    }
}
