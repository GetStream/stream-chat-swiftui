//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI

import SwiftUI

struct WhatsAppChannelHeaderModifier: ChatChannelHeaderViewModifier {
    
    let channel: ChatChannel
    
    func body(content: Content) -> some View {
        content.toolbar {
            WhatsAppChannelHeader(channel: channel)
        }
    }
}

struct WhatsAppChannelHeader: ToolbarContent {
    
    @ObservedObject private var channelHeaderLoader = InjectedValues[\.utils].channelHeaderLoader
    
    @Injected(\.chatClient) var chatClient
    @Injected(\.utils) var utils
    @Injected(\.fonts) var fonts
    @Injected(\.colors) var colors
    
    var channel: ChatChannel
    
    private var currentUserId: String {
        chatClient.currentUserId ?? ""
    }
    
    private var channelNamer: ChatChannelNamer {
        utils.channelNamer
    }
    
    private var channelSubtitle: String {
        if channel.memberCount <= 2 {
            return channel.onlineInfoText(currentUserId: currentUserId)
        } else {
            return channel
                .lastActiveMembers
                .map { $0.name ?? $0.id }
                .joined(separator: ", ")
        }
    }
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            HStack {
                ChannelAvatarView(
                    avatar: channelHeaderLoader.image(for: channel),
                    showOnlineIndicator: false,
                    size: CGSize(width: 36, height: 36)
                )
                VStack(alignment: .leading) {
                    Text(channelNamer(channel, currentUserId) ?? "")
                        .font(fonts.bodyBold)
                    Text(channelSubtitle)
                        .font(fonts.caption1)
                        .foregroundColor(Color(colors.textLowEmphasis))
                }
            }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            HStack {
                Button(action: {
                    print("tapped on video")
                }, label: {
                    Image(systemName: "video")
                })
                Button(action: {
                    print("tapped on audio")
                }, label: {
                    Image(systemName: "phone")
                })
            }
        }
    }
}
