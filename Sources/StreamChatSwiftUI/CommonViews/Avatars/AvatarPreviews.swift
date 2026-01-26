//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

@available(iOS 26, *)
#Preview(traits: .fixedLayout(width: 700, height: 300)) {
    @Previewable let channelURL = URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/Aerial_view_of_the_Amazon_Rainforest.jpg/960px-Aerial_view_of_the_Amazon_Rainforest.jpg")!
    @Previewable let avatarURL = URL(string: "https://vignette.wikia.nocookie.net/starwars/images/b/b2/Padmegreenscrshot.jpg")!
    @Previewable let streamChat = StreamChat(chatClient: .init(config: .init(apiKeyString: "Preview")))
    
    HStack(spacing: 16) {
        // ChannelAvatar - With URL
        VStack(spacing: 12) {
            Text("Channel\nWith URL")
                .font(.caption2)
                .multilineTextAlignment(.center)
            ForEach(AvatarSize.standardSizes, id: \.self) { size in
                ChannelAvatar(
                    urls: [channelURL],
                    size: size
                )
            }
        }
        
        // ChannelAvatar - No URL (Placeholder)
        VStack(spacing: 12) {
            Text("Channel\nPlaceholder")
                .font(.caption2)
                .multilineTextAlignment(.center)
            ForEach(AvatarSize.standardSizes, id: \.self) { size in
                ChannelAvatar(
                    urls: [],
                    size: size
                )
            }
        }
        
        // ChannelAvatar - Redacted
        VStack(spacing: 12) {
            Text("Channel\nRedacted")
                .font(.caption2)
                .multilineTextAlignment(.center)
            ChannelAvatar(urls: [], size: AvatarSize.medium)
                .redacted(reason: .placeholder)
        }
        
        Divider()
        
        // UserAvatar - With URL and Initials
        VStack(spacing: 12) {
            Text("User\nWith URL")
                .font(.caption2)
                .multilineTextAlignment(.center)
            ForEach(AvatarSize.standardSizes, id: \.self) { size in
                UserAvatar(
                    url: avatarURL,
                    initials: "PA",
                    size: size,
                    indicator: .online
                )
            }
        }
        
        // UserAvatar - No URL with Initials
        VStack(spacing: 12) {
            Text("User\nInitials")
                .font(.caption2)
                .multilineTextAlignment(.center)
            ForEach(AvatarSize.standardSizes, id: \.self) { size in
                UserAvatar(
                    url: nil,
                    initials: "PA",
                    size: size,
                    indicator: .online
                )
            }
        }
        
        // UserAvatar - No URL, Empty Initials
        VStack(spacing: 12) {
            Text("User\nEmpty")
                .font(.caption2)
                .multilineTextAlignment(.center)
            ForEach(AvatarSize.standardSizes, id: \.self) { size in
                UserAvatar(
                    url: nil,
                    initials: "",
                    size: size,
                    indicator: .offline
                )
            }
        }
        
        // UserAvatar - Redacted
        VStack(spacing: 12) {
            Text("User\nRedacted")
                .font(.caption2)
                .multilineTextAlignment(.center)
            UserAvatar(
                url: nil,
                initials: "",
                size: AvatarSize.medium,
                indicator: .offline
            )
            .redacted(reason: .placeholder)
        }
    }
    .padding()
}
