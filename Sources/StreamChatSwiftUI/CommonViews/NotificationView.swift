//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// An inline notification, from the `Core / Mobile / Notification` component: an icon, a title and an optional
/// description on a tinted background.
struct NotificationView: View {
    /// The look of the notification.
    enum Style {
        /// An error, on the error background.
        case error
        /// Information, on the brand background.
        case info
    }

    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.images) private var images
    @Injected(\.tokens) private var tokens

    /// The look of the notification.
    let style: Style
    /// The title, in bold.
    let title: String
    /// The text under the title.
    var description: String?

    var body: some View {
        HStack(spacing: tokens.spacingXs) {
            Image(uiImage: style == .error ? images.notificationError : images.notificationInfo)
                .customizable()
                .frame(width: tokens.iconSizeMd, height: tokens.iconSizeMd)
                .foregroundColor(Color(style == .error ? colors.accentError : colors.accentPrimary))
                .accessibilityHidden(true)

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
