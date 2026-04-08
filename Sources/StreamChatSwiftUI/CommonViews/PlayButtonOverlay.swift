//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Play button overlay for video attachment previews.
public struct PlayButtonOverlay: View {
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens
    @Injected(\.images) private var images

    public init() {}

    public var body: some View {
        ZStack {
            Circle()
                .fill(Color(colors.controlPlayButtonBackground))
                .frame(width: playButtonSize, height: playButtonSize)

            Image(uiImage: images.attachmentPlayOverlayIcon)
                .renderingMode(.template)
                .foregroundColor(Color(colors.controlPlayButtonIcon))
        }
        .accessibilityHidden(true)
    }

    private var playButtonSize: CGFloat {
        tokens.iconSizeMd
    }
}
