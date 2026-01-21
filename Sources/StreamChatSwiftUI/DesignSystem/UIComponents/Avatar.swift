//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatCommonUI
import SwiftUI

// MARK: - Channel Avatar

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

// MARK: - User Avatar

public struct UserAvatar: View {
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    
    let url: URL?
    let initials: String
    let size: CGFloat
    let indicator: AvatarIndicator
    let showsBorder: Bool
    
    public init(
        user: ChatUser,
        size: CGFloat,
        showsIndicator: Bool = false,
        showsBorder: Bool = true
    ) {
        self.init(
            url: user.imageURL,
            initials: Self.intials(from: user.name ?? ""),
            size: size,
            indicator: showsIndicator ? (user.isOnline ? .online : .offline) : .none,
            showsBorder: showsBorder
        )
    }
    
    public init(
        user: UserDisplayInfo,
        size: CGFloat,
        showsIndicator: Bool = false,
        showsBorder: Bool = true
    ) {
        self.init(
            url: user.imageURL,
            initials: Self.intials(from: user.name),
            size: size,
            indicator: showsIndicator ? (user.isOnline ? .online : .offline) : .none,
            showsBorder: showsBorder
        )
    }
    
    public init(
        url: URL?,
        initials: String,
        size: CGFloat,
        indicator: AvatarIndicator,
        showsBorder: Bool = true
    ) {
        self.url = url
        self.initials = String(initials.prefix(size >= AvatarSize.medium ? 2 : 1))
        self.size = size
        self.indicator = indicator
        self.showsBorder = showsBorder
    }
    
    public var body: some View {
        Avatar(
            url: url,
            placeholder: { _ in
                colors.avatarBgDefault.toColor
                    .overlay(
                        VStack {
                            if initials.isEmpty {
                                Image(systemName: "person")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: iconSize.width, height: iconSize.height)
                                    .font(.system(size: iconSize.height, weight: .semibold))
                            } else {
                                Text(verbatim: initials)
                            }
                        }
                        .font(font)
                        .foregroundColor(colors.avatarTextDefault.toColor)
                    )
                    .accessibilityIdentifier("UserAvatarPlaceholder")
            },
            size: size,
            showsBorder: showsBorder
        )
        .cornerRadius(DesignSystemTokens.radiusMax)
        .avatarIndicator(indicator, size: size)
        .accessibilityIdentifier("UserAvatar")
    }
    
    var iconSize: CGSize {
        switch size {
        case AvatarSize.largeSizeClass: CGSize(width: 16, height: 16)
        case AvatarSize.mediumSizeClass: CGSize(width: 14, height: 14)
        case AvatarSize.smallSizeClass: CGSize(width: 10, height: 10)
        default: CGSize(width: 9, height: 9)
        }
    }
    
    var font: Font {
        switch size {
        case AvatarSize.largeSizeClass: fonts.subheadline.weight(.semibold)
        case AvatarSize.mediumSizeClass: fonts.footnote.weight(.semibold)
        default: fonts.caption1.weight(.semibold)
        }
    }
}

extension UserAvatar {
    private static let intialsFormatter: PersonNameComponentsFormatter = {
        let formatter = PersonNameComponentsFormatter()
        formatter.style = .abbreviated
        return formatter
    }()
    
    private static func intials(from name: String) -> String {
        guard !name.isEmpty else { return "" }
        guard let components = intialsFormatter.personNameComponents(from: name) else { return "" }
        return intialsFormatter.string(from: components)
    }
}

// MARK: - Base Avatar

struct Avatar<Placeholder>: View where Placeholder: View {
    @Injected(\.colors) var colors
    @Injected(\.utils) var utils
    
    let url: URL?
    @ViewBuilder let placeholder: (AvatarPlaceholderState) -> Placeholder
    let size: CGFloat
    let showsBorder: Bool
    
    init(
        url: URL?,
        placeholder: @escaping (AvatarPlaceholderState) -> Placeholder,
        size: CGFloat,
        showsBorder: Bool
    ) {
        self.url = {
            guard let url else { return nil }
            return InjectedValues[\.utils.imageCDN].thumbnailURL(originalURL: url, preferredSize: CGSize(width: size, height: size))
        }()
        self.placeholder = placeholder
        self.size = size
        self.showsBorder = showsBorder
    }
    
    var body: some View {
        LazyImage(imageURL: url) { state in
            switch state {
            case let .loaded(image):
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .overlay(
                        showsBorder ? Circle().strokeBorder(colors.borderCoreImage.toColor, lineWidth: 1) : nil
                    )
            case .loading:
                placeholder(.loading)
            case .placeholder:
                placeholder(.empty)
            case let .error(error):
                placeholder(.error(error))
            }
        }
        .onDisappear(.cancel)
        .priority(.normal)
        .frame(width: size, height: size)
        .clipped()
    }
}

// MARK: - Avatar Styling

public enum AvatarSize {
    @MainActor public static var large: CGFloat = 40
    @MainActor public static var medium: CGFloat = 32
    @MainActor public static var small: CGFloat = 24
    @MainActor public static var extraSmall: CGFloat = 20
    
    @MainActor static var largeSizeClass: PartialRangeFrom<CGFloat> { AvatarSize.large... }
    @MainActor static var mediumSizeClass: Range<CGFloat> { AvatarSize.medium..<AvatarSize.large }
    @MainActor static var smallSizeClass: Range<CGFloat> { AvatarSize.small..<AvatarSize.medium }
    @MainActor static var extraSmallSizeClass: PartialRangeUpTo<CGFloat> { ..<AvatarSize.small }
    
    @MainActor static var standardSizes: [CGFloat] { [AvatarSize.large, AvatarSize.medium, AvatarSize.small, AvatarSize.extraSmall] }
}

public enum AvatarIndicator: CaseIterable {
    case online, offline, none
}

public enum AvatarPlaceholderState {
    /// The placeholder when no image is available.
    case empty
    /// The placeholder shown while the image is loading.
    case loading
    /// The placeholder shown when there is an error loading the image.
    case error(Error)
}

extension View {
    func avatarIndicator(_ indicator: AvatarIndicator, size: CGFloat) -> some View {
        modifier(AvatarIndicatorViewModifier(indicator: indicator, size: size))
    }
}

private struct AvatarIndicatorViewModifier: ViewModifier {
    let indicator: AvatarIndicator
    let size: CGFloat
    
    func body(content: Content) -> some View {
        content
            .overlay(
                indicator != .none ? OnlineIndicator(online: indicator == .online, size: size) : nil, alignment: .topTrailing
            )
    }

    struct OnlineIndicator: View {
        @Injected(\.colors) var colors
        
        let online: Bool
        let size: CGFloat
        
        var body: some View {
            Circle()
                .fill(colors.presenceBorder.toColor)
                .frame(width: diameter, height: diameter)
                .overlay(
                    Circle()
                        .inset(by: borderWidth)
                        .fill(fillColor)
                )
                .offset(x: borderWidth, y: -borderWidth)
        }
        
        var borderWidth: CGFloat {
            size >= AvatarSize.medium ? 2 : 1
        }
        
        var diameter: CGFloat {
            switch size {
            case AvatarSize.largeSizeClass: 14
            case AvatarSize.mediumSizeClass: 12
            default: 8
            }
        }
        
        var fillColor: Color {
            online ? colors.presenceBgOnline.toColor : colors.presenceBgOffline.toColor
        }
    }
}

// MARK: - Previews

@available(iOS 26)
#Preview(traits: .fixedLayout(width: 200, height: 200)) {
    @Previewable let avatarURL = URL(string: "https://vignette.wikia.nocookie.net/starwars/images/b/b2/Padmegreenscrshot.jpg")!
    @Previewable let channelURL = URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/Aerial_view_of_the_Amazon_Rainforest.jpg/960px-Aerial_view_of_the_Amazon_Rainforest.jpg")!
    @Previewable let streamChat = StreamChat(chatClient: .init(config: .init(apiKeyString: "Preview")))
    VStack(spacing: 12) {
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
        HStack(spacing: 12) {
            VStack(spacing: 12) {
                ForEach(AvatarSize.standardSizes, id: \.self) { size in
                    UserAvatar(
                        url: avatarURL,
                        initials: "PA",
                        size: size,
                        indicator: .online
                    )
                }
            }
            VStack(spacing: 12) {
                ForEach(AvatarSize.standardSizes, id: \.self) { size in
                    UserAvatar(
                        url: nil,
                        initials: "PA",
                        size: size,
                        indicator: .online
                    )
                }
            }
            VStack(spacing: 12) {
                ForEach(AvatarSize.standardSizes, id: \.self) { size in
                    UserAvatar(
                        url: nil,
                        initials: "",
                        size: size,
                        indicator: .offline
                    )
                }
            }
        }
    }
    .padding()
}
