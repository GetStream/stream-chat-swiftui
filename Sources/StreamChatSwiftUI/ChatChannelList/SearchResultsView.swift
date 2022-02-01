//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct SearchResultsView<Factory: ViewFactory>: View {
    
    @Injected(\.colors) private var colors
    
    var factory: Factory
    @Binding var selectedChannel: ChannelSelectionInfo?
    var searchResults: [ChannelSelectionInfo]
    var onlineIndicatorShown: (ChatChannel) -> Bool
    var channelNaming: (ChatChannel) -> String
    var imageLoader: (ChatChannel) -> UIImage
    var onSearchResultTap: (ChannelSelectionInfo) -> Void
    var onItemAppear: (Int) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("\(searchResults.count) results")
                    .foregroundColor(Color(colors.textLowEmphasis))
                    .standardPadding()
                Spacer()
            }
            .background(Color(colors.background1))
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(searchResults) { searchResult in
                        SearchResultView(
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
    }
}

struct SearchResultView<ChannelDestination: View>: View {
    
    @Injected(\.utils) private var utils
    
    @Binding var selectedChannel: ChannelSelectionInfo?
    var searchResult: ChannelSelectionInfo
    var onlineIndicatorShown: Bool
    var channelName: String
    var avatar: UIImage
    var onSearchResultTap: (ChannelSelectionInfo) -> Void
    var channelDestination: (ChannelSelectionInfo) -> ChannelDestination
    
    var body: some View {
        ZStack {
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
    
    private var timestampText: String {
        if let lastMessageAt = searchResult.channel.lastMessageAt {
            return utils.dateFormatter.string(from: lastMessageAt)
        } else {
            return ""
        }
    }
}
