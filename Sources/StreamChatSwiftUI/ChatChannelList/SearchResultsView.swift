//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct SearchResultsView: View {
    
    var searchResults: [SearchResult]
    var onlineIndicatorShown: (ChatChannel) -> Bool
    var channelNaming: (ChatChannel) -> String
    var imageLoader: (ChatChannel) -> UIImage
    var onSearchResultTap: (SearchResult) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(searchResults) { searchResult in
                    SearchResultView(
                        searchResult: searchResult,
                        onlineIndicatorShown: onlineIndicatorShown(searchResult.channel),
                        channelName: channelNaming(searchResult.channel),
                        avatar: imageLoader(searchResult.channel),
                        onSearchResultTap: onSearchResultTap
                    )
                }
            }
        }
    }
}

struct SearchResultView: View {
    
    @Injected(\.utils) private var utils
    
    var searchResult: SearchResult
    var onlineIndicatorShown: Bool
    var channelName: String
    var avatar: UIImage
    var onSearchResultTap: (SearchResult) -> Void
    
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
                        SubtitleText(text: searchResult.channel.lastMessageText ?? "")
                        Spacer()
                        SubtitleText(text: timestampText)
                    }
                }
            }
            .padding(.all, 8)
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

public struct SearchResult: Identifiable {
    public var id: String {
        "\(channel.id)-\(message.id)"
    }

    public let channel: ChatChannel
    public let message: ChatMessage
}
