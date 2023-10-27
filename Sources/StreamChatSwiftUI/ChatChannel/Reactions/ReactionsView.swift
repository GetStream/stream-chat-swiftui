//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct ReactionsContainer: View {
    @Injected(\.utils) var utils
    let message: ChatMessage
    var useLargeIcons = false
    var onTapGesture: () -> Void
    var onLongPressGesture: () -> Void

    var body: some View {
        VStack {
            ReactionsHStack(message: message) {
                ReactionsView(
                    message: message,
                    useLargeIcons: useLargeIcons,
                    reactions: reactions
                ) { _ in
                    log.debug("tapped on reaction")
                }
                .onTapGesture {
                    onTapGesture()
                }
                .onLongPressGesture {
                    onLongPressGesture()
                }
            }

            Spacer()
        }
        .offset(
            x: offsetX,
            y: -20
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("ReactionsContainer")
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
        var offset = reactionsSize / 3
        if message.reactionScores.count == 1 {
            offset = 16
        }
        return message.isRightAligned ? -offset : offset
    }
}

struct ReactionsView: View {
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images

    let message: ChatMessage
    var useLargeIcons = false
    var reactions: [MessageReactionType]
    var onReactionTap: (MessageReactionType) -> Void

    var body: some View {
        HStack {
            ForEach(reactions) { reaction in
                if let image = ReactionsIconProvider.icon(for: reaction, useLargeIcons: useLargeIcons) {
                    ReactionIcon(
                        icon: image,
                        color: ReactionsIconProvider.color(
                            for: reaction,
                            userReactionIDs: userReactionIDs
                        )
                    )
                    .frame(width: useLargeIcons ? 25 : 20, height: useLargeIcons ? 27 : 20)
                    .gesture(
                        useLargeIcons ?
                            TapGesture().onEnded {
                                onReactionTap(reaction)
                            } : nil
                    )
                    .accessibilityIdentifier("reaction-\(reaction.id)")
                }
            }
        }
        .padding(.all, 6)
        .reactionsBubble(for: message)
    }

    private var userReactionIDs: Set<MessageReactionType> {
        Set(message.currentUserReactions.map(\.type))
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

extension MessageReactionType: Identifiable {
    public var id: String {
        rawValue
    }
}
