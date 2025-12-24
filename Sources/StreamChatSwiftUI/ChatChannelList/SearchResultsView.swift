//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View displaying the search results in the channel list.
public struct SearchResultsView<Factory: ViewFactory>: View {
    @Injected(\.colors) private var colors

    var factory: Factory
    @Binding var selectedChannel: ChannelSelectionInfo?
    var searchResults: [ChannelSelectionInfo]
    var loadingSearchResults: Bool
    var onlineIndicatorShown: @MainActor (ChatChannel) -> Bool
    var channelNaming: @MainActor (ChatChannel) -> String
    var imageLoader: @MainActor (ChatChannel) -> UIImage
    var onSearchResultTap: @MainActor (ChannelSelectionInfo) -> Void
    var onItemAppear: @MainActor (Int) -> Void
    
    public init(
        factory: Factory,
        selectedChannel: Binding<ChannelSelectionInfo?>,
        searchResults: [ChannelSelectionInfo],
        loadingSearchResults: Bool,
        onlineIndicatorShown: @escaping @MainActor (ChatChannel) -> Bool,
        channelNaming: @escaping @MainActor (ChatChannel) -> String,
        imageLoader: @escaping @MainActor (ChatChannel) -> UIImage,
        onSearchResultTap: @escaping @MainActor (ChannelSelectionInfo) -> Void,
        onItemAppear: @escaping @MainActor (Int) -> Void
    ) {
        self.factory = factory
        _selectedChannel = selectedChannel
        self.searchResults = searchResults
        self.loadingSearchResults = loadingSearchResults
        self.onlineIndicatorShown = onlineIndicatorShown
        self.channelNaming = channelNaming
        self.imageLoader = imageLoader
        self.onSearchResultTap = onSearchResultTap
        self.onItemAppear = onItemAppear
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(L10n.Message.Search.numberOfResults(searchResults.count))
                    .foregroundColor(Color(colors.textLowEmphasis))
                    .standardPadding()
                Spacer()
            }

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(searchResults) { searchResult in
                        SearchResultView(
                            factory: factory,
                            selectedChannel: $selectedChannel,
                            searchResult: searchResult,
                            onlineIndicatorShown: onlineIndicatorShown(searchResult.channel),
                            channelName: channelNaming(searchResult.channel),
                            avatar: imageLoader(searchResult.channel),
                            onSearchResultTap: onSearchResultTap,
                            channelDestination: factory.makeChannelDestination(options: ChannelDestinationOptions())
                        )
                        .onAppear {
                            if let index = searchResults.firstIndex(where: { result in
                                result.id == searchResult.id
                            }) {
                                onItemAppear(index)
                            }
                        }
                    }
                }
            }
        }
        .overlay(
            loadingSearchResults ? ProgressView() : nil
        )
        .background(Color(colors.background))
    }
}

/// View for one search result item with navigation support.
struct SearchResultView<Factory: ViewFactory>: View {
    var factory: Factory
    @Binding var selectedChannel: ChannelSelectionInfo?
    var searchResult: ChannelSelectionInfo
    var onlineIndicatorShown: Bool
    var channelName: String
    var avatar: UIImage
    var onSearchResultTap: @MainActor (ChannelSelectionInfo) -> Void
    var channelDestination: @MainActor (ChannelSelectionInfo) -> Factory.ChannelDestination

    var body: some View {
        ZStack {
            factory.makeChannelListSearchResultItem(
                options: ChannelListSearchResultItemOptions(
                    searchResult: searchResult,
                    onlineIndicatorShown: onlineIndicatorShown,
                    channelName: channelName,
                    avatar: avatar,
                    onSearchResultTap: onSearchResultTap,
                    channelDestination: channelDestination
                )
            )

            NavigationLink(
                tag: searchResult,
                selection: $selectedChannel
            ) {
                LazyView(channelDestination(searchResult))
            } label: {
                EmptyView()
            }
            .opacity(0) // Fixes showing accessibility button shape
        }
    }
}

/// The search result item user interface.
struct SearchResultItem<Factory: ViewFactory, ChannelDestination: View>: View {
    @Injected(\.utils) private var utils

    var factory: Factory
    var searchResult: ChannelSelectionInfo
    var onlineIndicatorShown: Bool
    var channelName: String
    var avatar: UIImage
    var onSearchResultTap: (ChannelSelectionInfo) -> Void
    var channelDestination: (ChannelSelectionInfo) -> ChannelDestination

    var body: some View {
        Button {
            onSearchResultTap(searchResult)
        } label: {
            HStack {
                factory.makeChannelAvatarView(
                    options: ChannelAvatarViewFactoryOptions(
                        channel: searchResult.channel,
                        options: .init(showOnlineIndicator: onlineIndicatorShown, avatar: avatar)
                    )
                )

                VStack(alignment: .leading, spacing: 4) {
                    ChatTitleView(name: channelName)

                    HStack {
                        SubtitleText(text: messageText)
                        Spacer()
                        SubtitleText(text: timestampText)
                    }
                }
            }
            .padding(.all, 8)
        }
        .accessibilityIdentifier("SearchResultItem")
    }

    private var timestampText: String {
        if let lastMessageAt = searchResult.channel.lastMessageAt {
            let formatter = utils.messageTimestampFormatter
            return formatter.format(lastMessageAt)
        } else {
            return ""
        }
    }

    private var messageText: String {
        switch searchResult.searchType {
        case .channels:
            guard let previewMessage = searchResult.message else {
                return L10n.Channel.Item.emptyMessages
            }
            return utils.messagePreviewFormatter.format(previewMessage, in: searchResult.channel)
        case .messages:
            return searchResult.message?.text ?? ""
        default:
            return ""
        }
    }
}
