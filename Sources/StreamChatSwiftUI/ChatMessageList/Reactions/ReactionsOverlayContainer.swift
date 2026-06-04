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
            ReactionsAnimatableView(
                message: message,
                useLargeIcons: true,
                reactions: reactions,
                onReactionTap: onReactionTap,
                onMoreReactionsTap: onMoreReactionsTap
            )
        }
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
            .accessibilityLabel(L10n.Message.Reactions.more)
            .accessibilityIdentifier("moreReactions")
        }
        .padding(.leading, tokens.spacingXxs)
        .reactionsBubble(for: message, background: colors.backgroundCoreElevation2)
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
            // VoiceOver announces the whole button as one element: the emoji name,
            // a selected state and a "tap to remove" hint when the current user has
            // already added this reaction. The button trait is already implied.
            .accessibilityLabel(reactionAccessibilityLabel)
            .accessibilityAddTraits(isUserReaction ? .isSelected : [])
            .accessibilityHint(isUserReaction ? L10n.Message.Reactions.tapToRemove : "")
            .accessibilityIdentifier("reaction-\(reaction.rawValue)")
        }
    }

    private func reactionSelectedBackgroundColor(for reaction: MessageReactionType) -> Color? {
        userReactionIDs.contains(reaction) ? Color(colors.backgroundUtilitySelected) : nil
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

    /// Whether the current user has already added this reaction.
    private var isUserReaction: Bool {
        userReactionIDs.contains(reaction)
    }

    /// A spoken label for the reaction, preferring the emoji (VoiceOver reads its
    /// name, e.g. "thumbs up") and falling back to the raw reaction type.
    private var reactionAccessibilityLabel: String {
        if let emoji = images.availableMessagesReactionEmojis[reaction] {
            return emoji
        }
        if let dictionary = images.availableEmojis.first(where: { $0["key"] == reaction.rawValue }),
           let emoji = dictionary["value"] {
            return emoji
        }
        return reaction.rawValue
    }
}

private enum ButtonSize {
    @MainActor static var large: CGFloat = 40
    @MainActor static var medium: CGFloat = 32
    @MainActor static var small: CGFloat = 24
    @MainActor static var extraSmall: CGFloat = 20
}
