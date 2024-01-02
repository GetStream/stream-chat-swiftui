//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View used for the gallery header, for images and videos.
struct GalleryHeaderView: View {

    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.images) private var images

    var title: String
    var subtitle: String

    @Binding var isShown: Bool

    var body: some View {
        ZStack {
            HStack {
                Button {
                    isShown = false
                } label: {
                    Image(uiImage: images.close)
                        .customizable()
                        .frame(height: 16)
                }
                .padding()
                .foregroundColor(Color(colors.text))

                Spacer()
            }

            VStack {
                Text(title)
                    .font(fonts.bodyBold)
                Text(subtitle)
                    .font(fonts.footnote)
                    .foregroundColor(Color(colors.textLowEmphasis))
            }
        }
    }
}
