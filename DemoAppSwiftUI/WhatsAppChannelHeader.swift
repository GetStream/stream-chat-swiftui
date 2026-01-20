//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
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
    @Injected(\.chatClient) var chatClient
    @Injected(\.utils) var utils
    @Injected(\.fonts) var fonts
    @Injected(\.colors) var colors
    
    var channel: ChatChannel
    
    private var currentUserId: String {
        chatClient.currentUserId ?? ""
    }
    
    private var channelSubtitle: String {
        if channel.memberCount <= 2 {
            channel.onlineInfoText(currentUserId: currentUserId)
        } else {
            channel
                .lastActiveMembers
                .map { $0.name ?? $0.id }
                .joined(separator: ", ")
        }
    }
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            HStack {
                ChannelAvatar(channel: channel, size: .md)
                VStack(alignment: .leading) {
                    Text(name(for: channel))
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
    
    private func name(for channel: ChatChannel) -> String {
        utils.channelNameFormatter.format(
            channel: channel,
            forCurrentUserId: chatClient.currentUserId
        ) ?? ""
    }
}
