//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SwiftUI

public struct ChatThreadListErrorBannerView: View {
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images

    let action: () -> Void

    public var body: some View {
        HStack(alignment: .center) {
            Text(L10n.Thread.Error.message)
                .foregroundColor(Color(colors.staticColorText))
            Spacer()
            Button(action: action) {
                Image(uiImage: images.restart)
                    .customizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color(colors.staticColorText))
            }
        }
        .padding(.all, 16)
        .background(Color(colors.bannerBackgroundColor))
    }
}
