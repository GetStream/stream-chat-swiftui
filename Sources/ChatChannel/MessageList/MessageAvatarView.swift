//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import NukeUI
import StreamChat
import SwiftUI

public struct MessageAvatarView: View {
    @Injected(\.utils) var utils
    
    private var imageCDN: ImageCDN {
        utils.imageCDN
    }
    
    var author: ChatUser
    
    public var body: some View {
        if let urlString = author.imageURL?.absoluteString, let url = URL(string: urlString) {
            let adjustedURL = imageCDN.thumbnailURL(
                originalURL: url,
                preferredSize: .messageAvatarSize
            )
            
            LazyImage(source: adjustedURL)
                .clipShape(Circle())
                .frame(
                    width: CGSize.messageAvatarSize.width,
                    height: CGSize.messageAvatarSize.height
                )
                .id(url)
        } else {
            Image(systemName: "person.circle")
                .resizable()
                .frame(
                    width: CGSize.messageAvatarSize.width,
                    height: CGSize.messageAvatarSize.height
                )
                .id("placeholder")
        }
    }
}

extension CGSize {
    static var messageAvatarSize = CGSize(width: 36, height: 36)
}
