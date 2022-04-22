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
    
    let channel: ChatChannel
    
    private var channelController: ChatChannelController!
    private var memberListController: ChatChannelMemberListController!
    private var loadingUsers = false
    
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
    
    var notDisplayedParticipantsCount: Int {
        let total = channel.memberCount
        let displayed = displayedParticipants.count
        return total - displayed
    }
    
    var mutedText: String {
        let isGroup = channel.memberCount > 2
        return isGroup ? L10n.ChatInfo.Mute.group : L10n.ChatInfo.Mute.user
    }
    
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
    
    func onParticipantAppear(_ participantInfo: ParticipantInfo) {
        if memberListCollapsed {
            return
        }
        
        let displayedParticipants = self.displayedParticipants
        if displayedParticipants.isEmpty {
            loadAdditionalUsers()
            return
        }
        
        guard let index = displayedParticipants.firstIndex(where: { participant in
            participant.id == participantInfo.id
        }) else {
            return
        }
        
        if index < displayedParticipants.count - 10 {
            return
        }
     
        loadAdditionalUsers()
    }
    
    private func loadAdditionalUsers() {
        if loadingUsers {
            return
        }
        
        loadingUsers = true
        memberListController.loadNextMembers { [weak self] error in
            guard let self = self else { return }
            self.loadingUsers = false
            if error == nil {
                let newMembers = self.memberListController.members.map { member in
                    ParticipantInfo(
                        chatUser: member,
                        displayName: member.name ?? member.id,
                        onlineInfoText: self.onlineInfo(for: member)
                    )
                }
                if newMembers.count > self.participants.count {
                    self.participants = newMembers
                }
            }
        }
    }
    
    private var lastSeenDateFormatter: (Date) -> String? {
        DateUtils.timeAgo
    }
}
