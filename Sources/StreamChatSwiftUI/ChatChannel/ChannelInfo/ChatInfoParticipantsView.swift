//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View for the chat info participants.
public struct ChatInfoParticipantsView: View {

    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors

    public var participants: [ParticipantInfo]
    public var onItemAppear: (ParticipantInfo) -> Void

    public init(participants: [ParticipantInfo], onItemAppear: @escaping (ParticipantInfo) -> Void) {
        self.participants = participants
        self.onItemAppear = onItemAppear
    }

    public var body: some View {
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
                .onAppear {
                    onItemAppear(participant)
                }
            }
        }
        .background(Color(colors.background))
    }
}

public struct ParticipantInfo: Identifiable {
    public var id: String {
        chatUser.id
    }

    public let chatUser: ChatUser
    public let displayName: String
    public let onlineInfoText: String

    public init(chatUser: ChatUser, displayName: String, onlineInfoText: String) {
        self.chatUser = chatUser
        self.displayName = displayName
        self.onlineInfoText = onlineInfoText
    }
}
