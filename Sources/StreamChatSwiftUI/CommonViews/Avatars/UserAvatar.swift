//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatCommonUI
import SwiftUI

public struct UserAvatar: View {
    @Injected(\.colors) var colors
    
    let urls: [URL]
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
            initials: Self.initials(from: user.name ?? ""),
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
        self.urls = [url].compactMap { $0 }
        self.initials = String(initials.prefix(size >= AvatarSize.medium ? 2 : 1))
        self.size = size
        self.indicator = indicator
        self.showsBorder = showsBorder
    }
    
    public var body: some View {
        StreamAsyncImage(
            urls: urls,
            size: size,
            content: { phase in
                Group {
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .overlay(
                                showsBorder ? Circle().strokeBorder(colors.borderCoreImage.toColor, lineWidth: 1) : nil
                            )
                    case .loading, .empty:
                        PlaceholderView(initials: initials, size: size)
                    }
                }
            }
        )
        .cornerRadius(DesignSystemTokens.radiusMax)
        .avatarIndicator(indicator, size: size)
        .accessibilityIdentifier("UserAvatar")
    }
}

extension UserAvatar {
    struct PlaceholderView: View {
        @Injected(\.colors) var colors
        @Injected(\.images) var images
        @Injected(\.fonts) var fonts

        let initials: String
        let size: CGFloat
        
        var body: some View {
            colors.avatarBgDefault.toColor
                .overlay(
                    VStack {
                        if initials.isEmpty {
                            Image(uiImage: images.userAvatarPlaceholder)
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
                    .environment(\.sizeCategory, .large) // no font scaling for initials
                )
                .accessibilityIdentifier("UserAvatarPlaceholder")
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
}

extension UserAvatar {
    private static let initialsFormatter: PersonNameComponentsFormatter = {
        let formatter = PersonNameComponentsFormatter()
        formatter.style = .abbreviated
        return formatter
    }()
    
    private static func initials(from name: String) -> String {
        guard !name.isEmpty else { return "" }
        guard let components = initialsFormatter.personNameComponents(from: name) else { return "" }
        return initialsFormatter.string(from: components)
    }
}

@available(iOS 26, *)
#Preview(traits: .fixedLayout(width: 200, height: 200)) {
    @Previewable let avatarURL = URL(string: "https://vignette.wikia.nocookie.net/starwars/images/b/b2/Padmegreenscrshot.jpg")!
    @Previewable let streamChat = StreamChat(chatClient: .init(config: .init(apiKeyString: "Preview")))
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
    .padding()
}
