//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// A row with a leading icon and a title, for lists of actions and options.
///
/// Part of the design system, where it is the `Core / Mobile / List Item` component.
/// It only draws the row. Wrap it in a `Button` or a `NavigationLink` to make it interactive, with
/// `ListItemButtonStyle` for the highlight of the pressed row.
///
/// ```swift
/// Button(action: schedule) {
///     ListItemView(icon: icon, title: "Tomorrow at 9:00 AM")
/// }
/// .buttonStyle(ListItemButtonStyle())
/// ```
struct ListItemView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens

    /// The icon shown in front of the title.
    let icon: UIImage
    /// The title of the row.
    let title: String
    /// Shows a chevron after the title, for a row that opens another view.
    var showsChevron = false
    /// Shows the icon and the title in the error color, for a row that removes something.
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

/// The button style of a `ListItemView` row, which highlights the row while it is pressed.
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
