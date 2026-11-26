//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// A row of a list or a sheet, from the `Core / Mobile / List Item` component: an icon, a title and an optional
/// chevron. Disabled, it draws everything in the disabled text color.
struct ListItemView: View {
    @Environment(\.isEnabled) private var isEnabled
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens

    /// The icon before the title.
    let icon: UIImage
    /// The title of the row.
    let title: String
    /// Whether a chevron after the title shows that the row opens another screen.
    var showsChevron = false
    /// Whether the row is drawn in the error color, for an action that deletes something.
    var destructive = false

    var body: some View {
        HStack(spacing: tokens.spacingSm) {
            Image(uiImage: icon)
                .customizable()
                .frame(width: tokens.iconSizeMd, height: tokens.iconSizeMd)
                .foregroundColor(Color(color(destructive ? colors.accentError : colors.textSecondary)))
                .accessibilityHidden(true)

            Text(title)
                .font(fonts.body)
                .foregroundColor(Color(color(destructive ? colors.accentError : colors.textPrimary)))
                // A button centers the lines of its label otherwise.
                .multilineTextAlignment(.leading)

            Spacer(minLength: 0)

            if showsChevron {
                Image(systemName: "chevron.forward")
                    .foregroundColor(Color(color(colors.textSecondary)))
                    .accessibilityHidden(true)
            }
        }
        .padding(.horizontal, tokens.spacingMd)
        .padding(.vertical, tokens.spacingXs)
        .frame(minHeight: tokens.buttonHitTargetMinHeight)
        .contentShape(Rectangle())
    }

    private func color(_ enabledColor: UIColor) -> UIColor {
        isEnabled ? enabledColor : colors.textDisabled
    }
}

/// The button style of a `ListItemView`, which highlights the row while it is pressed.
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
