//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// A notification with an icon, a title and an optional description, shown inline with other content.
///
/// Part of the design system, where it is the `Core / Mobile / Notification` component.
///
/// ```swift
/// NotificationView(style: .error, title: "Couldn't schedule message. Try again")
/// ```
struct NotificationView: View {
    /// The look of a notification.
    enum Style {
        /// Something went wrong.
        case error
        /// Neutral information.
        case info
    }

    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.images) private var images
    @Injected(\.tokens) private var tokens

    /// The look of the notification, which sets its icon and colors.
    let style: Style
    /// The title of the notification.
    let title: String
    /// The text shown below the title.
    var description: String?

    var body: some View {
        HStack(spacing: tokens.spacingXs) {
            Image(uiImage: style == .error ? images.exclamationCircle : images.info)
                .customizable()
                .frame(width: tokens.iconSizeMd, height: tokens.iconSizeMd)
                .foregroundColor(Color(style == .error ? colors.accentError : colors.accentPrimary))

            VStack(alignment: .leading, spacing: tokens.spacingXxxs) {
                Text(title)
                    .font(fonts.footnoteBold)
                if let description {
                    Text(description)
                        .font(fonts.footnote)
                }
            }
            .foregroundColor(Color(colors.textPrimary))
            .padding(.vertical, tokens.spacingSm)
            .padding(.trailing, tokens.spacingXs)

            Spacer(minLength: 0)
        }
        .padding(.leading, tokens.spacingSm)
        .padding(.trailing, tokens.spacingXxs)
        .frame(minHeight: 46)
        .background(
            RoundedRectangle(cornerRadius: tokens.radiusMd)
                .fill(Color(style == .error ? colors.backgroundUtilityErrorSubtle : colors.accentPrimarySubtle))
        )
        .accessibilityElement(children: .combine)
    }
}
