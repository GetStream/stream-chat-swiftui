//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat
import SwiftUI

// View model for the `ChatChannelInfoView`.
@MainActor public class ChatChannelInfoViewModel: ObservableObject, ChatChannelControllerDelegate {
    @Injected(\.chatClient) private var chatClient

    @Published public var participants = [ParticipantInfo]()
    @Published public var muted: Bool {
        didSet {
            if muted {
                channelController.muteChannel()
            } else {
                channelController.unmuteChannel()
            }
        }
    }

    @Published public var memberListCollapsed = true
    @Published public var leaveGroupAlertShown = false
    @Published public var errorShown = false
    @Published public var channelName: String
    @Published public var channel: ChatChannel {
        didSet {
            channelId = UUID().uuidString
        }
    }

    @Published public var channelId = UUID().uuidString
    @Published public var keyboardShown = false
    @Published public var addUsersShown = false

    public var shouldShowLeaveConversationButton: Bool {
        if channel.isDirectMessageChannel {
            channel.ownCapabilities.contains(.deleteChannel)
        } else {
            channel.ownCapabilities.contains(.leaveChannel)
        }
    }

    public var canRenameChannel: Bool {
        channel.ownCapabilities.contains(.updateChannel)
    }

    public var shouldShowAddUserButton: Bool {
        if channel.isDirectMessageChannel {
            false
        } else {
            channel.ownCapabilities.contains(.updateChannelMembers)
        }
    }

    var channelController: ChatChannelController!
    private var memberListController: ChatChannelMemberListController!
    private var loadingUsers = false
    
    public var showSingleMemberDMView: Bool {
        channel.isDirectMessageChannel && participants.count <= 2
    }

    public var displayedParticipants: [ParticipantInfo] {
        if showSingleMemberDMView,
           let otherParticipant = participants.first(where: { info in
               info.id != chatClient.currentUserId
           }) {
            return [otherParticipant]
        }
        
        let participants = participants.filter { $0.isDeactivated == false }

        if participants.count <= 6 {
            return participants
        }

        if memberListCollapsed {
            return Array(participants[0..<6])
        } else {
            return participants
        }
    }

    public var leaveButtonTitle: String {
        if channel.isDirectMessageChannel {
            L10n.Alert.Actions.deleteChannelTitle
        } else {
            L10n.Alert.Actions.leaveGroupTitle
        }
    }

    public var leaveConversationDescription: String {
        if channel.isDirectMessageChannel {
            L10n.Alert.Actions.deleteChannelMessage
        } else {
            L10n.Alert.Actions.leaveGroupMessage
        }
    }
    
    public var showMoreUsersButtonTitle: String {
        L10n.ChatInfo.Users.loadMore(notDisplayedParticipantsCount)
    }

    public var notDisplayedParticipantsCount: Int {
        let total = channel.memberCount
        let displayed = displayedParticipants.count
        let deactivated = participants.count(where: { $0.isDeactivated })
        return total - displayed - deactivated
    }

    public var mutedText: String {
        let isGroup = channel.memberCount > 2
        return isGroup ? L10n.ChatInfo.Mute.group : L10n.ChatInfo.Mute.user
    }

    public var showMoreUsersButton: Bool {
        !showSingleMemberDMView && memberListCollapsed && notDisplayedParticipantsCount > 0
    }

    public init(channel: ChatChannel) {
        self.channel = channel
        channelName = channel.name ?? ""
        muted = channel.isMuted
        channelController = chatClient.channelController(for: channel.cid)
        channelController.delegate = self
        memberListController = chatClient.memberListController(
            query: .init(cid: channel.cid, filter: .none)
        )

        participants = channel.lastActiveMembers.map { member in
            ParticipantInfo(
                chatUser: member,
                displayName: member.name ?? member.id,
                onlineInfoText: onlineInfo(for: member),
                isDeactivated: member.isDeactivated
            )
        }
    }

    public func onlineInfo(for user: ChatUser) -> String {
        if user.isOnline {
            L10n.Message.Title.online
        } else if let lastActiveAt = user.lastActiveAt,
                  let timeAgo = lastSeenDateFormatter(lastActiveAt) {
            timeAgo
        } else {
            L10n.Message.Title.offline
        }
    }

    public func onParticipantAppear(_ participantInfo: ParticipantInfo) {
        if memberListCollapsed {
            return
        }

        let displayedParticipants = displayedParticipants
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

    public func leaveConversationTapped(completion: @escaping @MainActor() -> Void) {
        if !channel.isDirectMessageChannel {
            removeUserFromConversation(completion: completion)
        } else {
            deleteChannel(completion: completion)
        }
    }

    public func cancelGroupRenaming() {
        resignFirstResponder()
        channelName = channel.name ?? ""
    }

    public func confirmGroupRenaming() {
        resignFirstResponder()
        channelController.updateChannel(
            name: channelName,
            imageURL: channel.imageURL,
            team: channel.team,
            extraData: channel.extraData
        )
    }

    public func channelController(
        _ channelController: ChatChannelController,
        didUpdateChannel channel: EntityChange<ChatChannel>
    ) {
        if let channel = channelController.channel {
            self.channel = channel
            if self.channel.lastActiveMembers.count > participants.count {
                participants = channel.lastActiveMembers.map { member in
                    ParticipantInfo(
                        chatUser: member,
                        displayName: member.name ?? member.id,
                        onlineInfoText: onlineInfo(for: member),
                        isDeactivated: member.isDeactivated
                    )
                }
            }
        }
    }

    public func addUserTapped(_ user: ChatUser) {
        channelController.addMembers(userIds: [user.id])
        addUsersShown = false
    }

    // MARK: - private

    private func removeUserFromConversation(completion: @escaping @MainActor() -> Void) {
        guard let userId = chatClient.currentUserId else { return }
        channelController.removeMembers(userIds: [userId]) { [weak self] error in
            if error != nil {
                self?.errorShown = true
            } else {
                completion()
            }
        }
    }

    private func deleteChannel(completion: @escaping @MainActor() -> Void) {
        channelController.deleteChannel { [weak self] error in
            if error != nil {
                self?.errorShown = true
            } else {
                completion()
            }
        }
    }

    private func loadAdditionalUsers() {
        if loadingUsers {
            return
        }

        loadingUsers = true
        memberListController.loadNextMembers { [weak self] error in
            guard let self else { return }
            loadingUsers = false
            if error == nil {
                let newMembers = memberListController.members.map { member in
                    ParticipantInfo(
                        chatUser: member,
                        displayName: member.name ?? member.id,
                        onlineInfoText: self.onlineInfo(for: member),
                        isDeactivated: member.isDeactivated
                    )
                }
                if newMembers.count > participants.count {
                    participants = newMembers
                }
            }
        }
    }

    private var lastSeenDateFormatter: (Date) -> String? {
        DateUtils.timeAgo
    }
}
