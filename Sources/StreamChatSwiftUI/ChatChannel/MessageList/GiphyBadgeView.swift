//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Default view for the giphy badge.
public struct GiphyBadgeView: View {
    @Injected(\.images) private var images
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts

    public var body: some View {
        BottomLeftView {
            HStack(spacing: 4) {
                Image(uiImage: images.commandGiphy)
                Text(L10n.Message.GiphyAttachment.title)
                    .font(fonts.bodyBold)
                    .foregroundColor(Color(colors.staticColorText))
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(Color.black.opacity(0.6))
            .cornerRadius(24)
            .padding(.all, 8)
        }
        .accessibilityIdentifier("GiphyBadgeView")
    }
}
