//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View model for the `MemberAddView`.
@MainActor class MemberAddViewModel: ObservableObject {
    @Injected(\.chatClient) private var chatClient

    @Published var users = [ChatUser]()
    @Published var searchText = "" {
        didSet {
            guard searchText != oldValue else { return }
            searchUsers(term: searchText)
        }
    }

    @Published private(set) var selectedUserIds = Set<String>()

    private var loadedUserIds: [String]
    private var loadingNextUsers = false
    private lazy var searchController: ChatUserSearchController = chatClient.userSearchController()

    init(loadedUserIds: [String]) {
        self.loadedUserIds = loadedUserIds
        searchUsers()
    }

    init(loadedUserIds: [String], searchController: ChatUserSearchController) {
        self.loadedUserIds = loadedUserIds
        self.searchController = searchController
        searchUsers()
    }

    func toggleUser(_ user: ChatUser) {
        if selectedUserIds.contains(user.id) {
            selectedUserIds.remove(user.id)
        } else {
            selectedUserIds.insert(user.id)
        }
    }

    func isSelected(_ user: ChatUser) -> Bool {
        selectedUserIds.contains(user.id)
    }

    func isAlreadyMember(_ user: ChatUser) -> Bool {
        loadedUserIds.contains(user.id)
    }

    var selectedUsers: [ChatUser] {
        users.filter { selectedUserIds.contains($0.id) }
    }

    func onUserAppear(_ user: ChatUser) {
        guard let index = users.firstIndex(where: { element in
            user.id == element.id
        }) else {
            return
        }

        if index < users.count - 10 {
            return
        }

        if !loadingNextUsers {
            loadingNextUsers = true
            searchController.loadNextUsers { [weak self] _ in
                guard let self else { return }
                users = searchController.userArray
                loadingNextUsers = false
            }
        }
    }

    private func searchUsers() {
        searchController.search(query: UserListQuery()) { [weak self] error in
            guard let self, error == nil else { return }
            users = searchController.userArray
        }
    }

    private func searchUsers(term: String) {
        if term.isEmpty {
            searchUsers()
            return
        }
        // Debouncing is handled by ChatUserSearchController.
        searchController.search(term: term) { [weak self] error in
            guard let self, error == nil else { return }
            users = searchController.userArray
        }
    }
}
