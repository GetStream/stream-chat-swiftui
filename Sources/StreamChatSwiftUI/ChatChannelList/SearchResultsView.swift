//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View displaying the search results in the channel list.
struct SearchResultsView<Factory: ViewFactory>: View {
    
    @Injected(\.colors) private var colors
    
    var factory: Factory
    @Binding var selectedChannel: ChannelSelectionInfo?
    var searchResults: [ChannelSelectionInfo]
    var loadingSearchResults: Bool
    var onlineIndicatorShown: (ChatChannel) -> Bool
    var channelNaming: (ChatChannel) -> String
    var imageLoader: (ChatChannel) -> UIImage
    var onSearchResultTap: (ChannelSelectionInfo) -> Void
    var onItemAppear: (Int) -> Void
    
    var body: some View {
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
                            channelDestination: factory.makeChannelDestination()
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
    var onSearchResultTap: (ChannelSelectionInfo) -> Void
    var channelDestination: (ChannelSelectionInfo) -> Factory.ChannelDestination
    
    var body: some View {
        ZStack {
            factory.makeChannelListSearchResultItem(
                searchResult: searchResult,
                onlineIndicatorShown: onlineIndicatorShown,
                channelName: channelName,
                avatar: avatar,
                onSearchResultTap: onSearchResultTap,
                channelDestination: channelDestination
            )
            
            NavigationLink(
                tag: searchResult,
                selection: $selectedChannel
            ) {
                LazyView(channelDestination(searchResult))
            } label: {
                EmptyView()
            }
        }
    }
}

/// The search result item user interface.
struct SearchResultItem<ChannelDestination: View>: View {
    
    @Injected(\.utils) private var utils
    
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
                ChannelAvatarView(
                    avatar: avatar,
                    showOnlineIndicator: onlineIndicatorShown
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    ChatTitleView(name: channelName)
                    
                    HStack {
                        SubtitleText(text: searchResult.message?.text ?? "")
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
            return utils.dateFormatter.string(from: lastMessageAt)
        } else {
            return ""
        }
    }
}
