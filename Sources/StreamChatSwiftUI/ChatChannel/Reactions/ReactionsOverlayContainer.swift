//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct ReactionsOverlayContainer: View {
    @Injected(\.utils) private var utils
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images

    let message: ChatMessage
    let contentRect: CGRect
    var onReactionTap: (MessageReactionType) -> Void

    init(
        message: ChatMessage,
        contentRect: CGRect,
        onReactionTap: @escaping (MessageReactionType) -> Void
    ) {
        self.message = message
        self.contentRect = contentRect
        self.onReactionTap = onReactionTap
    }

    var body: some View {
        VStack {
            ReactionsHStack(message: message) {
                ReactionsAnimatableView(
                    message: message,
                    useLargeIcons: true,
                    reactions: reactions,
                    onReactionTap: onReactionTap
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
        images.availableReactions.keys
            .map { $0 }
            .sorted(by: utils.sortReactions)
    }

    private var reactionsSize: CGFloat {
        let entrySize = 28
        return CGFloat(reactions.count * entrySize)
    }
}

public extension ChatMessage {

    func reactionOffsetX(
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

    let message: ChatMessage
    var useLargeIcons = false
    var reactions: [MessageReactionType]
    var onReactionTap: (MessageReactionType) -> Void

    @State var animationStates: [CGFloat]

    public init(
        message: ChatMessage,
        useLargeIcons: Bool = false,
        reactions: [MessageReactionType],
        onReactionTap: @escaping (MessageReactionType) -> Void
    ) {
        self.message = message
        self.useLargeIcons = useLargeIcons
        self.reactions = reactions
        self.onReactionTap = onReactionTap
        _animationStates = State(
            initialValue: [CGFloat](repeating: 0, count: reactions.count)
        )
    }

    public var body: some View {
        HStack {
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
        .padding(.all, 6)
        .padding(.horizontal, 4)
        .reactionsBubble(for: message, background: colors.background8)
    }
}

public struct ReactionAnimatableView: View {
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images

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
        if let image = iconProvider(for: reaction) {
            Button {
                onReactionTap(reaction)
            } label: {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(color(for: reaction))
                    .frame(width: useLargeIcons ? 25 : 20, height: useLargeIcons ? 27 : 20)
            }
            .background(reactionSelectedBackgroundColor(for: reaction).cornerRadius(8))
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
        var colors = colors
        guard let color = colors.selectedReactionBackgroundColor else {
            return nil
        }

        let backgroundColor: Color? = userReactionIDs.contains(reaction) ? Color(color) : nil
        return backgroundColor
    }

    private func index(for reaction: MessageReactionType) -> Int? {
        let index = reactions.firstIndex(where: { type in
            type == reaction
        })

        return index
    }

    private func iconProvider(for reaction: MessageReactionType) -> UIImage? {
        if useLargeIcons {
            return images.availableReactions[reaction]?.largeIcon
        } else {
            return images.availableReactions[reaction]?.smallIcon
        }
    }

    private func color(for reaction: MessageReactionType) -> Color? {
        var colors = colors
        let containsUserReaction = userReactionIDs.contains(reaction)
        let color = containsUserReaction ? colors.reactionCurrentUserColor : colors.reactionOtherUserColor

        if let color = color {
            return Color(color)
        } else {
            return nil
        }
    }

    private var userReactionIDs: Set<MessageReactionType> {
        Set(message.currentUserReactions.map(\.type))
    }
}
