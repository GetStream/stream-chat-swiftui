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
    let size: ComponentSize
    let border: Bool
    
    public init(
        channel: ChatChannel,
        size: ComponentSize,
        border: Bool
    ) {
        self.init(
            url: channel.imageURL,
            size: size,
            border: border
        )
    }
    
    public init(
        url: URL?,
        size: ComponentSize,
        border: Bool
    ) {
        self.url = url
        self.size = size
        self.border = border
    }
    
    public var body: some View {
        Avatar(
            url: url,
            placeholder: {
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
            border: border
        )
    }
    
    var iconSize: CGSize {
        // Width is fine-tuned based on the icon symbol
        switch size {
        case .lg: CGSize(width: 22, height: 20)
        case .md: CGSize(width: 18, height: 16)
        case .sm: CGSize(width: 14, height: 12)
        case .xs: CGSize(width: 12, height: 10)
        }
    }
}

// MARK: - User Avatar

public struct UserAvatar: View {
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    
    let url: URL?
    let initials: String
    let size: ComponentSize
    let indicator: AvatarIndicator
    let border: Bool
    
    public init(
        user: ChatUser,
        size: ComponentSize,
        border: Bool
    ) {
        self.init(
            url: user.imageURL,
            initials: Self.intials(from: user.name ?? ""),
            size: size,
            indicator: user.isOnline ? .online : .offline,
            border: border
        )
    }
    
    public init(
        url: URL?,
        initials: String,
        size: ComponentSize,
        indicator: AvatarIndicator,
        border: Bool
    ) {
        self.url = url
        self.initials = {
            switch size {
            case .lg, .md: String(initials.prefix(2))
            case .sm, .xs: String(initials.prefix(1))
            }
        }()
        self.size = size
        self.indicator = indicator
        self.border = border
    }
    
    public var body: some View {
        Avatar(
            url: url,
            placeholder: {
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
            },
            size: size,
            border: border
        )
        .avatarIndicator(indicator, size: size)
    }
    
    var iconSize: CGSize {
        switch size {
        case .lg: CGSize(width: 16, height: 16)
        case .md: CGSize(width: 14, height: 14)
        case .sm: CGSize(width: 10, height: 10)
        case .xs: CGSize(width: 9, height: 9)
        }
    }
    
    var font: Font {
        switch size {
        case .lg: fonts.subheadline.weight(.semibold)
        case .md: fonts.footnote.weight(.semibold)
        case .sm, .xs: fonts.caption1.weight(.semibold)
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
    
    let url: URL?
    @ViewBuilder let placeholder: () -> Placeholder
    let size: ComponentSize
    let border: Bool
    
    init(
        url: URL?,
        placeholder: @escaping () -> Placeholder,
        size: ComponentSize,
        border: Bool
    ) {
        self.url = url
        self.placeholder = placeholder
        self.size = size
        self.border = border
    }
    
    var body: some View {
        ThumbnailImage(
            url: url,
            size: size.avatar,
            content: { image in
                image
                    .resizable()
                    .scaledToFill()
                    .overlay(
                        border ? Circle().strokeBorder(colors.borderCoreImage.toColor, lineWidth: 1) : nil
                    )
            },
            placeholder: placeholder
        )
        .clipped()
        .cornerRadius(DesignSystemTokens.radiusMax)
    }
}

extension ComponentSize {
    var avatar: CGSize {
        switch self {
        case .lg: CGSize(width: 40, height: 40)
        case .md: CGSize(width: 32, height: 32)
        case .sm: CGSize(width: 24, height: 24)
        case .xs: CGSize(width: 20, height: 20)
        }
    }
}

// MARK: - Avatar Presence Indicator

public enum AvatarIndicator: CaseIterable {
    case online, offline, none
}

extension View {
    func avatarIndicator(_ indicator: AvatarIndicator, size: ComponentSize) -> some View {
        modifier(AvatarIndicatorViewModifier(indicator: indicator, size: size))
    }
}

private struct AvatarIndicatorViewModifier: ViewModifier {
    let indicator: AvatarIndicator
    let size: ComponentSize
    
    func body(content: Content) -> some View {
        content
            .overlay(
                indicator != .none ? OnlineIndicator(online: indicator == .online, size: size) : nil, alignment: .topTrailing
            )
    }

    struct OnlineIndicator: View {
        @Injected(\.colors) var colors
        
        let online: Bool
        let size: ComponentSize
        
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
            switch size {
            case .lg, .md: 2
            case .sm, .xs: 1
            }
        }
        
        var diameter: CGFloat {
            switch size {
            case .lg: 14
            case .md: 12
            case .sm, .xs: 8
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
    let streamChat = StreamChat(chatClient: .init(config: .init(apiKeyString: "Preview")))
    VStack(spacing: 12) {
        HStack(spacing: 12) {
            VStack(spacing: 12) {
                ForEach(ComponentSize.allCases, id: \.self) { size in
                    ChannelAvatar(
                        url: channelURL,
                        size: size,
                        border: true
                    )
                }
            }
            VStack(spacing: 12) {
                ForEach(ComponentSize.allCases, id: \.self) { size in
                    ChannelAvatar(
                        url: nil,
                        size: size,
                        border: true
                    )
                }
            }
        }
        HStack(spacing: 12) {
            VStack(spacing: 12) {
                ForEach(ComponentSize.allCases, id: \.self) { size in
                    UserAvatar(
                        url: avatarURL,
                        initials: "PA",
                        size: size,
                        indicator: .online,
                        border: true
                    )
                }
            }
            VStack(spacing: 12) {
                ForEach(ComponentSize.allCases, id: \.self) { size in
                    UserAvatar(
                        url: nil,
                        initials: "PA",
                        size: size,
                        indicator: .online,
                        border: true
                    )
                }
            }
            VStack(spacing: 12) {
                ForEach(ComponentSize.allCases, id: \.self) { size in
                    UserAvatar(
                        url: nil,
                        initials: "",
                        size: size,
                        indicator: .offline,
                        border: true
                    )
                }
            }
        }
    }
    .padding()
}
