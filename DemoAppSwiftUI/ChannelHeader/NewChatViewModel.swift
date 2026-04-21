//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Dispatch
import StreamChat
import StreamChatCommonUI
import StreamChatSwiftUI
import SwiftUI

@MainActor class NewChatViewModel: ObservableObject, ChatUserSearchControllerDelegate {
    @Injected(\.chatClient) var chatClient

    @Published var searchText: String = "" {
        didSet {
            scheduleDebouncedUserSearch()
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
                        try makeChannelController()
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

    var channelController: ChatChannelController?

    private lazy var searchController: ChatUserSearchController = chatClient.userSearchController()
    private let lastSeenDateFormatter = DateUtils.timeAgo

    /// Matches UIKit demo `CreateChatViewController.throttleTime` / `CreateGroupViewController.throttleTime`.
    private let userSearchDebounceMilliseconds = 1000
    private var userSearchDebounceWorkItem: DispatchWorkItem?
    private var userSearchRequestGeneration: UInt64 = 0

    private struct ActiveUserSearch: Equatable {
        var apiTerm: String?
    }

    /// Last user-list query that finished successfully (`apiTerm == nil` is “all users”).
    private enum UserListFetchCursor: Equatable {
        case notYetFetched
        case fetched(apiTerm: String?)
    }

    private var activeUserSearch: ActiveUserSearch?
    private var userListFetchCursor: UserListFetchCursor = .notYetFetched

    init() {
        chatUsers = searchController.userArray
        searchController.delegate = self
        // Empty initial search to get all users (immediate — not debounced; same as UIKit `viewDidLoad`)
        performUserSearch(term: nil)
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
            "Online"
        } else if let lastActiveAt = user.lastActiveAt,
                  let timeAgo = lastSeenDateFormatter(lastActiveAt) {
            timeAgo
        } else {
            "Offline"
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
            searchController.loadNextUsers { [weak self] _ in
                guard let self = self else { return }
                self.chatUsers = self.searchController.userArray
                self.loadingNextUsers = false
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

    private func scheduleDebouncedUserSearch() {
        let nextTerm = normalizedUserSearchTerm(searchText)
        if let active = activeUserSearch, matchesUserSearchTerm(active.apiTerm, nextTerm) {
            return
        }
        if case let .fetched(prev) = userListFetchCursor,
           matchesUserSearchTerm(prev, nextTerm),
           state != .error {
            return
        }

        state = .loading
        userSearchDebounceWorkItem?.cancel()
        let query = searchText
        let work = DispatchWorkItem { [weak self] in
            self?.performUserSearch(term: query.isEmpty ? nil : query)
        }
        userSearchDebounceWorkItem = work
        DispatchQueue.main.asyncAfter(
            deadline: .now() + .milliseconds(userSearchDebounceMilliseconds),
            execute: work
        )
    }

    private func performUserSearch(term: String?) {
        if let active = activeUserSearch, matchesUserSearchTerm(active.apiTerm, term) {
            return
        }
        activeUserSearch = ActiveUserSearch(apiTerm: term)
        userSearchRequestGeneration += 1
        let generation = userSearchRequestGeneration
        state = .loading
        searchController.search(term: term) { [weak self] error in
            guard let self else { return }
            guard generation == self.userSearchRequestGeneration else { return }
            self.activeUserSearch = nil
            if error != nil {
                self.state = .error
            } else {
                self.userListFetchCursor = .fetched(apiTerm: term)
                self.state = self.chatUsers.isEmpty ? .noUsers : .loaded
            }
        }
    }

    private func normalizedUserSearchTerm(_ text: String) -> String? {
        text.isEmpty ? nil : text
    }

    private func matchesUserSearchTerm(_ lhs: String?, _ rhs: String?) -> Bool {
        switch (lhs, rhs) {
        case (nil, nil): true
        case let (l?, r?): l == r
        default: false
        }
    }

    private func makeChannelController() throws {
        let selectedUserIds = Set(selectedUsers.map(\.id))
        channelController = try chatClient.channelController(
            createDirectMessageChannelWith: selectedUserIds,
            name: nil,
            imageURL: nil,
            extraData: [:]
        )
        channelController?.synchronize { [weak self] error in
            if error != nil {
                self?.state = .error
                self?.updatingSelectedUsers = false
            } else {
                withAnimation {
                    self?.state = .channel
                    self?.updatingSelectedUsers = false
                }
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
