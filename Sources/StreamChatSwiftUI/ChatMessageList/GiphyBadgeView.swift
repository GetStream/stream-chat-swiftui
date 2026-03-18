//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Default view for the giphy badge.
public struct GiphyBadgeView: View {
    @Injected(\.images) private var images
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens

    public var body: some View {
        BottomLeftView {
            HStack(spacing: tokens.spacingXxs) {
                Image(uiImage: images.commandGiphyIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: tokens.iconSizeXs, height: tokens.iconSizeXs)
                    .accessibilityHidden(true)
                Text(L10n.Message.GiphyAttachment.title)
                    .font(fonts.footnote.weight(.semibold))
                    .foregroundColor(Color(colors.badgeTextOnAccent))
            }
            .frame(height: 24)
            .padding(.horizontal, tokens.spacingXs)
            .padding(.vertical, tokens.spacingXxxs)
            .background(Color(colors.badgeBackgroundOverlay))
            .cornerRadius(tokens.radiusLg)
            .padding(.all, tokens.spacingXs)
        }
        .accessibilityIdentifier("GiphyBadgeView")
    }
}
