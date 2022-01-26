//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct ReactionsUsersView: View {
    
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    
    var message: ChatMessage
    var maxHeight: CGFloat
    
    private static let columnCount = 4
    
    private let columns = Array(
        repeating:
        GridItem(
            .adaptive(minimum: 64),
            alignment: .top
        ),
        count: columnCount
    )
    
    private var reactions: [ChatMessageReaction] {
        Array(message.latestReactions)
    }
    
    var body: some View {
        HStack {
            if message.isSentByCurrentUser {
                Spacer()
            }
            
            VStack(alignment: .center) {
                Text(L10n.Message.Reactions.title)
                    .foregroundColor(Color(colors.text))
                    .font(fonts.title3)
                    .fontWeight(.bold)
                    .padding()
                
                if reactions.count > Self.columnCount {
                    ScrollView {
                        LazyVGrid(columns: columns, alignment: .center, spacing: 8) {
                            ForEach(reactions) { reaction in
                                ReactionUserView(reaction: reaction)
                            }
                        }
                    }
                    .frame(maxHeight: maxHeight)
                } else {
                    HStack(alignment: .top, spacing: 0) {
                        ForEach(reactions) { reaction in
                            ReactionUserView(reaction: reaction)
                        }
                    }
                    .padding(.horizontal, 8)
                }
            }
            .background(Color(colors.background))
            .cornerRadius(16)
            
            if !message.isSentByCurrentUser {
                Spacer()
            }
        }
    }
}

struct ReactionUserView: View {
    
    @Injected(\.chatClient) private var chatClient
    @Injected(\.fonts) private var fonts
    
    var reaction: ChatMessageReaction
    
    private var isCurrentUser: Bool {
        chatClient.currentUserId == reaction.author.id
    }
    
    private var authorName: String {
        if isCurrentUser {
            return L10n.Message.Reactions.currentUser
        } else {
            return reaction.author.name ?? reaction.author.id
        }
    }
    
    var body: some View {
        VStack {
            MessageAvatarView(
                author: reaction.author,
                size: CGSize(width: 64, height: 64),
                showOnlineIndicator: false
            )
            .overlay(
                VStack {
                    Spacer()
                    SingleReactionView(reaction: reaction)
                        .frame(height: 32)
                }
            )
            
            Text(authorName)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .font(fonts.footnoteBold)
                .frame(width: 64)
        }
        .padding(.vertical)
        .padding(.horizontal, 8)
    }
}

extension ChatMessageReaction: Identifiable {
    
    public var id: String {
        "\(author.id)-\(type.rawValue)"
    }
}
