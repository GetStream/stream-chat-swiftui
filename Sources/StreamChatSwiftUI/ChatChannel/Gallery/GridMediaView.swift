//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View used for displaying media in a grid.
struct GridMediaView: View {
    var attachments: [MediaAttachment]
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
                    ForEach(attachments) { attachment in
                        LazyLoadingImage(
                            source: attachment,
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
