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
                            .frame(width: 24, height: 24)
                            .padding(.all, 4)
                            .background(Color(colors.background6))
                            .clipShape(Circle())
  
                        // TODO: implement the bubbles.
//                        ReactionBubbles(
//                            isSentByCurrentUser: isSentByCurrentUser
//                        )
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
    
    var isSentByCurrentUser: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Circle()
                .fill(Color.gray)
                .frame(width: 12, height: 12)
            Circle()
                .fill(Color.gray)
                .frame(width: 8, height: 8)
        }
        .rotationEffect(.degrees(isSentByCurrentUser ? -45 : 45))
    }
}
