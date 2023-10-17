//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct BottomReactionsView: View {
    
    @Injected(\.utils) var utils
    @Injected(\.colors) var colors
    
    var message: ChatMessage
    var onTap: () -> ()
    
    var body: some View {
        HStack {
            ForEach(reactions) { reaction in
                if let image = ReactionsIconProvider.icon(for: reaction, useLargeIcons: false) {
                    HStack(spacing: 4) {
                        ReactionIcon(
                            icon: image,
                            color: ReactionsIconProvider.color(
                                for: reaction,
                                userReactionIDs: userReactionIDs
                            )
                        )
                        .frame(width: 20, height: 20)
                        Text("1")
                    }
                    .padding(.all, 8)
                    .background(Color(colors.background1))
                    .cornerRadius(16)
                }
            }
            Button(
                action: onTap,
                label: {
                    Image(systemName: "face.smiling.inverse")
                        .padding(.all, 8)
                        .background(Color(colors.background1))
                        .cornerRadius(16)
                }
            )
        }
    }
    
    private var reactions: [MessageReactionType] {
        message.reactionScores.keys.filter { reactionType in
            (message.reactionScores[reactionType] ?? 0) > 0
        }
        .sorted(by: utils.sortReactions)
    }
    
    private var userReactionIDs: Set<MessageReactionType> {
        Set(message.currentUserReactions.map(\.type))
    }
}
