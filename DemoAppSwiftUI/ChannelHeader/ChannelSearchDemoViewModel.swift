//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI

/// Drives ``ChannelSearchDemoView`` on top of the state layer's `ChannelSearch`.
@MainActor class ChannelSearchDemoViewModel: ObservableObject {
    /// The searching object under test. The view observes its `state` for the results.
    let channelSearch: ChannelSearch

    @Published var searchText = ""
    @Published private(set) var isSearching = false
    @Published private(set) var errorMessage: String?

    private var isLoadingMore = false

    init() {
        channelSearch = InjectedValues[\.chatClient].makeChannelSearch()
    }

    func search(for text: String) {
        errorMessage = nil

        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            isSearching = false
            Task { [channelSearch] in
                try? await channelSearch.search(text: "")
            }
            return
        }

        isSearching = true
        Task { [weak self] in
            guard let self else { return }
            do {
                try await channelSearch.search(text: text)
            } catch {
                errorMessage = error.localizedDescription
            }
            // A search the debouncer superseded returns as soon as a newer one starts, so it
            // must not report that searching finished.
            if text == searchText {
                isSearching = false
            }
        }
    }

    func loadMoreIfNeeded(after channel: ChatChannel) {
        guard channel.cid == channelSearch.state.channels.last?.cid else { return }
        // The last row appears more than once, so overlapping pages are skipped.
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
