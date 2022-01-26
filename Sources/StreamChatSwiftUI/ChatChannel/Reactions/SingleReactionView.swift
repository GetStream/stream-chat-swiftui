//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct SingleReactionView: View {
    
    @Injected(\.images) private var images
    @Injected(\.colors) private var colors
    @Injected(\.chatClient) private var chatClient
    
    var reaction: ChatMessageReaction
    
    private var isSentByCurrentUser: Bool {
        reaction.author.id == chatClient.currentUserId
    }
    
    private var reactionColor: Color {
        isSentByCurrentUser ? colors.tintColor : Color(colors.textLowEmphasis)
    }
    
    private var backgroundColor: Color {
        isSentByCurrentUser ? Color(colors.background) : Color(colors.background6)
    }
        
    var body: some View {
        VStack {
            Spacer()
            HStack {
                if !isSentByCurrentUser {
                    Spacer()
                }
                
                if let image = images.availableReactions[reaction.type]?.largeIcon {
                    VStack(spacing: 0) {
                        Image(uiImage: image)
                            .resizable()
                            .foregroundColor(reactionColor)
                            .frame(width: 16, height: 16)
                            .padding(.all, 8)
                            .background(backgroundColor)
                            .overlay(
                                Circle()
                                    .strokeBorder(
                                        Color(colors.innerBorder),
                                        lineWidth: 1
                                    )
                            )
                            .clipShape(Circle())
  
                        ReactionBubbles(
                            isSentByCurrentUser: isSentByCurrentUser,
                            backgroundColor: backgroundColor
                        )
                        .offset(x: isSentByCurrentUser ? 8 : -8, y: -14)
                    }
                }
                
                if isSentByCurrentUser {
                    Spacer()
                }
            }
        }
    }
}

struct ReactionBubbles: View {
    
    @Injected(\.colors) private var colors
    
    var isSentByCurrentUser: Bool
    var backgroundColor: Color
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Circle()
                .fill(backgroundColor)
                .frame(width: 8, height: 8)
            Circle()
                .fill(backgroundColor)
                .frame(width: 4, height: 4)
        }
        .rotationEffect(.degrees(isSentByCurrentUser ? -45 : 45))
    }
}
