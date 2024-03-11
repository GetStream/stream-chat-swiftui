//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI

class CreateGroupViewModel: ObservableObject, ChatUserSearchControllerDelegate {

    @Injected(\.chatClient) var chatClient

    var chat: Chat!

    @Published var searchText = "" {
        didSet {
            searchUsers(with: searchText)
        }
    }

    @Published var state: NewChatState = .initial
    @Published var chatUsers = [ChatUser]()
    @Published var selectedUsers = [ChatUser]()
    @Published var groupName = ""
    @Published var showGroupConversation = false
    @Published var errorShown = false

    private lazy var searchController: ChatUserSearchController = chatClient.userSearchController()
    private let lastSeenDateFormatter = DateUtils.timeAgo

    init() {
        chatUsers = searchController.userArray
        searchController.delegate = self
        // Empty initial search to get all users
        searchUsers(with: nil)
    }

    var canCreateGroup: Bool {
        !selectedUsers.isEmpty && !groupName.isEmpty
    }

    func userTapped(_ user: ChatUser) {
        if selectedUsers.contains(user) {
            selectedUsers.removeAll { selected in
                selected == user
            }
        } else {
            selectedUsers.append(user)
        }
    }

    func onlineInfo(for user: ChatUser) -> String {
        if user.isOnline {
            return "Online"
        } else if let lastActiveAt = user.lastActiveAt,
                  let timeAgo = lastSeenDateFormatter(lastActiveAt) {
            return timeAgo
        } else {
            return "Offline"
        }
    }

    func isSelected(user: ChatUser) -> Bool {
        selectedUsers.contains(user)
    }

    func showChannelView() {
        Task {
            do {
                chat = try await chatClient.makeChat(
                    with: .init(
                        type: .messaging,
                        id: String(UUID().uuidString.prefix(10))
                    ),
                    name: groupName,
                    members: selectedUsers.map(\.id)
                )
                showGroupConversation = true
            } catch {
                errorShown = true
            }
        }
    }

    // MARK: - ChatUserSearchControllerDelegate

    func controller(
        _ controller: ChatUserSearchController,
        didChangeUsers changes: [ListChange<ChatUser>]
    ) {
        chatUsers = controller.userArray
    }

    // MARK: - private

    private func searchUsers(with term: String?) {
        state = .loading
        searchController.search(term: term) { [weak self] error in
            if error != nil {
                self?.state = .error
            } else {
                self?.state = .loaded
            }
        }
    }
}
