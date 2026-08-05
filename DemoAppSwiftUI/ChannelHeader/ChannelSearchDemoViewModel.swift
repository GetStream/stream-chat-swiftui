//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI

/// Preview row cap for the combined search screen. Each search passes this as `pageSize` to the API.
enum MultiSearchDemo {
    static let previewLimit = 3
}

enum MultiSearchSection: String, CaseIterable, Identifiable {
    case channels
    case messages
    case users

    var id: String { rawValue }

    var title: String {
        switch self {
        case .channels: return "Channels"
        case .messages: return "Messages"
        case .users: return "People"
        }
    }

    var systemImage: String {
        switch self {
        case .channels: return "number"
        case .messages: return "bubble.left.and.bubble.right"
        case .users: return "person"
        }
    }
}

/// Runs channel, message, and user searches in parallel through the state layer.
@MainActor final class MultiSearchDemoViewModel: ObservableObject {
    private let chatClient: ChatClient
    let channelSearch: ChannelSearch
    let messageSearch: MessageSearch
    let userSearch: UserSearch

    @Published var searchText = ""
    @Published private(set) var isSearching = false
    @Published private(set) var errorMessage: String?

    init(chatClient: ChatClient = InjectedValues[\.chatClient]) {
        self.chatClient = chatClient
        channelSearch = chatClient.makeChannelSearch()
        messageSearch = chatClient.makeMessageSearch()
        userSearch = chatClient.makeUserSearch()
    }

    func search(for text: String) {
        errorMessage = nil
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            isSearching = false
            Task {
                try? await channelSearch.search(text: "")
                try? await messageSearch.search(text: "")
            }
            return
        }

        isSearching = true
        Task { [weak self] in
            guard let self else { return }
            guard chatClient.currentUserId != nil else {
                errorMessage = "You must be logged in to search."
                isSearching = false
                return
            }
            do {
                try await performParallelSearch(for: trimmed)
            } catch {
                errorMessage = error.localizedDescription
            }
            if trimmed == searchText.trimmingCharacters(in: .whitespacesAndNewlines) {
                isSearching = false
            }
        }
    }

    private func performParallelSearch(for text: String) async throws {
        guard let currentUserId = chatClient.currentUserId else { return }

        let messageQuery = MessageSearchQuery(
            channelFilter: .containMembers(userIds: [currentUserId]),
            messageFilter: .autocomplete(.text, text: text),
            sort: [.init(key: .createdAt, isAscending: false)],
            pageSize: MultiSearchDemo.previewLimit
        )

        var userQuery = UserListQuery.search(term: text)
        userQuery.pagination = Pagination(pageSize: MultiSearchDemo.previewLimit)

        var channelQuery = ChannelListQuery(
            filter: .and([
                .autocomplete(.name, text: text),
                .containMembers(userIds: [currentUserId])
            ]),
            pageSize: MultiSearchDemo.previewLimit
        )
        channelQuery.options = []

        async let channels = channelSearch.search(query: channelQuery)
        async let messages = messageSearch.search(query: messageQuery)
        async let users = userSearch.search(query: userQuery)
        _ = try await (channels, messages, users)
    }
}

/// Full channel search for the drill-down screen.
@MainActor final class ChannelSearchDetailViewModel: ObservableObject {
    let channelSearch: ChannelSearch

    @Published private(set) var isSearching = false
    @Published private(set) var errorMessage: String?

    private var isLoadingMore = false

    init(chatClient: ChatClient = InjectedValues[\.chatClient]) {
        channelSearch = chatClient.makeChannelSearch()
    }

    func search(for text: String) {
        errorMessage = nil
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            isSearching = false
            Task { try? await channelSearch.search(text: "") }
            return
        }

        isSearching = true
        Task { [weak self] in
            guard let self else { return }
            do {
                try await channelSearch.search(text: trimmed)
            } catch {
                errorMessage = error.localizedDescription
            }
            isSearching = false
        }
    }

    func loadMoreIfNeeded(after channel: ChatChannel) {
        guard channel.cid == channelSearch.state.channels.last?.cid else { return }
        guard !isLoadingMore else { return }
        isLoadingMore = true
        Task { [weak self] in
            guard let self else { return }
            do {
                try await channelSearch.loadMoreChannels()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoadingMore = false
        }
    }
}

/// Full message search for the drill-down screen.
@MainActor final class MessageSearchDetailViewModel: ObservableObject {
    let messageSearch: MessageSearch

    @Published private(set) var isSearching = false
    @Published private(set) var errorMessage: String?

    private var isLoadingMore = false

    init(chatClient: ChatClient = InjectedValues[\.chatClient]) {
        messageSearch = chatClient.makeMessageSearch()
    }

    func search(for text: String) {
        errorMessage = nil
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            isSearching = false
            Task { try? await messageSearch.search(text: "") }
            return
        }

        isSearching = true
        Task { [weak self] in
            guard let self else { return }
            do {
                try await messageSearch.search(text: trimmed)
            } catch {
                errorMessage = error.localizedDescription
            }
            isSearching = false
        }
    }

    func loadMoreIfNeeded(after message: ChatMessage) {
        guard message.id == messageSearch.state.messages.last?.id else { return }
        guard !isLoadingMore else { return }
        isLoadingMore = true
        Task { [weak self] in
            guard let self else { return }
            do {
                try await messageSearch.loadMoreMessages()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoadingMore = false
        }
    }
}

/// Full user search for the drill-down screen.
@MainActor final class UserSearchDetailViewModel: ObservableObject {
    let userSearch: UserSearch

    @Published private(set) var isSearching = false
    @Published private(set) var errorMessage: String?

    private var isLoadingMore = false

    init(chatClient: ChatClient = InjectedValues[\.chatClient]) {
        userSearch = chatClient.makeUserSearch()
    }

    func search(for text: String) {
        errorMessage = nil
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            isSearching = false
            Task { try? await userSearch.search(term: nil) }
            return
        }

        isSearching = true
        Task { [weak self] in
            guard let self else { return }
            do {
                try await userSearch.search(term: trimmed)
            } catch {
                errorMessage = error.localizedDescription
            }
            isSearching = false
        }
    }

    func loadMoreIfNeeded(after user: ChatUser) {
        guard user.id == userSearch.state.users.last?.id else { return }
        guard !isLoadingMore else { return }
        isLoadingMore = true
        Task { [weak self] in
            guard let self else { return }
            do {
                try await userSearch.loadMoreUsers()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoadingMore = false
        }
    }
}
