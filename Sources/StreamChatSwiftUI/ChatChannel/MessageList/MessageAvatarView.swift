//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public struct MessageAvatarView: View {

    @Injected(\.utils) private var utils
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images

    private var imageCDN: ImageCDN {
        utils.imageCDN
    }

    var avatarURL: URL?
    var size: CGSize
    var showOnlineIndicator: Bool = false

    public init(
        avatarURL: URL?,
        size: CGSize = CGSize.messageAvatarSize,
        showOnlineIndicator: Bool = false
    ) {
        self.avatarURL = avatarURL
        self.size = size
        self.showOnlineIndicator = showOnlineIndicator
    }

    public var body: some View {
        if let urlString = avatarURL?.absoluteString, let url = URL(string: urlString) {
            let adjustedURL = imageCDN.thumbnailURL(
                originalURL: url,
                preferredSize: size
            )

            LazyImage(imageURL: adjustedURL)
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
            Image(uiImage: images.userAvatarPlaceholder2)
                .resizable()
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
