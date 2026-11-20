//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

struct ListItemView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens

    let icon: UIImage
    let title: String
    var showsChevron = false
    var isDestructive = false

    var body: some View {
        HStack(spacing: tokens.spacingSm) {
            Image(uiImage: icon)
                .customizable()
                .frame(width: tokens.iconSizeMd, height: tokens.iconSizeMd)
                .foregroundColor(Color(isDestructive ? colors.accentError : colors.textSecondary))

            Text(title)
                .font(fonts.body)
                .foregroundColor(Color(isDestructive ? colors.accentError : colors.textPrimary))
                // A button centers the lines of its label otherwise.
                .multilineTextAlignment(.leading)

            Spacer(minLength: 0)

            if showsChevron {
                DisclosureIndicatorView()
                    .accessibilityHidden(true)
            }
        }
        .padding(.horizontal, tokens.spacingMd)
        .padding(.vertical, tokens.spacingXs)
        .frame(minHeight: tokens.buttonHitTargetMinHeight)
        .contentShape(Rectangle())
    }
}

struct ListItemButtonStyle: ButtonStyle {
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: tokens.radiusMd)
                    .fill(Color(configuration.isPressed ? colors.backgroundUtilityPressed : .clear))
                    .padding(.horizontal, tokens.spacingXxs)
            )
    }
}
