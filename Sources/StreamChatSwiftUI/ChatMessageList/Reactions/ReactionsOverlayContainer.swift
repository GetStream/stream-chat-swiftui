//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct ReactionsOverlayContainer: View {
    @Injected(\.utils) private var utils
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images
    @Injected(\.tokens) private var tokens

    let message: ChatMessage
    let contentRect: CGRect
    var onReactionTap: (MessageReactionType) -> Void
    var onMoreReactionsTap: () -> Void

    init(
        message: ChatMessage,
        contentRect: CGRect,
        onReactionTap: @escaping (MessageReactionType) -> Void,
        onMoreReactionsTap: @escaping () -> Void
    ) {
        self.message = message
        self.contentRect = contentRect
        self.onReactionTap = onReactionTap
        self.onMoreReactionsTap = onMoreReactionsTap
    }

    var body: some View {
        VStack {
            ReactionsHStack(message: message) {
                ReactionsAnimatableView(
                    message: message,
                    useLargeIcons: true,
                    reactions: reactions,
                    onReactionTap: onReactionTap,
                    onMoreReactionsTap: onMoreReactionsTap
                )
            }

            Spacer()
        }
        .offset(
            x: message.reactionOffsetX(
                for: contentRect,
                reactionsSize: reactionsSize
            ),
            y: -20
        )
    }

    private var reactions: [MessageReactionType] {
        images.availableMessagesReactionEmojis.keys
            .map(\.self)
            .sorted(by: utils.sortReactions)
    }

    private var reactionsSize: CGFloat {
        let entrySize = ButtonSize.large
        let spacing = tokens.spacingXxxs * CGFloat(max(0, reactions.count - 1))
        return CGFloat(reactions.count + 1) * entrySize + spacing + tokens.spacingXxs
    }
}

public extension ChatMessage {
    @MainActor func reactionOffsetX(
        for contentRect: CGRect,
        availableWidth: CGFloat = UIScreen.main.bounds.width,
        reactionsSize: CGFloat
    ) -> CGFloat {
        if isRightAligned {
            var originX = contentRect.origin.x - reactionsSize / 2
            let total = originX + reactionsSize
            if total > availableWidth {
                originX = availableWidth - reactionsSize
            }
            return -(contentRect.origin.x - originX)
        } else {
            if contentRect.width < reactionsSize {
                return (reactionsSize - contentRect.width) / 2
            }

            let originX = contentRect.origin.x - reactionsSize / 2
            return contentRect.origin.x - originX
        }
    }
}

public struct ReactionsAnimatableView: View {
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images
    @Injected(\.tokens) private var tokens

    let message: ChatMessage
    var useLargeIcons = false
    var reactions: [MessageReactionType]
    var onReactionTap: (MessageReactionType) -> Void
    var onMoreReactionsTap: () -> Void

    @State var animationStates: [CGFloat]

    public init(
        message: ChatMessage,
        useLargeIcons: Bool = false,
        reactions: [MessageReactionType],
        onReactionTap: @escaping (MessageReactionType) -> Void,
        onMoreReactionsTap: @escaping () -> Void
    ) {
        self.message = message
        self.useLargeIcons = useLargeIcons
        self.reactions = reactions
        self.onReactionTap = onReactionTap
        self.onMoreReactionsTap = onMoreReactionsTap
        _animationStates = State(
            initialValue: [CGFloat](repeating: 0, count: reactions.count)
        )
    }

    public var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: tokens.spacingXxxs) {
                ForEach(reactions) { reaction in
                    ReactionAnimatableView(
                        message: message,
                        reaction: reaction,
                        useLargeIcons: useLargeIcons,
                        reactions: reactions,
                        animationStates: $animationStates,
                        onReactionTap: onReactionTap
                    )
                }
            }
            Button {
                onMoreReactionsTap()
            } label: {
                Image(systemName: "plus")
                    .foregroundColor(.primary)
                    .padding(.all, 6)
            }
            .frame(width: ButtonSize.medium, height: ButtonSize.medium)
            .overlay(
                Circle().strokeBorder(Color(colors.buttonSecondaryBorder), lineWidth: 1)
            )
            .padding(tokens.spacingXs)
        }
        .padding(.leading, tokens.spacingXxs)
        .reactionsBubble(for: message, background: colors.background8)
    }
}

public struct ReactionAnimatableView: View {
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images
    @Injected(\.tokens) private var tokens

    let message: ChatMessage
    let reaction: MessageReactionType
    var useLargeIcons = false
    var reactions: [MessageReactionType]
    @Binding var animationStates: [CGFloat]
    var onReactionTap: (MessageReactionType) -> Void

    public init(
        message: ChatMessage,
        reaction: MessageReactionType,
        useLargeIcons: Bool = false,
        reactions: [MessageReactionType],
        animationStates: Binding<[CGFloat]>,
        onReactionTap: @escaping (MessageReactionType) -> Void
    ) {
        self.message = message
        self.reaction = reaction
        self.useLargeIcons = useLargeIcons
        self.reactions = reactions
        _animationStates = animationStates
        self.onReactionTap = onReactionTap
    }

    public var body: some View {
        if let image = ReactionsIconProvider.icon(for: reaction, useLargeIcons: useLargeIcons) {
            Button {
                onReactionTap(reaction)
            } label: {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: useLargeIcons ? 25 : 20, height: useLargeIcons ? 27 : 20)
            }
            .frame(width: ButtonSize.large, height: ButtonSize.large)
            .background(reactionSelectedBackgroundColor(for: reaction)?.clipShape(Circle()))
            .scaleEffect(index(for: reaction) != nil ? animationStates[index(for: reaction)!] : 1)
            .onAppear {
                guard let index = index(for: reaction) else {
                    return
                }

                withAnimation(
                    .interpolatingSpring(
                        stiffness: 170,
                        damping: 8
                    )
                    .delay(0.1 * CGFloat(index + 1))
                ) {
                    animationStates[index] = 1
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("reaction-\(reaction.rawValue)")
        }
    }

    private func reactionSelectedBackgroundColor(for reaction: MessageReactionType) -> Color? {
        userReactionIDs.contains(reaction) ? Color(colors.backgroundCoreSelected) : nil
    }

    private func index(for reaction: MessageReactionType) -> Int? {
        let index = reactions.firstIndex(where: { type in
            type == reaction
        })

        return index
    }

    private var userReactionIDs: Set<MessageReactionType> {
        Set(message.currentUserReactions.map(\.type))
    }
}

private enum ButtonSize {
    @MainActor static var large: CGFloat = 40
    @MainActor static var medium: CGFloat = 32
    @MainActor static var small: CGFloat = 24
    @MainActor static var extraSmall: CGFloat = 20
}
