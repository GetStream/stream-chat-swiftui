//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Combine
import StreamChat
import StreamChatSwiftUI
import SwiftUI

class CreateGroupViewModel: ObservableObject {

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

    private lazy var userSearch: UserSearch = chatClient.makeUserSearch()
    private let lastSeenDateFormatter = DateUtils.timeAgo
    private var cancellables = Set<AnyCancellable>()

    init() {
        chatUsers = Array(userSearch.state.users)
        // Empty initial search to get all users
        searchUsers(with: nil)
        subscribeToUserChanges()
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
        Task { @MainActor in
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

    // MARK: - private
    
    private func subscribeToUserChanges() {
        userSearch.state.$users.sink { [weak self] users in
            self?.chatUsers = Array(users)
        }
        .store(in: &cancellables)
    }

    private func searchUsers(with term: String?) {
        state = .loading
        Task { @MainActor in
            do {
                try await userSearch.search(query: .search(term: term))
                state = .loaded
            } catch {
                state = .error
            }
        }
    }
}
