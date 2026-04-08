//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Chip view displayed in the composer when a slash command is active.
public struct CommandChipView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.images) private var images
    @Injected(\.tokens) private var tokens

    var displayName: String
    var onDismiss: () -> Void

    public init(
        displayName: String,
        onDismiss: @escaping () -> Void
    ) {
        self.displayName = displayName
        self.onDismiss = onDismiss
    }

    public var body: some View {
        HStack(spacing: tokens.spacingXxs) {
            Image(uiImage: images.commandsBolt)
                .customizable()
                .frame(width: tokens.iconSizeXs, height: tokens.iconSizeXs)

            Text(displayName.uppercased())
                .font(fonts.footnoteBold)
                .lineLimit(1)

            Button(action: onDismiss) {
                Image(uiImage: images.commandsDismissIcon)
                    .customizable()
                    .frame(width: 10, height: 10)
            }
        }
        .padding(.horizontal, tokens.spacingXs)
        .padding(.vertical, tokens.spacingXxxs)
        .frame(height: 24)
        .foregroundColor(Color(colors.textOnInverse))
        .background(Color(colors.backgroundCoreInverse))
        .clipShape(Capsule())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(displayName)
        .accessibilityAddTraits(.isButton)
    }
}
