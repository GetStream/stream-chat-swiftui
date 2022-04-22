//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat
import SwiftUI

public class ChatChannelInfoViewModel: ObservableObject {
    
    @Injected(\.chatClient) private var chatClient
    
    @Published var participants = [ParticipantInfo]()
    @Published var muted: Bool {
        didSet {
            if muted {
                channelController.muteChannel()
            } else {
                channelController.unmuteChannel()
            }
        }
    }

    @Published var memberListCollapsed = true
    
    var displayedParticipants: [ParticipantInfo] {
        if participants.count <= 6 {
            return participants
        }
        
        if memberListCollapsed {
            return Array(participants[0..<6])
        } else {
            return participants
        }
    }
    
    var mutedText: String {
        let isGroup = channel.memberCount > 2
        return isGroup ? L10n.ChatInfo.Mute.group : L10n.ChatInfo.Mute.user
    }
    
    let channel: ChatChannel
    var channelController: ChatChannelController!
    var memberListController: ChatChannelMemberListController!
    
    public init(channel: ChatChannel) {
        self.channel = channel
        muted = channel.isMuted
        channelController = chatClient.channelController(for: channel.cid)
        memberListController = chatClient.memberListController(
            query: .init(cid: channel.cid, filter: .none)
        )

        participants = channel.lastActiveMembers.map { member in
            ParticipantInfo(
                chatUser: member,
                displayName: member.name ?? member.id,
                onlineInfoText: onlineInfo(for: member)
            )
        }
    }
    
    func onlineInfo(for user: ChatUser) -> String {
        if user.isOnline {
            return L10n.Message.Title.online
        } else if let lastActiveAt = user.lastActiveAt,
                  let timeAgo = lastSeenDateFormatter(lastActiveAt) {
            return timeAgo
        } else {
            return L10n.Message.Title.offline
        }
    }
    
    private var lastSeenDateFormatter: (Date) -> String? {
        DateUtils.timeAgo
    }
}
