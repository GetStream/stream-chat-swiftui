//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct ReactionsContainer: View {
    let message: ChatMessage
    var useLargeIcons = false
    
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
            }
            
            Spacer()
        }
        .offset(
            x: offsetX,
            y: -20
        )
    }
    
    private var reactions: [MessageReactionType] {
        message.reactionScores.keys.filter { reactionType in
            (message.reactionScores[reactionType] ?? 0) > 0
        }
        .sorted(by: { lhs, rhs in
            lhs.rawValue < rhs.rawValue
        })
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
        return message.isSentByCurrentUser ? -offset : offset
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
                if let image = iconProvider(for: reaction) {
                    Button {
                        onReactionTap(reaction)
                    } label: {
                        Image(uiImage: image)
                            .makeCustomizable()
                            .foregroundColor(color(for: reaction))
                            .frame(width: useLargeIcons ? 25 : 20, height: useLargeIcons ? 27 : 20)
                    }
                }
            }
        }
        .padding(.all, 6)
        .reactionsBubble(for: message)
    }
    
    private func iconProvider(for reaction: MessageReactionType) -> UIImage? {
        if useLargeIcons {
            return images.availableReactions[reaction]?.largeIcon
        } else {
            return images.availableReactions[reaction]?.smallIcon
        }
    }
    
    private func color(for reaction: MessageReactionType) -> Color {
        userReactionIDs
            .contains(reaction) ? Color(colors.highlightedAccentBackground) : Color(colors.textLowEmphasis)
    }
    
    private var userReactionIDs: Set<MessageReactionType> {
        Set(message.currentUserReactions.map(\.type))
    }
}

extension MessageReactionType: Identifiable {
    public var id: String {
        rawValue
    }
}
