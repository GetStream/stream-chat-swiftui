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
    
    let indicator: AvatarIndicator
    let memberCount: Int
    let size: CGFloat
    let showsBorder: Bool
    let stackedPlaceholders: [(url: URL?, initials: String)]
    let url: URL?
    
    /// Creates a channel avatar from a chat channel.
    ///
    /// When the channel has a custom image, it is displayed as a single avatar.
    /// Otherwise, member avatars are shown in a stacked layout.
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
            url: channel.imageURL,
            size: size,
            stackedPlaceholders: channel.avatarUsers.map { ($0.imageURL, UserAvatar.initials(from: $0.name ?? "")) },
            memberCount: channel.memberCount,
            indicator: showsIndicator ? channel.avatarIndicator : .none,
            showsBorder: showsBorder
        )
    }
    
    /// Creates a channel avatar from explicit values.
    ///
    /// When `url` is non-nil it is displayed as a single avatar image.
    /// Otherwise, `stackedPlaceholders` are shown in a stacked layout
    /// (for sizes ≥ ``AvatarSize/large``).
    ///
    /// - Parameters:
    ///   - url: The URL of the channel's custom image, or `nil` to use the
    ///     stacked member layout.
    ///   - size: The width and height of the avatar.
    ///   - stackedPlaceholders: An array of member avatar URLs and initials
    ///     used for the stacked layout when `url` is `nil`.
    ///   - memberCount: The total number of members in the channel, used to
    ///     compute the overflow badge count.
    ///   - indicator: The presence indicator to display. Defaults to no indicator.
    ///   - showsBorder: A Boolean value that indicates whether to show a circular
    ///     border around the avatar. Defaults to `true`.
    init(
        url: URL?,
        size: CGFloat,
        stackedPlaceholders: [(url: URL?, initials: String)],
        memberCount: Int,
        indicator: AvatarIndicator = .none,
        showsBorder: Bool = true
    ) {
        self.indicator = indicator
        self.memberCount = memberCount
        self.showsBorder = showsBorder
        self.size = size
        self.stackedPlaceholders = stackedPlaceholders
        self.url = url
    }
    
    public var body: some View {
        StreamAsyncImage(
            url: url,
            thumbnailSize: .avatarThumbnailSize,
            content: { phase in
                Group {
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .overlay(
                                showsBorder ? Circle().strokeBorder(colors.borderCoreOpacity10.toColor, lineWidth: 1) : nil
                            )
                            .clipShape(Circle())
                    case .empty, .loading:
                        if size >= AvatarSize.large, !stackedPlaceholders.isEmpty {
                            StackedPlaceholderView(
                                users: stackedPlaceholders,
                                size: size,
                                memberCount: memberCount
                            )
                        } else {
                            PlaceholderView(size: size)
                                .clipShape(Circle())
                        }
                    }
                }
            }
        )
        .frame(width: size, height: size)
        
        .avatarIndicator(indicator, size: size)
        .accessibilityIdentifier("ChannelAvatar")
    }
}
 
private extension ChannelAvatar {
    struct PlaceholderView: View {
        @Environment(\.redactionReasons) var redactionReasons
        @Injected(\.colors) var colors
        @Injected(\.images) var images
        
        let size: CGFloat
        
        var body: some View {
            colors.avatarBackgroundDefault.toColor
                .overlay(
                    Image(uiImage: images.channelAvatarPlaceholder)
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: iconSize.width, height: iconSize.height)
                        .font(.system(size: iconSize.height, weight: .semibold))
                        .foregroundColor(colors.avatarTextDefault.toColor)
                        .opacity(redactionReasons.contains(.placeholder) ? 0 : 1)
                )
                .accessibilityIdentifier("ChannelAvatarPlaceholder")
        }
        
        var iconSize: CGSize {
            // Width is fine-tuned based on the icon symbol
            switch size {
            case AvatarSize.sizeClassExtraExtraLarge: CGSize(width: 36, height: 32)
            case AvatarSize.sizeClassExtraLarge: CGSize(width: 26, height: 24)
            case AvatarSize.sizeClassLarge: CGSize(width: 22, height: 20)
            case AvatarSize.sizeClassMedium: CGSize(width: 18, height: 16)
            case AvatarSize.sizeClassSmall: CGSize(width: 14, height: 12)
            default: CGSize(width: 12, height: 10)
            }
        }
    }
    
    /// A view that displays multiple member avatars in a stacked layout.
    ///
    /// The layout adapts to the number of users:
    /// - **1 user**: Diagonal — avatar (top-leading) with a generic placeholder (bottom-trailing).
    /// - **2 users**: Diagonal — both avatars placed top-leading and bottom-trailing.
    /// - **3 users**: Triangle — top-center, bottom-leading, bottom-trailing.
    /// - **4 users**: 2×2 grid filling all four quadrants.
    /// - **5+ users**: Two avatars at the top with a count badge at the bottom center.
    struct StackedPlaceholderView: View {
        @Injected(\.colors) var colors
        
        let users: [(url: URL?, initials: String)]
        let size: CGFloat
        let memberCount: Int
                
        /// The width of the white ring around each mini avatar.
        private var outerBorderWidth: CGFloat { 2 }
        
        // MARK: - Body
        
        var body: some View {
            Group {
                switch users.count {
                case 0:
                    EmptyView()
                case 1:
                    singleMemberLayout
                case 2:
                    twoMemberLayout
                case 3:
                    threeMemberLayout
                case 4:
                    fourMemberLayout
                default:
                    overflowLayout
                }
            }
            .frame(width: size, height: size)
            .accessibilityIdentifier("ChannelAvatarPlaceholder")
        }
        
        // MARK: - Layouts
        
        /// Single member: user avatar at top-leading, generic placeholder at bottom-trailing.
        private var singleMemberLayout: some View {
            ZStack {
                avatar(for: users[0])
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .offset(x: -outerBorderWidth, y: -outerBorderWidth)
                avatar(for: (nil, ""))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .offset(x: outerBorderWidth, y: outerBorderWidth)
            }
        }
        
        /// Two members: diagonal layout.
        private var twoMemberLayout: some View {
            ZStack {
                avatar(for: users[0])
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .offset(x: -outerBorderWidth, y: -outerBorderWidth)
                avatar(for: users[1])
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .offset(x: outerBorderWidth, y: outerBorderWidth)
            }
        }
        
        /// Three members: triangle — one on top centered, two at the bottom.
        private var threeMemberLayout: some View {
            ZStack {
                avatar(for: users[0])
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .offset(y: -outerBorderWidth)
                avatar(for: users[1])
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    .offset(x: -outerBorderWidth, y: outerBorderWidth)
                avatar(for: users[2])
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .offset(x: outerBorderWidth, y: outerBorderWidth)
            }
        }
        
        /// Four members: 2×2 grid.
        private var fourMemberLayout: some View {
            ZStack {
                avatar(for: users[0])
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .offset(x: -outerBorderWidth, y: -outerBorderWidth)
                avatar(for: users[1])
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .offset(x: outerBorderWidth, y: -outerBorderWidth)
                avatar(for: users[2])
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    .offset(x: -outerBorderWidth, y: outerBorderWidth)
                avatar(for: users[3])
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .offset(x: outerBorderWidth, y: outerBorderWidth)
            }
        }
        
        /// Five or more members: two avatars at top, count badge at bottom center.
        private var overflowLayout: some View {
            ZStack {
                avatar(for: users[0])
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .offset(x: -outerBorderWidth, y: -outerBorderWidth)
                avatar(for: users[1])
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .offset(x: outerBorderWidth, y: -outerBorderWidth)
                CountBadgeView(count: memberCount - 2, size: size)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
        }
        
        private func avatar(for user: (url: URL?, initials: String)) -> some View {
            UserAvatar(
                url: user.0,
                initials: user.1,
                size: {
                    switch size {
                    case AvatarSize.sizeClassExtraExtraLarge: AvatarSize.large
                    case AvatarSize.sizeClassExtraLarge: AvatarSize.medium
                    default: AvatarSize.small
                    }
                }(),
                indicator: .none,
                showsBorder: false
            )
            .padding(outerBorderWidth)
            .background(Circle().fill(colors.borderCoreOnDark.toColor))
        }
    }
    
    /// A small pill-shaped badge that shows the number of additional members not displayed.
    struct CountBadgeView: View {
        @Injected(\.colors) var colors
        @Injected(\.tokens) var tokens
        
        let count: Int
        /// The avatar size used to determine badge dimensions.
        let size: CGFloat
        
        /// The capped display value. Values ≥ 100 are clamped to 99.
        private var displayText: String {
            "+\(min(count, 99))"
        }
        
        private var elevation: BoxShadow { tokens.lightElevation2 }
        
        // MARK: - Size-dependent properties
        
        /// Badge height based on the avatar size class.
        private var badgeHeight: CGFloat {
            switch size {
            case AvatarSize.sizeClassExtraExtraLarge: 32
            case AvatarSize.sizeClassExtraLarge: 24
            default: 20
            }
        }
        
        /// Badge minimum width based on the avatar size class.
        private var badgeMinWidth: CGFloat { badgeHeight }
        
        /// Horizontal padding based on the avatar size class.
        private var horizontalPadding: CGFloat {
            switch size {
            case AvatarSize.sizeClassExtraExtraLarge: 8
            case AvatarSize.sizeClassExtraLarge: 8
            default: 4
            }
        }
        
        /// Font size based on the avatar size class.
        private var fontSize: CGFloat {
            switch size {
            case AvatarSize.sizeClassExtraExtraLarge: 13
            case AvatarSize.sizeClassExtraLarge: 13
            default: 10
            }
        }
        
        var body: some View {
            Text(displayText)
                .font(.system(size: fontSize, weight: .bold))
                .foregroundColor(colors.badgeText.toColor)
                .environment(\.sizeCategory, .large)
                .padding(.horizontal, horizontalPadding)
                .frame(minWidth: badgeMinWidth, minHeight: badgeHeight)
                .frame(height: badgeHeight)
                .background(
                    Capsule()
                        .fill(colors.badgeBackgroundDefault.toColor)
                )
                .overlay(
                    Capsule()
                        .strokeBorder(colors.borderCoreSubtle.toColor, lineWidth: 1)
                )
                .shadow(
                    color: Color(elevation.color),
                    radius: elevation.blur / 2,
                    x: elevation.x,
                    y: elevation.y
                )
        }
    }
}

private extension ChatChannel {
    @MainActor var avatarUsers: [ChatUser] {
        let currentUserId = InjectedValues[\.chatClient].currentUserId
        return Array(
            lastActiveMembers
                .filter { $0.id != currentUserId }
                .sorted { $0.memberCreatedAt < $1.memberCreatedAt }
                .prefix(4)
        )
    }
    
    @MainActor var avatarIndicator: AvatarIndicator {
        guard isDirectMessageChannel, memberCount == 2 else { return .none }
        let currentUserId = InjectedValues[\.chatClient].currentUserId
        guard let otherMember = lastActiveMembers.first(where: { $0.id != currentUserId }) else { return .none }
        return otherMember.isOnline ? .online : .offline
    }
}
