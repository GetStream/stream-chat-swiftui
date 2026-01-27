//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatCommonUI
import SwiftUI

/// A view that renders a user avatar with optional presence indicator.
public struct UserAvatar: View {
    @Injected(\.colors) var colors
    
    let urls: [URL]
    let initials: String
    let size: CGFloat
    let indicator: AvatarIndicator
    let showsBorder: Bool
    
    /// Creates a user avatar from a chat user.
    ///
    /// - Parameters:
    ///   - user: The user whose avatar to display.
    ///   - size: The width and height of the avatar.
    ///   - showsIndicator: A Boolean value that indicates whether to show the
    ///     user's online status. Defaults to `false`.
    ///   - showsBorder: A Boolean value that indicates whether to show a circular
    ///     border around the avatar. Defaults to `true`.
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
    
    /// Creates a user avatar from a URL and initials.
    ///
    /// - Parameters:
    ///   - url: The URL of the avatar image to display.
    ///   - initials: The text to display when the image is unavailable.
    ///   - size: The width and height of the avatar.
    ///   - indicator: The presence indicator to display.
    ///   - showsBorder: A Boolean value that indicates whether to show a circular
    ///     border around the avatar. Defaults to `true`.
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
                    case .loading, .empty:
                        PlaceholderView(initials: initials, size: size)
                    }
                }
            }
        )
        .frame(width: size, height: size)
        .clipShape(Circle())
        .avatarIndicator(indicator, size: size)
        .accessibilityIdentifier("UserAvatar")
    }
}

extension UserAvatar {
    struct PlaceholderView: View {
        @Environment(\.redactionReasons) var redactionReasons
        @Injected(\.colors) var colors
        @Injected(\.images) var images
        @Injected(\.fonts) var fonts

        let initials: String
        let size: CGFloat
        
        var body: some View {
            colors.avatarBackgroundDefault.toColor
                .overlay(
                    VStack {
                        if initials.isEmpty {
                            Image(uiImage: images.userAvatarPlaceholder)
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: iconSize.width, height: iconSize.height)
                                .font(.system(size: iconSize.height, weight: .semibold))
                                .opacity(redactionReasons.contains(.placeholder) ? 0 : 1)
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
            case AvatarSize.sizeClassExtraLarge: CGSize(width: 22, height: 22)
            case AvatarSize.sizeClassLarge: CGSize(width: 16, height: 16)
            case AvatarSize.sizeClassMedium: CGSize(width: 14, height: 14)
            case AvatarSize.sizeClassSmall: CGSize(width: 10, height: 10)
            default: CGSize(width: 9, height: 9)
            }
        }
        
        var font: Font {
            switch size {
            case AvatarSize.sizeClassExtraLarge: fonts.title2.weight(.semibold)
            case AvatarSize.sizeClassLarge: fonts.subheadline.weight(.semibold)
            case AvatarSize.sizeClassMedium: fonts.footnote.weight(.semibold)
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
