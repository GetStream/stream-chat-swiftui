//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public enum AvatarPlaceholderState {
    /// The placeholder when no image is available.
    case empty
    /// The placeholder shown while the image is loading.
    case loading
    /// The placeholder shown when there is an error loading the image.
    case error(Error)
}

public struct MessageAvatarView<Placeholder>: View where Placeholder: View {
    @Injected(\.utils) private var utils
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images

    private var imageCDN: ImageCDN {
        utils.imageCDN
    }

    var avatarURL: URL?
    var size: CGSize
    var showOnlineIndicator: Bool = false
    @ViewBuilder var placeholder: (AvatarPlaceholderState) -> Placeholder

    public init(
        avatarURL: URL?,
        size: CGSize = CGSize.messageAvatarSize,
        showOnlineIndicator: Bool = false,
        placeholder: @escaping (AvatarPlaceholderState) -> Placeholder
    ) {
        self.avatarURL = avatarURL
        self.size = size
        self.showOnlineIndicator = showOnlineIndicator
        self.placeholder = placeholder
    }

    public init(
        avatarURL: URL?,
        size: CGSize = CGSize.messageAvatarSize,
        showOnlineIndicator: Bool = false
    ) where Placeholder == MessageAvatarDefaultPlaceholderView {
        self.avatarURL = avatarURL
        self.size = size
        self.showOnlineIndicator = showOnlineIndicator
        placeholder = { _ in
            MessageAvatarDefaultPlaceholderView(size: size)
        }
    }

    public var body: some View {
        if let urlString = avatarURL?.absoluteString, let url = URL(string: urlString) {
            let adjustedURL = imageCDN.thumbnailURL(
                originalURL: url,
                preferredSize: size
            )

            LazyImage(imageURL: adjustedURL) { state in
                switch state {
                case let .loaded(image):
                    NukeImage(image)
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
            .clipShape(Circle())
            .frame(
                width: size.width,
                height: size.height
            )
            .overlay(
                showOnlineIndicator ?
                    TopRightView {
                        OnlineIndicatorView(indicatorSize: size.width * 0.3)
                    }
                    .offset(x: 3, y: -1)
                    : nil
            )
            .accessibilityIdentifier("MessageAvatarView")
        } else {
            placeholder(.empty)
        }
    }
}

public struct MessageAvatarDefaultPlaceholderView: View {
    @Injected(\.images) private var images

    public let size: CGSize

    public init(size: CGSize) {
        self.size = size
    }

    public var body: some View {
        Image(uiImage: images.userAvatarPlaceholder2)
            .resizable()
            .frame(
                width: size.width,
                height: size.height
            )
            .accessibilityIdentifier("MessageAvatarViewPlaceholder")
    }
}

extension CGSize {
    public static var messageAvatarSize = CGSize(width: 36, height: 36)
}
