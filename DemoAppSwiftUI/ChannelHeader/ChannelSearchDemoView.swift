//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI

/// A scratch screen for exercising the state layer's `ChannelSearch`.
///
/// It shows the debounced searching, the live results, and pagination when scrolling to the end
/// of the list.
struct ChannelSearchDemoView: View {
    @Injected(\.colors) var colors

    @StateObject private var viewModel = ChannelSearchDemoViewModel()

    var body: some View {
        VStack(spacing: 0) {
            searchField
            statusBar
            Divider()
            ChannelSearchResultsView(
                state: viewModel.channelSearch.state,
                loadMoreIfNeeded: viewModel.loadMoreIfNeeded(after:)
            )
        }
        .background(Color(colors.backgroundCoreElevation0).ignoresSafeArea())
        .navigationTitle("Channel Search")
        .onChange(of: viewModel.searchText) { text in
            viewModel.search(for: text)
        }
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color(colors.textTertiary))

            TextField("Search channels by name", text: $viewModel.searchText)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .foregroundColor(Color(colors.textPrimary))

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color(colors.textTertiary))
                }
                .accessibilityLabel(Text("Clear search"))
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 44)
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color(colors.textTertiary).opacity(0.4), lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var statusBar: some View {
        HStack(spacing: 8) {
            if viewModel.isSearching {
                ProgressView()
                    .scaleEffect(0.7)
            }
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundColor(.red)
            }
            Spacer()
        }
        .frame(height: 20)
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }
}

/// Renders the results by observing the search state directly.
private struct ChannelSearchResultsView: View {
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts

    @ObservedObject var state: ChannelSearchState
    var loadMoreIfNeeded: (ChatChannel) -> Void

    var body: some View {
        if state.channels.isEmpty {
            VStack {
                Text(placeholder)
                    .font(fonts.body)
                    .foregroundColor(Color(colors.textSecondary))
                    .multilineTextAlignment(.center)
                    .padding(32)
                Spacer()
            }
        } else {
            List(state.channels, id: \.cid) { channel in
                row(for: channel)
                    .onAppear { loadMoreIfNeeded(channel) }
            }
            .listStyle(.plain)
        }
    }

    private var placeholder: String {
        state.query == nil
            ? "Search for channels you are a member of."
            : "No channels match this search."
    }

    private func row(for channel: ChatChannel) -> some View {
        HStack(spacing: 12) {
            UserAvatar(
                url: channel.imageURL,
                initials: initials(for: channel),
                size: 40,
                indicator: .none
            )
            VStack(alignment: .leading, spacing: 2) {
                Text(channel.name ?? channel.cid.id)
                    .font(fonts.bodyBold)
                    .foregroundColor(Color(colors.textPrimary))
                Text("\(channel.memberCount) members · \(channel.cid.id)")
                    .font(fonts.footnote)
                    .foregroundColor(Color(colors.textSecondary))
                    .lineLimit(1)
            }
            Spacer()
        }
    }

    private func initials(for channel: ChatChannel) -> String {
        let name = channel.name ?? channel.cid.id
        return name.split(separator: " ").compactMap { $0.first.map(String.init) }.joined()
    }
}
