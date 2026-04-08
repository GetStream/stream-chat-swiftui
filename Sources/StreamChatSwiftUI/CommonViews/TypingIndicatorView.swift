//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View shown in the message list when other users are typing.
///
/// Displays an ``AvatarStack`` of typing users next to an incoming-style
/// message bubble that contains animated dots.
public struct TypingIndicatorView: View {
    @Injected(\.colors) var colors
    @Injected(\.tokens) var tokens
    @Injected(\.utils) var utils

    let typingUsers: [(url: URL?, initials: String)]
    let totalCount: Int
    let typingText: String

    public init(
        users: [ChatUser],
        typingText: String
    ) {
        self.totalCount = users.count
        self.typingUsers = users.prefix(3).map { ($0.imageURL, UserAvatar.initials(from: $0.name ?? "")) }
        self.typingText = typingText
    }

    public var body: some View {
        HStack(alignment: .bottom, spacing: tokens.spacingXs) {
            AvatarStack(
                avatars: typingUsers,
                totalCount: totalCount,
                size: AvatarSize.medium
            )
            TypingIndicatorDotsView()
                .frame(height: 36)
                .padding(.horizontal, tokens.spacingSm)
                .modifier(
                    BubbleModifier(
                        corners: [.topLeft, .topRight, .bottomRight],
                        backgroundColors: [colors.chatBackgroundIncoming.toColor],
                        borderColor: colors.chatBorderIncoming.toColor,
                        cornerRadius: tokens.messageBubbleRadiusGroupBottom
                    )
                )
        }
        .padding(.vertical, tokens.spacingXs)
        .padding(.horizontal, utils.messageListConfig.messagePaddings.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
        .transition(utils.messageListConfig.messageDisplayOptions.otherUserMessageTransition)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(typingText)
        .accessibilityIdentifier("TypingIndicatorView")
    }
}

/// Standalone animated dots used as a typing indicator.
///
/// Three circles animate with staggered easing to convey an ongoing typing
/// action. Used directly in channel list rows and channel headers where the
/// full avatar + bubble layout is not needed.
public struct TypingIndicatorDotsView: View {
    @Injected(\.tokens) var tokens
    @State private var isTyping = false

    private let animationDuration: CGFloat = 0.75

    public init() { /* Public init */ }

    init(isTyping: Bool) {
        _isTyping = State<Bool>(wrappedValue: isTyping)
    }

    public var body: some View {
        HStack(spacing: tokens.spacingXxs) {
            TypingIndicatorCircle(isTyping: isTyping)
                .animation(
                    .easeOut(duration: animationDuration)
                        .repeatForever(autoreverses: true), value: isTyping
                )
            TypingIndicatorCircle(isTyping: isTyping)
                .animation(
                    .easeInOut(duration: animationDuration)
                        .repeatForever(autoreverses: true), value: isTyping
                )
            TypingIndicatorCircle(isTyping: isTyping)
                .animation(
                    .easeIn(duration: animationDuration)
                        .repeatForever(autoreverses: true), value: isTyping
                )
        }
        .onAppear {
            // NOTE: Delay needed because of a glitch when animated in a navigation bar.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isTyping = true
            }
        }
    }
}

/// Typing indicator shown in the channel header subtitle area.
///
/// Displays animated dots alongside a text description of who is typing.
public struct SubtitleTypingIndicatorView: View {
    @Injected(\.chatClient) private var chatClient

    let channel: ChatChannel

    public init(channel: ChatChannel) {
        self.channel = channel
    }

    public var body: some View {
        HStack {
            TypingIndicatorDotsView()
            SubtitleText(text: channel.typingIndicatorString(currentUserId: chatClient.currentUserId))
        }
    }
}

/// One circle of the typing indicator dots animation.
private struct TypingIndicatorCircle: View {
    @Injected(\.colors) var colors

    private let circleWidth: CGFloat = 5
    private let circleHeight: CGFloat = 5
    private let yOffset: CGFloat = 1.5
    private let minOpacity: CGFloat = 0.25
    private let maxOpacity: CGFloat = 1.0

    var isTyping: Bool

    var body: some View {
        Circle()
            .foregroundColor(colors.chatTextTypingIndicator.toColor)
            .frame(width: circleWidth, height: circleHeight)
            .opacity(isTyping ? maxOpacity : minOpacity)
            .offset(y: isTyping ? yOffset : -yOffset)
    }
}
