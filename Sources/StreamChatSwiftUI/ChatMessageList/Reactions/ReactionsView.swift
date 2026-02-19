//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct ReactionsContainer: View {
    @Injected(\.tokens) private var tokens
    @Injected(\.utils) var utils
    let message: ChatMessage
    let topPlacement: Bool
    var useLargeIcons = false
    var onTapGesture: () -> Void
    var onLongPressGesture: () -> Void

    private let maxVisibleSegmentedReactions = 4

    var body: some View {
        VStack {
            HStack(spacing: 0) {
                if !isLeadingAligned {
                    Spacer(minLength: 0)
                }
                ReactionsView(
                    message: message,
                    reactionsStyle: reactionsStyle,
                    useLargeIcons: useLargeIcons,
                    reactions: visibleReactions,
                    overflowCount: overflowCount
                )
                .onTapGesture {
                    onTapGesture()
                }
                .onLongPressGesture {
                    onLongPressGesture()
                }
                .accessibilityAction {
                    onTapGesture()
                }
                if isLeadingAligned {
                    Spacer(minLength: 0)
                }
            }
            if topPlacement {
                Spacer()
            }
        }
        .offset(
            x: offsetX,
            y: topPlacement ? -19 : 0
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("ReactionsContainer")
    }
    
    var isLeadingAligned: Bool {
        if topPlacement {
            return message.isRightAligned
        } else {
            return !message.isRightAligned
        }
    }

    private var reactions: [MessageReactionType] {
        message.reactionScores.keys.filter { reactionType in
            (message.reactionScores[reactionType] ?? 0) > 0
        }
        .sorted(by: utils.sortReactions)
    }

    private var offsetX: CGFloat {
        if topPlacement {
            return message.isRightAligned ? -tokens.spacingXs : tokens.spacingXs
        }
        return 0
    }
    
    private var reactionsStyle: ReactionsStyle {
        utils.messageListConfig.messageDisplayOptions.reactionsStyle
    }

    // MARK: - Overflow

    private var visibleReactions: [MessageReactionType] {
        guard reactions.count > maxVisibleSegmentedReactions else {
            return reactions
        }
        return Array(reactions.prefix(maxVisibleSegmentedReactions))
    }

    private var overflowCount: Int {
        guard reactions.count > maxVisibleSegmentedReactions else {
            return 0
        }
        return reactions
            .dropFirst(maxVisibleSegmentedReactions)
            .reduce(0) { $0 + (message.reactionCounts[$1] ?? 0) }
    }
}

struct ReactionsView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens
    
    let message: ChatMessage
    let reactionsStyle: ReactionsStyle
    var useLargeIcons = false
    var reactions: [MessageReactionType]
    var overflowCount = 0
    
    var body: some View {
        Group {
            switch reactionsStyle {
            case .clustered:
                clusteredContent
            case .segmented:
                segmentedContent
            }
        }
    }
    
    private var clusteredContent: some View {
        HStack(spacing: tokens.spacingXxs) {
            ForEach(reactions) { reaction in
                if let image = reactionIconImage(for: reaction) {
                    reactionIcon(image: image, reaction: reaction)
                        .accessibilityIdentifier("reaction-\(reaction.id)")
                }
            }
            if message.totalReactionsCount > 1 {
                reactionCountText(message.totalReactionsCount)
            }
        }
        .reactionPill(for: message)
    }
    
    private var segmentedContent: some View {
        HStack(spacing: tokens.spacingXxs) {
            ForEach(reactions) { reaction in
                if let image = reactionIconImage(for: reaction) {
                    HStack {
                        reactionIcon(image: image, reaction: reaction)
                        let count = reactionCount(for: reaction)
                        if count > 1 {
                            reactionCountText(count)
                        }
                    }
                    .reactionPill(for: message)
                    .accessibilityIdentifier("reaction-\(reaction.id)")
                }
            }
            overflowPill
        }
    }

    @ViewBuilder
    private var overflowPill: some View {
        if overflowCount > 0 {
            reactionCountText(overflowCount, prefixed: true)
                .reactionPill(for: message)
                .accessibilityIdentifier("reaction-overflow")
        }
    }
    
    private func reactionIconImage(for reaction: MessageReactionType) -> UIImage? {
        ReactionsIconProvider.icon(for: reaction, useLargeIcons: useLargeIcons)
    }
    
    private func reactionIcon(image: UIImage, reaction: MessageReactionType) -> some View {
        ReactionIcon(
            icon: image,
            color: ReactionsIconProvider.color(
                for: reaction,
                userReactionIDs: userReactionIDs
            )
        )
        .frame(width: useLargeIcons ? 25 : 20, height: useLargeIcons ? 27 : 20)
    }
    
    private func reactionCountText(_ count: Int, prefixed: Bool = false) -> some View {
        Text(verbatim: prefixed ? "+\(count)" : "\(count)")
            .font(fonts.footnoteBold)
            .foregroundColor(colors.reactionText.toColor)
            .fixedSize(horizontal: true, vertical: false)
            .layoutPriority(1)
    }
    
    private func reactionCount(for reaction: MessageReactionType) -> Int {
        message.reactionCounts[reaction] ?? 0
    }
    
    private var userReactionIDs: Set<MessageReactionType> {
        Set(message.currentUserReactions.map(\.type))
    }
}

// MARK: - Reaction Pill Modifier

private struct ReactionPillModifier: ViewModifier {
    @Injected(\.tokens) private var tokens
    let message: ChatMessage

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, tokens.spacingXs)
            .frame(height: 24)
            .reactionsBubble(for: message)
    }
}

private extension View {
    func reactionPill(for message: ChatMessage) -> some View {
        modifier(ReactionPillModifier(message: message))
    }
}

public struct ReactionIcon: View {
    var icon: UIImage
    var color: Color?
    
    public init(icon: UIImage, color: Color? = nil) {
        self.icon = icon
        self.color = color
    }
    
    public var body: some View {
        Image(uiImage: icon)
            .resizable()
            .scaledToFit()
            .foregroundColor(color)
    }
}
