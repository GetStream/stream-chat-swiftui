//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct GalleryView: View {
    
    var message: ChatMessage
    @Binding var isShown: Bool
    
    var body: some View {
        GeometryReader { reader in
            VStack {
                GalleryHeaderView(
                    title: message.author.name ?? "",
                    subtitle: message.author.onlineText,
                    isShown: $isShown
                )

                TabView {
                    ForEach(sources, id: \.self) { url in
                        LazyLoadingImage(
                            source: url,
                            width: reader.size.width,
                            resize: true
                        )
                        .frame(width: reader.size.width)
                        .aspectRatio(contentMode: .fit)
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .never))
            }
        }
    }
    
    private var sources: [URL] {
        message.imageAttachments.map { attachment in
            attachment.imageURL
        }
    }
}
