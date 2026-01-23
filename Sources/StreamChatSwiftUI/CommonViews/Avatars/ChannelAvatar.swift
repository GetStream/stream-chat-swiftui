//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatCommonUI
import SwiftUI

/// A view that renders a channel avatar, merging multiple member images when needed.
public struct ChannelAvatar: View {
    @Injected(\.colors) var colors
    @Injected(\.utils) var utils
    
    let urls: [URL]
    let indicator: AvatarIndicator
    let size: CGFloat
    let showsBorder: Bool
    
    /// Creates a channel avatar from a chat channel.
    ///
    /// - Parameters:
    ///   - channel: The channel whose avatar to display.
    ///   - size: The width and height of the avatar.
    ///   - showsIndicator: A Boolean value that indicates whether to show the
    ///     online status for direct message channels. Defaults to `false`.
    ///   - showsBorder: A Boolean value that indicates whether to show a circular
    ///     border around the avatar. Defaults to `true`.
    public init(
        channel: ChatChannel,
        size: CGFloat,
        showsIndicator: Bool = false,
        showsBorder: Bool = true
    ) {
        self.init(
            urls: channel.avatarURLs,
            size: size,
            indicator: showsIndicator ? channel.avatarIndicator : .none,
            showsBorder: showsBorder
        )
    }
    
    /// Creates a channel avatar from image URLs.
    ///
    /// - Parameters:
    ///   - urls: The URLs of the images to display. When multiple URLs are
    ///     provided, they are merged into a single avatar.
    ///   - size: The width and height of the avatar.
    ///   - indicator: The presence indicator to display. Defaults to no indicator.
    ///   - showsBorder: A Boolean value that indicates whether to show a circular
    ///     border around the avatar. Defaults to `true`.
    public init(
        urls: [URL],
        size: CGFloat,
        indicator: AvatarIndicator = .none,
        showsBorder: Bool = true
    ) {
        self.indicator = indicator
        self.size = size
        self.urls = urls
        self.showsBorder = showsBorder
    }
    
    public var body: some View {
        StreamAsyncImage(urls: urls, size: size) { phase in
            Group {
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .overlay(
                            showsBorder ? Circle().strokeBorder(colors.borderCoreImage.toColor, lineWidth: 1) : nil
                        )
                case .empty, .loading:
                    PlaceholderView(size: size)
                }
            }
        } imageMerger: { images in
            let options = ChannelAvatarsMergerOptions()
            let merger = utils.channelAvatarsMerger
            return await withTaskGroup(of: UIImage?.self, returning: UIImage?.self) { [options] group in
                group.addTask {
                    merger.createMergedAvatar(from: images, options: options)
                }
                if let image = await group.next() {
                    return image
                }
                return nil
            }
        }
        .cornerRadius(DesignSystemTokens.radiusMax)
        .avatarIndicator(indicator, size: size)
        .accessibilityIdentifier("ChannelAvatar")
    }
}
 
extension ChannelAvatar {
    struct PlaceholderView: View {
        @Injected(\.colors) var colors
        @Injected(\.images) var images
        
        let size: CGFloat
        
        var body: some View {
            colors.avatarBgDefault.toColor
                .overlay(
                    Image(uiImage: images.channelAvatarPlaceholder)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: iconSize.width, height: iconSize.height)
                        .font(.system(size: iconSize.height, weight: .semibold))
                        .foregroundColor(colors.avatarTextDefault.toColor)
                )
        }
        
        var iconSize: CGSize {
            // Width is fine-tuned based on the icon symbol
            switch size {
            case AvatarSize.sizeClassLarge: CGSize(width: 22, height: 20)
            case AvatarSize.sizeClassMedium: CGSize(width: 18, height: 16)
            case AvatarSize.sizeClassSmall: CGSize(width: 14, height: 12)
            default: CGSize(width: 12, height: 10)
            }
        }
    }
}

private extension ChatChannel {
    @MainActor var avatarURLs: [URL] {
        if let imageURL {
            return [imageURL]
        }
        let currentUserId = InjectedValues[\.chatClient].currentUserId
        return Array(lastActiveMembers.filter({ $0.id != currentUserId }).sorted(by: { $0.memberCreatedAt < $1.memberCreatedAt }).compactMap(\.imageURL).prefix(4))
    }
    
    @MainActor var avatarIndicator: AvatarIndicator {
        guard isDirectMessageChannel, memberCount == 2 else { return .none }
        let currentUserId = InjectedValues[\.chatClient].currentUserId
        guard let otherMember = lastActiveMembers.first(where: { $0.id != currentUserId }) else { return .none }
        return otherMember.isOnline ? .online : .offline
    }
}

@available(iOS 26, *)
#Preview(traits: .fixedLayout(width: 200, height: 200)) {
    @Previewable let channelURL = URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/Aerial_view_of_the_Amazon_Rainforest.jpg/960px-Aerial_view_of_the_Amazon_Rainforest.jpg")!
    @Previewable let streamChat = StreamChat(chatClient: .init(config: .init(apiKeyString: "Preview")))
    HStack(spacing: 12) {
        VStack(spacing: 12) {
            ForEach(AvatarSize.standardSizes, id: \.self) { size in
                ChannelAvatar(
                    urls: [channelURL],
                    size: size
                )
            }
        }
        VStack(spacing: 12) {
            ForEach(AvatarSize.standardSizes, id: \.self) { size in
                ChannelAvatar(
                    urls: [],
                    size: size
                )
            }
        }
    }
    .padding()
}
