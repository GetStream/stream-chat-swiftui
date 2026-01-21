//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatCommonUI
import SwiftUI

public struct Avatar<Placeholder>: View where Placeholder: View {
    @Injected(\.colors) var colors
    @Injected(\.utils) var utils
    
    let url: URL?
    @ViewBuilder let placeholder: (AvatarPlaceholderState) -> Placeholder
    let size: CGFloat
    let showsBorder: Bool
    
    public init(
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
    
    public var body: some View {
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
