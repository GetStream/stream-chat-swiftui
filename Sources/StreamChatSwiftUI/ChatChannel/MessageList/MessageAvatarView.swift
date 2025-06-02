//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

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
    @ViewBuilder private let placeholder: () -> Placeholder

    public init(
        avatarURL: URL?,
        size: CGSize = CGSize.messageAvatarSize,
        showOnlineIndicator: Bool = false,
        placeholder: @escaping () -> Placeholder = {
            Image(uiImage: InjectedValues[\.images].userAvatarPlaceholder2)
                .resizable()
        }
    ) {
        self.avatarURL = avatarURL
        self.size = size
        self.showOnlineIndicator = showOnlineIndicator
        self.placeholder = placeholder
    }

    public var body: some View {
        if let urlString = avatarURL?.absoluteString, let url = URL(string: urlString) {
            let adjustedURL = imageCDN.thumbnailURL(
                originalURL: url,
                preferredSize: size
            )

            LazyImage(imageURL: adjustedURL) { content in
                if let image = content.image {
                    image
                } else {
                    placeholder()
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
            placeholder()
                .clipShape(Circle())
                .frame(
                    width: size.width,
                    height: size.height
                )
                .accessibilityIdentifier("MessageAvatarViewPlaceholder")
        }
    }
}

extension CGSize {
    public static var messageAvatarSize = CGSize(width: 36, height: 36)
}
