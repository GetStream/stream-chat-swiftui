//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Dispatch
import StreamChat
import StreamChatCommonUI
import StreamChatSwiftUI
import SwiftUI

@MainActor class CreateGroupViewModel: ObservableObject, ChatUserSearchControllerDelegate {
    @Injected(\.chatClient) var chatClient

    var channelController: ChatChannelController!

    @Published var searchText = "" {
        didSet {
            scheduleDebouncedUserSearch()
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

    /// Matches UIKit demo `CreateGroupViewController.throttleTime`.
    private let userSearchDebounceMilliseconds = 1000
    private var userSearchDebounceWorkItem: DispatchWorkItem?
    private var userSearchRequestGeneration: UInt64 = 0

    init() {
        chatUsers = searchController.userArray
        searchController.delegate = self
        // Empty initial search to get all users (immediate — not debounced)
        performUserSearch(term: nil)
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

    func showChannelView() {
        do {
            channelController = try chatClient.channelController(
                createChannelWithId: .init(
                    type: .messaging,
                    id: String(UUID().uuidString.prefix(10))
                ),
                name: groupName,
                members: Set(selectedUsers.map(\.id))
            )
            channelController.synchronize { [weak self] error in
                if error != nil {
                    self?.errorShown = true
                } else {
                    self?.showGroupConversation = true
                }
            }

        } catch {
            errorShown = true
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
        userSearchRequestGeneration += 1
        let generation = userSearchRequestGeneration
        state = .loading
        searchController.search(term: term) { [weak self] error in
            guard let self else { return }
            guard generation == self.userSearchRequestGeneration else { return }
            if error != nil {
                self.state = .error
            } else {
                self.state = self.chatUsers.isEmpty ? .noUsers : .loaded
            }
        }
    }
}
