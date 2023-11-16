//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Contains info needed for a modifier to be applied to the message view.
public struct MessageModifierInfo {

    public var message: ChatMessage
    public var isFirst: Bool
    public var injectedBackgroundColor: UIColor?
    public var cornerRadius: CGFloat = 18
    public var forceLeftToRight = false

    public init(
        message: ChatMessage,
        isFirst: Bool,
        injectedBackgroundColor: UIColor? = nil,
        cornerRadius: CGFloat = 18,
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
    @Injected(\.utils) private var utils

    public var message: ChatMessage
    public var isFirst: Bool
    public var injectedBackgroundColor: UIColor?
    public var cornerRadius: CGFloat = 18
    public var forceLeftToRight = false
    public var topPadding: CGFloat = 0
    public var bottomPadding: CGFloat = 0

    public init(
        message: ChatMessage,
        isFirst: Bool,
        injectedBackgroundColor: UIColor? = nil,
        cornerRadius: CGFloat = 18,
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
                    cornerRadius: cornerRadius
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

    /// Returns the bubble background(s) for a given message.
    /// - Parameters:
    ///  - colors: The color pallete.
    ///  - injectedBackgroundColor: If you need a custom background color injected.
    /// - Returns: The background colors (can be many for gradients) for the message cell.
    public func bubbleBackground(colors: ColorPalette, injectedBackgroundColor: UIColor? = nil) -> [Color] {
        if let injectedBackgroundColor = injectedBackgroundColor {
            return [Color(injectedBackgroundColor)]
        }
        var colors = colors
        if isSentByCurrentUser {
            if type == .ephemeral {
                return colors.messageCurrentUserEmphemeralBackground.map { Color($0) }
            } else {
                return colors.messageCurrentUserBackground.map { Color($0) }
            }
        } else {
            return colors.messageOtherUserBackground.map { Color($0) }
        }
    }
}
