//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct MediaAttachmentsView: View {
    
    @StateObject private var viewModel: MediaAttachmentsViewModel
    
    private static let spacing: CGFloat = 2
    
    private static var itemWidth: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return (UIScreen.main.bounds.size.width / 3) - spacing * 3
        } else {
            return 120
        }
    }
    
    private let columns = [GridItem(.adaptive(minimum: itemWidth), spacing: spacing)]
    
    init(channel: ChatChannel) {
        _viewModel = StateObject(
            wrappedValue: MediaAttachmentsViewModel(channel: channel)
        )
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(viewModel.mediaItems) { mediaItem in
                    LazyLoadingImage(
                        source: mediaItem.imageURL,
                        width: Self.itemWidth,
                        height: Self.itemWidth
                    )
                    .frame(
                        width: Self.itemWidth,
                        height: Self.itemWidth
                    )
                    .clipped()
                }
            }
            .padding(.horizontal, 2)
            .animation(nil)
        }
    }
}
