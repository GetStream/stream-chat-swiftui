//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View for the chat info participants.
struct ChatInfoParticipantsView<Factory: ViewFactory>: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors

    let factory: Factory
    var participants: [ParticipantInfo]
    var onItemAppear: (ParticipantInfo) -> Void
    
    init(
        factory: Factory = DefaultViewFactory.shared,
        participants: [ParticipantInfo],
        onItemAppear: @escaping (ParticipantInfo) -> Void
    ) {
        self.factory = factory
        self.participants = participants
        self.onItemAppear = onItemAppear
    }

    var body: some View {
        LazyVStack {
            ForEach(participants) { participant in
                HStack {
                    let displayInfo = UserDisplayInfo(
                        id: participant.chatUser.id,
                        name: participant.chatUser.name ?? "",
                        imageURL: participant.chatUser.imageURL,
                        extraData: participant.chatUser.extraData
                    )
                    factory.makeMessageAvatarView(for: displayInfo)

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
    public let isDeactivated: Bool

    public init(
        chatUser: ChatUser,
        displayName: String,
        onlineInfoText: String,
        isDeactivated: Bool = false
    ) {
        self.chatUser = chatUser
        self.displayName = displayName
        self.onlineInfoText = onlineInfoText
        self.isDeactivated = isDeactivated
    }
}
