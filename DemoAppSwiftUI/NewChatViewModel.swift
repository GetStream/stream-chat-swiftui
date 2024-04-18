//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI

@MainActor class NewChatViewModel: ObservableObject {

    @Injected(\.chatClient) var chatClient

    @Published var searchText: String = "" {
        didSet {
            searchUsers(with: searchText)
        }
    }

    @Published var messageText: String = ""
    @Published var chatUsers = [ChatUser]()
    @Published var state: NewChatState = .initial
    @Published var selectedUsers = [ChatUser]() {
        didSet {
            if !updatingSelectedUsers {
                updatingSelectedUsers = true
                if !selectedUsers.isEmpty {
                    do {
                        try makeChat()
                    } catch {
                        state = .error
                        updatingSelectedUsers = false
                    }

                } else {
                    withAnimation {
                        state = .loaded
                        updatingSelectedUsers = false
                    }
                }
            }
        }
    }

    private var loadingNextUsers: Bool = false
    private var updatingSelectedUsers: Bool = false

    var chat: Chat?

    private lazy var userSearch: UserSearch = chatClient.makeUserSearch()
    private let lastSeenDateFormatter = DateUtils.timeAgo

    init() {
        chatUsers = Array(userSearch.state.users)
        // Empty initial search to get all users
        searchUsers(with: nil)
    }

    func userTapped(_ user: ChatUser) {
        if updatingSelectedUsers {
            return
        }

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

    func onChatUserAppear(_ user: ChatUser) {
        guard let index = chatUsers.firstIndex(where: { element in
            user.id == element.id
        }) else {
            return
        }

        if index < chatUsers.count - 10 {
            return
        }

        if !loadingNextUsers {
            loadingNextUsers = true
            Task { @MainActor in
                _ = try? await userSearch.loadMoreUsers(limit: 50)
                chatUsers = Array(userSearch.state.users)
                loadingNextUsers = false
            }
        }
    }
    
    // MARK: - private

    private func searchUsers(with term: String?) {
        state = .loading
        Task { @MainActor in
            do {
                chatUsers = try await userSearch.search(term: term)
                state = .loaded
            } catch {
                state = .error
            }
        }
    }

    private func makeChat() throws {
        let selectedUserIds = selectedUsers.map(\.id)
        Task { @MainActor in
            do {
                chat = try await chatClient.makeDirectMessageChat(with: selectedUserIds, extraData: [:])
                withAnimation {
                    state = .channel
                    updatingSelectedUsers = false
                }
            } catch {
                state = .error
                updatingSelectedUsers = false
            }
        }
    }
}

enum NewChatState {
    case initial
    case loading
    case noUsers
    case error
    case loaded
    case channel
}
