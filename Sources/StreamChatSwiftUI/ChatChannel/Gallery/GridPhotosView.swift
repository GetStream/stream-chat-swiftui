//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View used for displaying photos in a grid.
struct GridPhotosView: View {

    var imageURLs: [URL]
    @Binding var isShown: Bool

    private static let spacing: CGFloat = 2

    private static var itemWidth: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return (UIScreen.main.bounds.size.width / 3) - spacing * 3
        } else {
            return 120
        }
    }

    private let columns = [GridItem(.adaptive(minimum: itemWidth), spacing: spacing)]

    var body: some View {
        VStack {
            TitleWithCloseButton(
                title: L10n.Message.Gallery.photos,
                isShown: $isShown
            )
            ScrollView {
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(imageURLs, id: \.self) { url in
                        LazyLoadingImage(
                            source: url,
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
            Spacer()
        }
    }
}
