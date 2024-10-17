//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SwiftUI

struct ActionBannerView: View {
    @Injected(\.colors) private var colors

    let text: String
    let image: UIImage
    let action: () -> Void

    public var body: some View {
        HStack(alignment: .center) {
            Text(text)
                .foregroundColor(Color(colors.staticColorText))
            Spacer()
            Button(action: action) {
                Image(uiImage: image)
                    .customizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color(colors.staticColorText))
            }
        }
        .padding(.all, 16)
        .background(Color(colors.bannerBackgroundColor))
    }
}
