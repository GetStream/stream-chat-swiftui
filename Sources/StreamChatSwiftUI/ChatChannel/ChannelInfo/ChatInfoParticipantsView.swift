//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct ChatInfoParticipantsView: View {
    
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    
    var participants: [ParticipantInfo]
    
    var body: some View {
        LazyVStack {
            ForEach(participants) { participant in
                HStack {
                    MessageAvatarView(avatarURL: participant.chatUser.imageURL)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(participant.displayName)
                            .lineLimit(1)
                            .font(fonts.bodyBold)
                        Text(participant.onlineInfoText)
                            .font(fonts.footnote)
                            .foregroundColor(Color(colors.textLowEmphasis))
                    }
                    Spacer()
                }
                .padding(.all, 8)
            }
        }
    }
}

struct ParticipantInfo: Identifiable {
    var id: String {
        chatUser.id
    }

    let chatUser: ChatUser
    let displayName: String
    let onlineInfoText: String
}
