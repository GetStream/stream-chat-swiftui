//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import NukeUI
import StreamChat
import SwiftUI

public struct MessageAvatarView: View {
    @Injected(\.utils) private var utils
    @Injected(\.colors) private var colors
    
    private var imageCDN: ImageCDN {
        utils.imageCDN
    }
    
    var author: ChatUser
    var size: CGSize
    var showOnlineIndicator: Bool = false
    
    public init(
        author: ChatUser,
        size: CGSize = CGSize.messageAvatarSize,
        showOnlineIndicator: Bool = false
    ) {
        self.author = author
        self.size = size
        self.showOnlineIndicator = showOnlineIndicator
    }
    
    public var body: some View {
        if let urlString = author.imageURL?.absoluteString, let url = URL(string: urlString) {
            let adjustedURL = imageCDN.thumbnailURL(
                originalURL: url,
                preferredSize: size
            )
            
            LazyImage(source: adjustedURL)
                .onDisappear(.reset)
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
        } else {
            Image(systemName: "person.circle")
                .renderingMode(.template)
                .resizable()
                .foregroundColor(Color(colors.textLowEmphasis))
                .frame(
                    width: size.width,
                    height: size.height
                )
        }
    }
}

extension CGSize {
    public static var messageAvatarSize = CGSize(width: 36, height: 36)
}
