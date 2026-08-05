//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI

/// Combined search prototype: channels, messages, and users in parallel using the state layer.
@MainActor
struct MultiSearchDemoView: View {
    @StateObject private var viewModel = MultiSearchDemoViewModel()

    var body: some View {
        MultiSearchDemoContent(
            viewModel: viewModel,
            channelState: viewModel.channelSearch.state,
            messageState: viewModel.messageSearch.state,
            userState: viewModel.userSearch.state
        )
    }
}

@MainActor
private struct MultiSearchDemoContent: View {
    @Injected(\.colors) var colors

    @ObservedObject var viewModel: MultiSearchDemoViewModel
    @ObservedObject var channelState: ChannelSearchState
    @ObservedObject var messageState: MessageSearchState
    @ObservedObject var userState: UserSearchState

    var body: some View {
        VStack(spacing: 0) {
            searchField
            statusBar
            Divider()
            results
        }
        .background(Color(colors.backgroundCoreElevation0).ignoresSafeArea())
        .navigationTitle("Multi Search")
        .onChange(of: viewModel.searchText) { text in
            viewModel.search(for: text)
        }
    }

    private var trimmedSearchText: String {
        viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func hasResults(for section: MultiSearchSection) -> Bool {
        switch section {
        case .channels: return !channelState.channels.isEmpty
        case .messages: return !messageState.messages.isEmpty
        case .users: return !userState.users.isEmpty
        }
    }

    private func hasMoreResults(for section: MultiSearchSection) -> Bool {
        switch section {
        case .channels:
            return channelState.channels.count >= MultiSearchDemo.previewLimit
        case .messages:
            return messageState.messages.count >= MultiSearchDemo.previewLimit
        case .users:
            return userState.users.count >= MultiSearchDemo.previewLimit
        }
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color(colors.textTertiary))

            TextField("Search", text: $viewModel.searchText)
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

    @ViewBuilder
    private var results: some View {
        if trimmedSearchText.isEmpty {
            placeholder("Search channels, messages, and people.")
        } else if !viewModel.isSearching && MultiSearchSection.allCases.allSatisfy({ !hasResults(for: $0) }) {
            placeholder("No results match this search.")
        } else {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    ForEach(MultiSearchSection.allCases) { section in
                        if hasResults(for: section) {
                            MultiSearchSectionView(
                                section: section,
                                searchText: viewModel.searchText,
                                hasMoreResults: hasMoreResults(for: section),
                                channels: channelState.channels,
                                messages: messageState.messages,
                                users: userState.users
                            )
                        }
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }

    private func placeholder(_ text: String) -> some View {
        VStack {
            Text(text)
                .font(InjectedValues[\.fonts].body)
                .foregroundColor(Color(colors.textSecondary))
                .multilineTextAlignment(.center)
                .padding(32)
            Spacer()
        }
    }
}

@MainActor
private struct MultiSearchSectionView: View {
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts

    let section: MultiSearchSection
    let searchText: String
    let hasMoreResults: Bool
    let channels: [ChatChannel]
    let messages: [ChatMessage]
    let users: [ChatUser]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            NavigationLink {
                detailView
            } label: {
                sectionHeader
            }
            .buttonStyle(.plain)

            sectionRows
        }
    }

    private var sectionHeader: some View {
        HStack(spacing: 10) {
            Image(systemName: section.systemImage)
                .font(.body.weight(.semibold))
                .foregroundColor(Color(colors.accentPrimary))
                .frame(width: 28, height: 28)
                .background(Color(colors.accentPrimary).opacity(0.12))
                .clipShape(Circle())

            Text(section.title)
                .font(fonts.bodyBold)
                .foregroundColor(Color(colors.textPrimary))

            Spacer()

            if hasMoreResults {
                Text("See All")
                    .font(fonts.footnote)
                    .foregroundColor(Color(colors.accentPrimary))
            }

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundColor(Color(colors.textTertiary))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint(Text("Show all \(section.title.lowercased()) results"))
    }

    @ViewBuilder
    private var sectionRows: some View {
        switch section {
        case .channels:
            ForEach(channels, id: \.cid) { channel in
                ChannelSearchRow(channel: channel)
            }
        case .messages:
            ForEach(messages, id: \.id) { message in
                MessageSearchRow(message: message)
            }
        case .users:
            ForEach(users, id: \.id) { user in
                UserSearchRow(user: user)
            }
        }
    }

    @ViewBuilder
    private var detailView: some View {
        switch section {
        case .channels:
            ChannelSearchDetailView(searchText: searchText)
        case .messages:
            MessageSearchDetailView(searchText: searchText)
        case .users:
            UserSearchDetailView(searchText: searchText)
        }
    }
}

// MARK: - Detail Screens

@MainActor
struct ChannelSearchDetailView: View {
    let searchText: String
    @StateObject private var viewModel = ChannelSearchDetailViewModel()

    var body: some View {
        ChannelSearchDetailContent(
            searchText: searchText,
            viewModel: viewModel,
            state: viewModel.channelSearch.state
        )
    }
}

@MainActor
private struct ChannelSearchDetailContent: View {
    @Injected(\.colors) var colors

    let searchText: String
    @ObservedObject var viewModel: ChannelSearchDetailViewModel
    @ObservedObject var state: ChannelSearchState

    var body: some View {
        VStack(spacing: 0) {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundColor(.red)
                    .padding()
            }

            if viewModel.isSearching && state.channels.isEmpty {
                Spacer()
                ProgressView()
                Spacer()
            } else if state.channels.isEmpty {
                emptyState("No channels match this search.")
            } else {
                List(state.channels, id: \.cid) { channel in
                    ChannelSearchRow(channel: channel)
                        .onAppear { viewModel.loadMoreIfNeeded(after: channel) }
                }
                .listStyle(.plain)
            }
        }
        .background(Color(colors.backgroundCoreElevation0).ignoresSafeArea())
        .navigationTitle("Channels")
        .onAppear { viewModel.search(for: searchText) }
    }

    private func emptyState(_ text: String) -> some View {
        VStack {
            Text(text)
                .font(InjectedValues[\.fonts].body)
                .foregroundColor(Color(colors.textSecondary))
                .multilineTextAlignment(.center)
                .padding(32)
            Spacer()
        }
    }
}

@MainActor
struct MessageSearchDetailView: View {
    let searchText: String
    @StateObject private var viewModel = MessageSearchDetailViewModel()

    var body: some View {
        MessageSearchDetailContent(
            searchText: searchText,
            viewModel: viewModel,
            state: viewModel.messageSearch.state
        )
    }
}

@MainActor
private struct MessageSearchDetailContent: View {
    @Injected(\.colors) var colors

    let searchText: String
    @ObservedObject var viewModel: MessageSearchDetailViewModel
    @ObservedObject var state: MessageSearchState

    var body: some View {
        VStack(spacing: 0) {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundColor(.red)
                    .padding()
            }

            if viewModel.isSearching && state.messages.isEmpty {
                Spacer()
                ProgressView()
                Spacer()
            } else if state.messages.isEmpty {
                emptyState("No messages match this search.")
            } else {
                List(state.messages, id: \.id) { message in
                    MessageSearchRow(message: message)
                        .onAppear { viewModel.loadMoreIfNeeded(after: message) }
                }
                .listStyle(.plain)
            }
        }
        .background(Color(colors.backgroundCoreElevation0).ignoresSafeArea())
        .navigationTitle("Messages")
        .onAppear { viewModel.search(for: searchText) }
    }

    private func emptyState(_ text: String) -> some View {
        VStack {
            Text(text)
                .font(InjectedValues[\.fonts].body)
                .foregroundColor(Color(colors.textSecondary))
                .multilineTextAlignment(.center)
                .padding(32)
            Spacer()
        }
    }
}

@MainActor
struct UserSearchDetailView: View {
    let searchText: String
    @StateObject private var viewModel = UserSearchDetailViewModel()

    var body: some View {
        UserSearchDetailContent(
            searchText: searchText,
            viewModel: viewModel,
            state: viewModel.userSearch.state
        )
    }
}

@MainActor
private struct UserSearchDetailContent: View {
    @Injected(\.colors) var colors

    let searchText: String
    @ObservedObject var viewModel: UserSearchDetailViewModel
    @ObservedObject var state: UserSearchState

    var body: some View {
        VStack(spacing: 0) {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundColor(.red)
                    .padding()
            }

            if viewModel.isSearching && state.users.isEmpty {
                Spacer()
                ProgressView()
                Spacer()
            } else if state.users.isEmpty {
                emptyState("No people match this search.")
            } else {
                List(state.users, id: \.id) { user in
                    UserSearchRow(user: user)
                        .onAppear { viewModel.loadMoreIfNeeded(after: user) }
                }
                .listStyle(.plain)
            }
        }
        .background(Color(colors.backgroundCoreElevation0).ignoresSafeArea())
        .navigationTitle("People")
        .onAppear { viewModel.search(for: searchText) }
    }

    private func emptyState(_ text: String) -> some View {
        VStack {
            Text(text)
                .font(InjectedValues[\.fonts].body)
                .foregroundColor(Color(colors.textSecondary))
                .multilineTextAlignment(.center)
                .padding(32)
            Spacer()
        }
    }
}

// MARK: - Rows

@MainActor
private struct ChannelSearchRow: View {
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts

    let channel: ChatChannel

    var body: some View {
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
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private func initials(for channel: ChatChannel) -> String {
        let name = channel.name ?? channel.cid.id
        return name.split(separator: " ").compactMap { $0.first.map(String.init) }.joined()
    }
}

@MainActor
private struct MessageSearchRow: View {
    @Injected(\.chatClient) var chatClient
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts

    let message: ChatMessage

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "text.bubble")
                .font(.title3)
                .foregroundColor(Color(colors.textTertiary))
                .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(channelTitle)
                    .font(fonts.bodyBold)
                    .foregroundColor(Color(colors.textPrimary))
                    .lineLimit(1)

                Text(messageText)
                    .font(fonts.body)
                    .foregroundColor(Color(colors.textSecondary))
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private var channelTitle: String {
        guard let cid = message.cid else { return "Message" }
        return chatClient.channelController(for: cid).channel?.name ?? cid.id
    }

    private var messageText: String {
        message.text.isEmpty ? "Attachment" : message.text
    }
}

@MainActor
private struct UserSearchRow: View {
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts

    let user: ChatUser

    var body: some View {
        HStack(spacing: 12) {
            UserAvatar(
                url: user.imageURL,
                initials: user.name ?? user.id,
                size: 40,
                indicator: user.isOnline ? .online : .none
            )
            VStack(alignment: .leading, spacing: 2) {
                Text(user.name ?? user.id)
                    .font(fonts.bodyBold)
                    .foregroundColor(Color(colors.textPrimary))
                Text(user.id)
                    .font(fonts.footnote)
                    .foregroundColor(Color(colors.textSecondary))
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}
