//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// A row with a leading icon and a title, for lists of actions and options.
///
/// Part of the design system, where it is the `Core / Mobile / List Item` component.
/// It only draws the row. Wrap it in a `Button` or a `NavigationLink` to make it interactive.
///
/// ```swift
/// Button(action: schedule) {
///     ListItemView(icon: icon, title: "Tomorrow at 9:00 AM")
/// }
/// ```
struct ListItemView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens

    /// The icon shown in front of the title.
    let icon: UIImage
    /// The title of the row.
    let title: String

    var body: some View {
        HStack(spacing: tokens.spacingSm) {
            Image(uiImage: icon)
                .customizable()
                .frame(width: tokens.iconSizeMd, height: tokens.iconSizeMd)
                .foregroundColor(Color(colors.textSecondary))

            Text(title)
                .font(fonts.body)
                .foregroundColor(Color(colors.textPrimary))
                // A button centers the lines of its label otherwise.
                .multilineTextAlignment(.leading)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, tokens.spacingMd)
        .padding(.vertical, tokens.spacingXs)
        .frame(minHeight: tokens.buttonHitTargetMinHeight)
        .contentShape(Rectangle())
    }
}
