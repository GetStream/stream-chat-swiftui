//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatCommonUI
import SwiftUI

/// Contains info needed for a modifier to be applied to the message view.
public final class MessageModifierInfo {
    public var message: ChatMessage
    public var isFirst: Bool
    public var injectedBackgroundColor: UIColor?
    public var cornerRadius: CGFloat?
    public var forceLeftToRight = false

    public init(
        message: ChatMessage,
        isFirst: Bool,
        injectedBackgroundColor: UIColor? = nil,
        cornerRadius: CGFloat? = nil,
        forceLeftToRight: Bool = false
    ) {
        self.message = message
        self.isFirst = isFirst
        self.injectedBackgroundColor = injectedBackgroundColor
        self.cornerRadius = cornerRadius
        self.forceLeftToRight = forceLeftToRight
    }
}

/// Modifier that enables message bubble container.
public struct MessageBubbleModifier: ViewModifier {
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens
    @Injected(\.utils) private var utils

    public var message: ChatMessage
    public var isFirst: Bool
    public var injectedBackgroundColor: UIColor?
    public var cornerRadius: CGFloat?
    public var forceLeftToRight = false
    public var topPadding: CGFloat = 0
    public var bottomPadding: CGFloat = 0

    public init(
        message: ChatMessage,
        isFirst: Bool,
        injectedBackgroundColor: UIColor? = nil,
        cornerRadius: CGFloat?,
        forceLeftToRight: Bool = false,
        topPadding: CGFloat = 0,
        bottomPadding: CGFloat = 0
    ) {
        self.message = message
        self.isFirst = isFirst
        self.injectedBackgroundColor = injectedBackgroundColor
        self.cornerRadius = cornerRadius
        if utils.messageListConfig.messageListAlignment == .leftAligned {
            self.forceLeftToRight = true
        } else {
            self.forceLeftToRight = forceLeftToRight
        }
        self.topPadding = topPadding
        self.bottomPadding = bottomPadding
    }

    public func body(content: Content) -> some View {
        content
            .modifier(
                BubbleModifier(
                    corners: message.bubbleCorners(
                        isFirst: isFirst,
                        forceLeftToRight: forceLeftToRight
                    ),
                    backgroundColors: message.bubbleBackground(
                        colors: colors,
                        injectedBackgroundColor: injectedBackgroundColor
                    ),
                    borderColor: message.bubbleBorder(colors: colors),
                    cornerRadius: cornerRadius ?? tokens.messageBubbleRadiusGroupBottom
                )
            )
            .padding(.top, topPadding)
            .padding(.bottom, bottomPadding)
    }
}

/// Modifier that enables bubble container.
public struct BubbleModifier: ViewModifier {
    @Injected(\.colors) private var colors

    var corners: UIRectCorner
    var backgroundColors: [Color]
    var borderColor: Color?
    var cornerRadius: CGFloat

    public init(corners: UIRectCorner, backgroundColors: [Color], borderColor: Color? = nil, cornerRadius: CGFloat = 18) {
        self.corners = corners
        self.backgroundColors = backgroundColors
        self.borderColor = borderColor
        self.cornerRadius = cornerRadius
    }

    public func body(content: Content) -> some View {
        content
            .background(background)
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

    @ViewBuilder
    private var background: some View {
        if backgroundColors.count == 1 {
            backgroundColors[0]
        } else if backgroundColors.count > 1 {
            LinearGradient(
                gradient: Gradient(colors: backgroundColors),
                startPoint: .top,
                endPoint: .bottom
            )
        } else {
            Color.clear
        }
    }
}

/// Shape that allows rounding of arbitrary corners.
public struct BubbleBackgroundShape: Shape {
    var cornerRadius: CGFloat
    var corners: UIRectCorner

    public func path(in rect: CGRect) -> Path {
        let radius = min(cornerRadius, min(rect.width, rect.height) / 2)
        let topLeftRadius = corners.contains(.topLeft) ? radius : 0
        let topRightRadius = corners.contains(.topRight) ? radius : 0
        let bottomRightRadius = corners.contains(.bottomRight) ? radius : 0
        let bottomLeftRadius = corners.contains(.bottomLeft) ? radius : 0

        var path = Path()
        path.move(to: CGPoint(x: rect.minX + topLeftRadius, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - topRightRadius, y: rect.minY))
        if topRightRadius > 0 {
            path.addArc(
                center: CGPoint(x: rect.maxX - topRightRadius, y: rect.minY + topRightRadius),
                radius: topRightRadius,
                startAngle: .degrees(-90),
                endAngle: .degrees(0),
                clockwise: false
            )
        } else {
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        }
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomRightRadius))
        if bottomRightRadius > 0 {
            path.addArc(
                center: CGPoint(x: rect.maxX - bottomRightRadius, y: rect.maxY - bottomRightRadius),
                radius: bottomRightRadius,
                startAngle: .degrees(0),
                endAngle: .degrees(90),
                clockwise: false
            )
        } else {
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        }
        path.addLine(to: CGPoint(x: rect.minX + bottomLeftRadius, y: rect.maxY))
        if bottomLeftRadius > 0 {
            path.addArc(
                center: CGPoint(x: rect.minX + bottomLeftRadius, y: rect.maxY - bottomLeftRadius),
                radius: bottomLeftRadius,
                startAngle: .degrees(90),
                endAngle: .degrees(180),
                clockwise: false
            )
        } else {
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        }
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topLeftRadius))
        if topLeftRadius > 0 {
            path.addArc(
                center: CGPoint(x: rect.minX + topLeftRadius, y: rect.minY + topLeftRadius),
                radius: topLeftRadius,
                startAngle: .degrees(180),
                endAngle: .degrees(270),
                clockwise: false
            )
        } else {
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        }
        path.closeSubpath()
        return path
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
                backgroundColors: [background],
                borderColor: borderColor
            )
        )
    }
}

extension ChatMessage {
    /// Returns the default corners that will be rounded by the message bubble modifier.
    /// - Parameters:
    ///  - isFirst: whether the message is first.
    ///  - forceLeftToRight: whether left to right should be forced.
    /// - Returns: the corners to be rounded in the message cell.
    public func bubbleCorners(isFirst: Bool, forceLeftToRight: Bool) -> UIRectCorner {
        if !isFirst {
            return [.topLeft, .topRight, .bottomLeft, .bottomRight]
        }

        if isSentByCurrentUser && !forceLeftToRight {
            return [.topLeft, .topRight, .bottomLeft]
        } else {
            return [.topLeft, .topRight, .bottomRight]
        }
    }
    
    func bubbleBorder(colors: Appearance.ColorPalette) -> Color {
        isSentByCurrentUser ? colors.chatBorderOutgoing.toColor : colors.chatBorderIncoming.toColor
    }

    /// Returns the bubble background(s) for a given message.
    /// - Parameters:
    ///  - colors: The color pallete.
    ///  - injectedBackgroundColor: If you need a custom background color injected.
    /// - Returns: The background colors (can be many for gradients) for the message cell.
    @MainActor public func bubbleBackground(colors: Appearance.ColorPalette, injectedBackgroundColor: UIColor? = nil) -> [Color] {
        if let injectedBackgroundColor {
            return [Color(injectedBackgroundColor)]
        }
        if isSentByCurrentUser {
            if type == .ephemeral {
                return colors.messageCurrentUserEmphemeralBackground.map { Color($0) }
            } else {
                return [colors.chatBackgroundOutgoing.toColor]
            }
        } else {
            return [colors.chatBackgroundIncoming.toColor]
        }
    }
}
