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
    var reactionsPerRow: Int
    var onTap: () -> ()
    var onLongPress: () -> ()
    
    @StateObject var viewModel: ReactionsOverlayViewModel
    
    init(
        message: ChatMessage,
        showsAllInfo: Bool,
        reactionsPerRow: Int = 4,
        onTap: @escaping () -> (),
        onLongPress: @escaping () -> ()
    ) {
        self.showsAllInfo = showsAllInfo
        self.onTap = onTap
        self.reactionsPerRow = reactionsPerRow
        self.onLongPress = onLongPress
        _viewModel = StateObject(wrappedValue: ReactionsOverlayViewModel(message: message))
    }
    
    var body: some View {
        if reactions.count > 3 {
            let numberOfRows = Int((Double(reactions.count + 1) / Double(reactionsPerRow)).rounded(.up))
            VStack {
                ForEach(0..<numberOfRows, id: \.self) { row in
                    let start = row * reactionsPerRow
                    let end = start + (reactionsPerRow - 1) >= reactions.count ? reactions.count - 1 : start + (reactionsPerRow - 1)
                    let slice = end < start ? [] : Array(reactions[start...end])
                    let isEndRow = slice.isEmpty ? true : end == (reactions.count - 1)
                    HStack {
                        if message.isRightAligned {
                            Spacer()
                        }
                        content(for: slice, isEndRow: isEndRow)
                        if !message.isRightAligned {
                            Spacer()
                        }
                    }
                }
            }
        } else {
            HStack {
                content(for: reactions)
            }
            .offset(y: -2)
        }
    }
    
    private func content(for reactions: [MessageReactionType], isEndRow: Bool = true) -> some View {
        Group {
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
                            corners: corners(for: reaction, in: reactions, isEndRow: isEndRow),
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
            
            if isEndRow && reactions.count < reactionsPerRow {
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
        }
    }
    
    private var message: ChatMessage {
        viewModel.message
    }
    
    private func corners(
        for reaction: MessageReactionType,
        in reactions: [MessageReactionType],
        isEndRow: Bool
    ) -> UIRectCorner {
        if message.isSentByCurrentUser || reaction != reactions.first || !showsAllInfo {
            return .allCorners
        }
        if isEndRow {
            return [.bottomLeft, .bottomRight, .topRight]
        } else {
            return .allCorners
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
    
    private func count(for reaction: MessageReactionType) -> Int {
        message.reactionScores[reaction] ?? 0
    }
}
