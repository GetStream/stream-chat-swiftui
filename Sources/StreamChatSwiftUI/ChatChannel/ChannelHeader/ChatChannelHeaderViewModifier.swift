//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View modifier for customizing the channel header.
public protocol ChatChannelHeaderViewModifier: ViewModifier {
    var channel: ChatChannel { get }
}

/// The default channel header.
public struct DefaultChatChannelHeader: ToolbarContent {
    @Injected(\.fonts) private var fonts
    @Injected(\.utils) private var utils
    @Injected(\.colors) private var colors
    @Injected(\.chatClient) private var chatClient
    
    private var channelNamer: ChatChannelNamer {
        utils.channelNamer
    }
    
    private var currentUserId: String {
        chatClient.currentUserId ?? ""
    }
    
    private var shouldShowTypingIndicator: Bool {
        !channel.currentlyTypingUsersFiltered(currentUserId: currentUserId).isEmpty
            && utils.typingIndicatorPlacement == .navigationBar
            && channel.config.typingEventsEnabled
    }
    
    private var onlineIndicatorShown: Bool {
        !channel.lastActiveMembers.filter { member in
            member.id != chatClient.currentUserId && member.isOnline
        }
        .isEmpty
    }
    
    public var channel: ChatChannel
    public var headerImage: UIImage
    
    public var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            VStack(spacing: 2) {
                Text(channelNamer(channel, currentUserId) ?? "")
                    .font(fonts.bodyBold)
                if shouldShowTypingIndicator {
                    HStack {
                        TypingIndicatorView()
                        SubtitleText(text: channel.typingIndicatorString(currentUserId: currentUserId))
                    }
                } else {
                    Text(channel.onlineInfoText(currentUserId: currentUserId))
                        .font(fonts.footnote)
                        .foregroundColor(Color(colors.textLowEmphasis))
                }
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            ChannelAvatarView(
                avatar: headerImage,
                showOnlineIndicator: onlineIndicatorShown,
                size: CGSize(width: 36, height: 36)
            )
            .offset(x: 8)
        }
    }
}

/// The default header modifier.
public struct DefaultChannelHeaderModifier: ChatChannelHeaderViewModifier {
    @StateObject private var channelHeaderLoader = ChannelHeaderLoader()
    
    public var channel: ChatChannel
    
    public func body(content: Content) -> some View {
        content.toolbar {
            DefaultChatChannelHeader(
                channel: channel,
                headerImage: channelHeaderLoader.image(for: channel)
            )
        }
    }
}
