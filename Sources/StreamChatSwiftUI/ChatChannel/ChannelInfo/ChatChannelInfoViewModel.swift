//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Combine
import Foundation
import StreamChat
import SwiftUI

// View model for the `ChatChannelInfoView`.
@MainActor public class ChatChannelInfoViewModel: ObservableObject, ChatChannelControllerDelegate {
    @Injected(\.chatClient) private var chatClient
    @Injected(\.utils) private var utils
    @Injected(\.images) private var images

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
    @Published public var memberListSheetShown = false
    @Published public var editGroupShown = false
    @Published public var isUploadingGroupAvatar = false
    @Published public var leaveGroupAlertShown = false
    @Published public var blockUserAlertShown = false
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
    @Published public var selectedParticipant: ParticipantInfo?
    
    open var shouldShowBlockUserButton: Bool {
        showSingleMemberDMView
    }

    public var isDMUserBlocked: Bool {
        guard let otherUserId = displayedParticipants.first?.id else { return false }
        return currentUserController?.currentUser?.blockedUserIds.contains(otherUserId) ?? false
    }

    public var blockUserTitle: String {
        isDMUserBlocked ? L10n.Alert.Actions.unblockUser : L10n.Alert.Actions.blockUser
    }

    open var shouldShowLeaveConversationButton: Bool {
        if showSingleMemberDMView {
            channel.ownCapabilities.contains(.deleteChannel)
        } else {
            channel.ownCapabilities.contains(.leaveChannel)
        }
    }
    
    open var shouldShowMuteChannelButton: Bool {
        channel.ownCapabilities.contains(.muteChannel)
    }

    open var canRenameChannel: Bool {
        channel.ownCapabilities.contains(.updateChannel)
    }

    open var shouldShowAddUserButton: Bool {
        if channel.isDirectMessageChannel {
            false
        } else {
            channel.ownCapabilities.contains(.updateChannelMembers)
        }
    }

    var channelController: ChatChannelController!
    var currentUserController: CurrentChatUserController?
    
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

        return Array(allParticipants.prefix(5))
    }

    public var allParticipants: [ParticipantInfo] {
        participants.filter { $0.isDeactivated == false }
    }

    open var leaveButtonTitle: String {
        if showSingleMemberDMView {
            L10n.Alert.Actions.deleteChannelTitle
        } else {
            L10n.Alert.Actions.leaveGroupTitle
        }
    }

    open var leaveConversationDescription: String {
        if showSingleMemberDMView {
            L10n.Alert.Actions.deleteChannelMessage
        } else {
            L10n.Alert.Actions.leaveGroupMessage
        }
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
        !showSingleMemberDMView && notDisplayedParticipantsCount > 0
    }

    public var allMemberIds: [String] {
        var ids = Set(participants.map(\.id))
        memberListController.members.forEach { ids.insert($0.id) }
        return Array(ids)
    }

    public init(channel: ChatChannel) {
        self.channel = channel
        channelName = channel.name?.isEmpty == false
            ? channel.name!
            : (InjectedValues[\.utils].channelNameFormatter.format(
                channel: channel,
                forCurrentUserId: InjectedValues[\.chatClient].currentUserId
            ) ?? "")
        muted = channel.isMuted
        channelController = chatClient.channelController(for: channel.cid)
        channelController.delegate = self
        memberListController = chatClient.memberListController(
            query: .init(cid: channel.cid, filter: .none)
        )
        currentUserController = chatClient.currentUserController()
        currentUserController?.synchronize()

        participants = channel.lastActiveMembers.map { member in
            ParticipantInfo(
                chatUser: member,
                displayName: memberDisplayName(member),
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

    public func onMemberAppear(_ participantInfo: ParticipantInfo) {
        let all = allParticipants
        guard let index = all.firstIndex(where: { $0.id == participantInfo.id }) else { return }
        if index < all.count - 10 { return }
        loadAdditionalUsers()
    }

    public func leaveConversationTapped(completion: @escaping @MainActor () -> Void) {
        if !showSingleMemberDMView {
            removeUserFromConversation(completion: completion)
        } else {
            deleteChannel(completion: completion)
        }
    }

    public func blockUserTapped() {
        guard let otherUserId = displayedParticipants.first?.id else { return }
        let controller = chatClient.userController(userId: otherUserId)
        if isDMUserBlocked {
            controller.unblock { [weak self] error in
                if error != nil { self?.errorShown = true }
            }
        } else {
            controller.block { [weak self] error in
                if error != nil { self?.errorShown = true }
            }
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

    public func saveGroupEdit(name: String, image: UIImage?) {
        channelName = name
        let imageURL = channel.imageURL
        let team = channel.team
        let extraData = channel.extraData
        if let image, let localURL = try? image.saveAsJpgToTemporaryUrl() {
            isUploadingGroupAvatar = true
            chatClient.uploadAttachment(localUrl: localURL, progress: nil) { [weak self] result in
                let uploadedURL = try? result.get().fileURL
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.isUploadingGroupAvatar = false
                    self.channelController.updateChannel(
                        name: name,
                        imageURL: uploadedURL ?? imageURL,
                        team: team,
                        extraData: extraData
                    )
                    self.editGroupShown = false
                }
            }
        } else {
            channelController.updateChannel(
                name: name,
                imageURL: imageURL,
                team: team,
                extraData: extraData
            )
            editGroupShown = false
        }
    }

    public func channelController(
        _ channelController: ChatChannelController,
        didUpdateChannel channel: EntityChange<ChatChannel>
    ) {
        if let channel = channelController.channel {
            self.channel = channel
            channelName = channel.name?.isEmpty == false
                ? channel.name!
                : (utils.channelNameFormatter.format(
                    channel: channel,
                    forCurrentUserId: chatClient.currentUserId
                ) ?? "")
            participants = channel.lastActiveMembers.map { member in
                ParticipantInfo(
                    chatUser: member,
                    displayName: memberDisplayName(member),
                    onlineInfoText: onlineInfo(for: member),
                    isDeactivated: member.isDeactivated
                )
            }
        }
    }

    public func addUsersTapped(_ users: [ChatUser]) {
        if !users.isEmpty {
            channelController.addMembers(userIds: Set(users.map(\.id)))
        }
        addUsersShown = false
    }

    // MARK: - private

    private func removeUserFromConversation(completion: @escaping @MainActor () -> Void) {
        guard let userId = chatClient.currentUserId else { return }
        channelController.removeMembers(userIds: [userId]) { [weak self] error in
            if error != nil {
                self?.errorShown = true
            } else {
                completion()
            }
        }
    }

    private func deleteChannel(completion: @escaping @MainActor () -> Void) {
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
                        displayName: self.memberDisplayName(member),
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

    private func memberDisplayName(_ member: ChatChannelMember) -> String {
        member.id == chatClient.currentUserId ? L10n.Channel.Item.you : (member.name ?? member.id)
    }
    
    open func participantActions(for participant: ParticipantInfo) -> [ParticipantAction] {
        if participant.id == chatClient.currentUserId {
            var actions = [ParticipantAction]()
            if !showSingleMemberDMView {
                actions.append(leaveGroupAction(
                    onDismiss: handleParticipantActionDismiss,
                    onError: handleParticipantActionError
                ))
            }
            return actions
        }

        var actions = [ParticipantAction]()

        let directMessageAction = ParticipantAction(
            title: L10n.Channel.Item.sendDirectMessage,
            iconName: "message",
            action: {},
            confirmationPopup: nil,
            isDestructive: false
        )
        if let currentUserId = chatClient.currentUserId,
           let channelController = try? chatClient.channelController(
               createDirectMessageChannelWith: [currentUserId, participant.id],
               extraData: [:]
           ) {
            directMessageAction.navigationDestination = AnyView(
                ChatChannelView(channelController: channelController)
            )

            actions.append(directMessageAction)
        }

        if channel.config.mutesEnabled {
            let mutedUsers = currentUserController?.currentUser?.mutedUsers ?? []
            if mutedUsers.contains(participant.chatUser) == true {
                let unmuteUser = unmuteAction(
                    participant: participant,
                    onDismiss: handleParticipantActionDismiss,
                    onError: handleParticipantActionError
                )
                actions.append(unmuteUser)
            } else {
                let muteUser = muteAction(
                    participant: participant,
                    onDismiss: handleParticipantActionDismiss,
                    onError: handleParticipantActionError
                )
                actions.append(muteUser)
            }
        }
        
        let blockAction = blockParticipantAction(
            participant: participant,
            onDismiss: handleParticipantActionDismiss,
            onError: handleParticipantActionError
        )
        actions.append(blockAction)

        if channel.canUpdateChannelMembers {
            let removeUserAction = removeUserAction(
                participant: participant,
                onDismiss: handleParticipantActionDismiss,
                onError: handleParticipantActionError
            )
            actions.append(removeUserAction)
        }
        
        return actions
    }
    
    public func muteAction(
        participant: ParticipantInfo,
        onDismiss: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) -> ParticipantAction {
        let muteAction = { [weak self] in
            let controller = self?.chatClient.userController(userId: participant.id)
            controller?.mute { error in
                if let error {
                    onError(error)
                } else {
                    onDismiss()
                }
            }
        }
        let confirmationPopup = ConfirmationPopup(
            title: "\(L10n.Channel.Item.mute) \(participant.displayName)",
            message: "\(L10n.Alert.Actions.muteChannelTitle) \(participant.displayName)?",
            buttonTitle: L10n.Channel.Item.mute
        )
        let muteUser = ParticipantAction(
            title: "\(L10n.Channel.Item.mute) \(participant.displayName)",
            iconName: "speaker.slash",
            action: muteAction,
            confirmationPopup: confirmationPopup,
            isDestructive: false
        )
        return muteUser
    }

    public func unmuteAction(
        participant: ParticipantInfo,
        onDismiss: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) -> ParticipantAction {
        let unMuteAction = { [weak self] in
            let controller = self?.chatClient.userController(userId: participant.id)
            controller?.unmute { error in
                if let error {
                    onError(error)
                } else {
                    onDismiss()
                }
            }
        }
        let confirmationPopup = ConfirmationPopup(
            title: "\(L10n.Channel.Item.unmute) \(participant.displayName)",
            message: "\(L10n.Alert.Actions.unmuteChannelTitle) \(participant.displayName)?",
            buttonTitle: L10n.Channel.Item.unmute
        )
        let unmuteUser = ParticipantAction(
            title: "\(L10n.Channel.Item.unmute) \(participant.displayName)",
            iconName: "speaker.wave.1",
            action: unMuteAction,
            confirmationPopup: confirmationPopup,
            isDestructive: false
        )

        return unmuteUser
    }
    
    public func removeUserAction(
        participant: ParticipantInfo,
        onDismiss: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) -> ParticipantAction {
        let action = { [weak self] in
            guard let self else {
                onError(ClientError.Unexpected("Self is nil"))
                return
            }
            let controller = chatClient.channelController(for: channel.cid)
            controller.removeMembers(userIds: [participant.id]) { error in
                if let error {
                    onError(error)
                } else {
                    onDismiss()
                }
            }
        }
        
        let confirmationPopup = ConfirmationPopup(
            title: L10n.Channel.Item.removeUserConfirmationTitle,
            message: L10n.Channel.Item.removeUserConfirmationMessage(participant.displayName, channel.name ?? channel.id),
            buttonTitle: L10n.Channel.Item.removeUser
        )
        
        let removeUserAction = ParticipantAction(
            title: L10n.Channel.Item.removeUser,
            iconName: "person.slash",
            action: action,
            confirmationPopup: confirmationPopup,
            isDestructive: true
        )

        return removeUserAction
    }
    
    public func blockParticipantAction(
        participant: ParticipantInfo,
        onDismiss: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) -> ParticipantAction {
        let isBlocked = currentUserController?.currentUser?.blockedUserIds.contains(participant.id) ?? false
        let title = isBlocked ? L10n.Alert.Actions.unblockUser : L10n.Alert.Actions.blockUser
        let action = { [weak self] in
            let controller = self?.chatClient.userController(userId: participant.id)
            if isBlocked {
                controller?.unblock { error in
                    if let error { onError(error) } else { onDismiss() }
                }
            } else {
                controller?.block { error in
                    if let error { onError(error) } else { onDismiss() }
                }
            }
        }
        let confirmationPopup = isBlocked ? nil : ConfirmationPopup(
            title: L10n.Alert.Actions.blockUser,
            message: L10n.Message.Actions.UserBlock.confirmationMessage,
            buttonTitle: L10n.Alert.Actions.blockUser
        )
        return ParticipantAction(
            title: title,
            iconName: "nosign",
            action: action,
            confirmationPopup: confirmationPopup,
            isDestructive: false
        )
    }

    public func leaveGroupAction(
        onDismiss: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) -> ParticipantAction {
        let action = { [weak self] in
            guard let self else { return }
            guard let userId = chatClient.currentUserId else { return }
            channelController.removeMembers(userIds: [userId]) { error in
                if let error { onError(error) } else { onDismiss() }
            }
        }
        let confirmationPopup = ConfirmationPopup(
            title: L10n.Alert.Actions.leaveGroupTitle,
            message: L10n.Alert.Actions.leaveGroupMessage,
            buttonTitle: L10n.Alert.Actions.leaveGroupButton
        )
        return ParticipantAction(
            title: L10n.Alert.Actions.leaveGroupTitle,
            iconName: "rectangle.portrait.and.arrow.right",
            action: action,
            confirmationPopup: confirmationPopup,
            isDestructive: true
        )
    }

    func handleParticipantActionDismiss() {
        selectedParticipant = nil
    }

    func handleParticipantActionError(_ error: Error?) {
        errorShown = true
    }
}
