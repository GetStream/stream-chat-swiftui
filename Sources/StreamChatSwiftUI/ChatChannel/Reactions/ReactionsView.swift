//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct ReactionsContainer: View {
    @Injected(\.utils) var utils
    let message: ChatMessage
    let reactionsStyle: ReactionsStyle
    let topPlacement: Bool
    var useLargeIcons = false
    var onTapGesture: () -> Void
    var onLongPressGesture: () -> Void

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
                    reactions: reactions
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
            Spacer()
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

    private var reactionsSize: CGFloat {
        let entrySize = 32
        return CGFloat(message.reactionScores.count * entrySize)
    }

    private var offsetX: CGFloat {
        if message.shouldRenderAsJumbomoji, topPlacement {
            return message.isRightAligned ? -16 : 16
        }
        return 0
    }
}

extension ReactionsContainer {
    struct ReactionsView: View {
        @Injected(\.colors) private var colors
        @Injected(\.fonts) private var fonts
        @Injected(\.tokens) private var tokens

        let message: ChatMessage
        let reactionsStyle: ReactionsStyle
        var useLargeIcons = false
        var reactions: [MessageReactionType]
        
        var body: some View {
            HStack(spacing: tokens.spacingXxs) {
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
            .padding(.horizontal, tokens.spacingXs)
            .padding(.vertical, tokens.spacingXxs)
            .reactionsBubble(for: message)
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
                        .padding(.horizontal, tokens.spacingXs)
                        .padding(.vertical, tokens.spacingXxs)
                        .reactionsBubble(for: message)
                        .accessibilityIdentifier("reaction-\(reaction.id)")
                    }
                }
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

        private func reactionCountText(_ count: Int) -> some View {
            Text(verbatim: "\(count)")
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
