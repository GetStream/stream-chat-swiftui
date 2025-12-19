//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View for the chat info participants.
public struct ChatInfoParticipantsView<Factory: ViewFactory>: View {
    @Injected(\.chatClient) private var chatClient
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    
    @Binding var selectedParticipant: ParticipantInfo?

    let factory: Factory
    let channel: ChatChannel
    var participants: [ParticipantInfo]
    var onItemAppear: (ParticipantInfo) -> Void
    
    public init(
        factory: Factory = DefaultViewFactory.shared,
        channel: ChatChannel,
        participants: [ParticipantInfo],
        onItemAppear: @escaping (ParticipantInfo) -> Void,
        selectedParticipant: Binding<ParticipantInfo?> = .constant(nil)
    ) {
        self.factory = factory
        self.channel = channel
        self.participants = participants
        self.onItemAppear = onItemAppear
        _selectedParticipant = selectedParticipant
    }

    public var body: some View {
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

                    participantView(participant: participant)
                    
                    Spacer()
                }
                .padding(.all, 8)
                .onAppear {
                    onItemAppear(participant)
                }
                .contentShape(.rect)
                .onTapGesture {
                    withAnimation {
                        if participant.id != chatClient.currentUserId {
                            selectedParticipant = participant
                        }
                    }
                }
            }
        }
        .background(Color(colors.background))
    }
    
    private func  participantView(participant:ParticipantInfo)-> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(participant.displayName)
                    .lineLimit(1)
                    .font(fonts.bodyBold)
                Text(participant.onlineInfoText)
                    .font(fonts.footnote)
                    .foregroundColor(Color(colors.textLowEmphasis))
            }
            Spacer()
            
            if channel.createdBy?.id == participant.chatUser.id {
                Text(L10n.chatGroupInfoOwner)
                    .font(fonts.footnote)
                    .foregroundColor(Color(colors.textLowEmphasis))
            }
        }
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
