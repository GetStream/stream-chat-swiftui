//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatCommonUI
import SwiftUI

public struct ChannelAvatar: View {
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    
    let url: URL?
    let size: CGFloat
    let showsIndicator: Bool
    let showsBorder: Bool
    let directMessageUser: UserDisplayInfo?
    
    public init(
        channel: ChatChannel,
        size: CGFloat,
        showsIndicator: Bool = false,
        showsBorder: Bool = true
    ) {
        url = channel.imageURL
        self.size = size
        self.showsBorder = showsBorder
        self.showsIndicator = showsIndicator
        directMessageUser = {
            guard channel.isDirectMessageChannel, channel.memberCount == 2 else { return nil }
            let currentUserId = InjectedValues[\.chatClient].currentUserId
            guard let member = channel.lastActiveMembers.first(where: { $0.id != currentUserId }) else { return nil }
            return UserDisplayInfo(member: member)
        }()
    }
    
    public var body: some View {
        if let directMessageUser {
            UserAvatar(
                user: directMessageUser,
                size: size,
                showsIndicator: showsIndicator,
                showsBorder: showsBorder
            )
            .accessibilityIdentifier("ChannelAvatar")
        } else {
            GroupAvatar(
                url: url,
                size: size,
                showsBorder: showsBorder
            )
            .accessibilityIdentifier("ChannelAvatar")
        }
    }
}

struct GroupAvatar: View {
    @Injected(\.colors) var colors
    let url: URL?
    let size: CGFloat
    let showsBorder: Bool
    
    init(url: URL?, size: CGFloat, showsBorder: Bool = true) {
        self.url = url
        self.size = size
        self.showsBorder = showsBorder
    }
    
    var body: some View {
        Avatar(
            url: url,
            placeholder: { _ in
                colors.avatarBgDefault.toColor
                    .overlay(
                        Image(systemName: "person.3")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: iconSize.width, height: iconSize.height)
                            .font(.system(size: iconSize.height, weight: .semibold))
                            .foregroundColor(colors.avatarTextDefault.toColor)
                    )
            },
            size: size,
            showsBorder: showsBorder
        )
        .cornerRadius(DesignSystemTokens.radiusMax)
    }
    
    var iconSize: CGSize {
        // Width is fine-tuned based on the icon symbol
        switch size {
        case AvatarSize.largeSizeClass: CGSize(width: 22, height: 20)
        case AvatarSize.mediumSizeClass: CGSize(width: 18, height: 16)
        case AvatarSize.smallSizeClass: CGSize(width: 14, height: 12)
        default: CGSize(width: 12, height: 10)
        }
    }
}

@available(iOS 26)
#Preview(traits: .fixedLayout(width: 200, height: 200)) {
    @Previewable let channelURL = URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/Aerial_view_of_the_Amazon_Rainforest.jpg/960px-Aerial_view_of_the_Amazon_Rainforest.jpg")!
    @Previewable let streamChat = StreamChat(chatClient: .init(config: .init(apiKeyString: "Preview")))
    HStack(spacing: 12) {
        VStack(spacing: 12) {
            ForEach(AvatarSize.standardSizes, id: \.self) { size in
                GroupAvatar(
                    url: channelURL,
                    size: size
                )
            }
        }
        VStack(spacing: 12) {
            ForEach(AvatarSize.standardSizes, id: \.self) { size in
                GroupAvatar(
                    url: nil,
                    size: size
                )
            }
        }
    }
    .padding()
}
