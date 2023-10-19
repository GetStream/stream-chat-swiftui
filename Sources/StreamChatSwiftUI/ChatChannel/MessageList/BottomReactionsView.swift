//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct BottomReactionsView: View {
    
    @Injected(\.chatClient) var chatClient
    @Injected(\.utils) var utils
    @Injected(\.colors) var colors
    
    var showsAllInfo: Bool
    var onTap: () -> ()
    var onLongPress: () -> ()
    
    @StateObject var viewModel: ReactionsOverlayViewModel
    
    init(
        message: ChatMessage,
        showsAllInfo: Bool,
        onTap: @escaping () -> (),
        onLongPress: @escaping () -> ()
    ) {
        self.showsAllInfo = showsAllInfo
        self.onTap = onTap
        self.onLongPress = onLongPress
        _viewModel = StateObject(wrappedValue: ReactionsOverlayViewModel(message: message))
    }
    
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
                        Text("\(count(for: reaction))")
                    }
                    .padding(.all, 8)
                    .background(Color(colors.background1))
                    .modifier(
                        BubbleModifier(
                            corners: corners(for: reaction),
                            backgroundColors: [Color(colors.background1)],
                            cornerRadius: 16
                        )
                    )
                    .onTapGesture {
                        viewModel.reactionTapped(reaction)
                    }
                    .onLongPressGesture {
                        onLongPress()
                    }
                }
            }
            Button(
                action: onTap,
                label: {
                    Image(systemName: "face.smiling.inverse")
                        .padding(.all, 8)
                        .modifier(
                            BubbleModifier(
                                corners: (message.isSentByCurrentUser && showsAllInfo) ? [.bottomLeft, .bottomRight, .topLeft] : .allCorners,
                                backgroundColors: [Color(colors.background1)],
                                cornerRadius: 16
                            )
                        )
                }
            )
        }
        .offset(y: -2)
    }
    
    private var message: ChatMessage {
        viewModel.message
    }
    
    private func corners(for reaction: MessageReactionType) -> UIRectCorner {
        if message.isSentByCurrentUser || reaction != reactions.first || !showsAllInfo {
            return .allCorners
        }
        return [.bottomLeft, .bottomRight, .topRight]
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
    
    private func count(for reaction: MessageReactionType) -> Int {
        message.reactionScores[reaction] ?? 0
    }
}
