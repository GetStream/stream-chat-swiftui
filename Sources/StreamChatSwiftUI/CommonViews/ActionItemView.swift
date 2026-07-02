//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// View for the  action item in an action list (for channels and messages).
public struct ActionItemView: View {
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images
    @Injected(\.fonts) private var fonts

    @Environment(\.sizeCategory) private var sizeCategory

    var title: String
    var iconName: String
    var isDestructive: Bool
    var boldTitle: Bool = true
    var bundle: Bundle?

    public var body: some View {
        HStack(spacing: 16) {
            if sizeCategory.isAccessibilityCategory {
                // At accessibility text sizes the icon is dropped (like the system context
                // menu) and the title fills the row, staying leading-aligned even when it
                // wraps to a second line.
                titleView
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Image(uiImage: image)
                    .customizable()
                    .frame(width: 20, height: 18)
                    .foregroundColor(
                        isDestructive ? Color(colors.accentError) : Color(colors.textTertiary)
                    )

                titleView

                Spacer()
            }
        }
        // The row grows to fit the title (up to two lines) instead of clipping it to a
        // fixed height, with extra vertical breathing room at accessibility text sizes.
        .frame(minHeight: 40)
        .padding(.vertical, sizeCategory.isAccessibilityCategory ? 6 : 0)
    }

    private var titleView: some View {
        Text(title)
            .font(boldTitle ? fonts.bodyBold : fonts.body)
            .foregroundColor(
                isDestructive ? Color(colors.accentError) : Color(colors.textPrimary)
            )
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var image: UIImage {
        // Check if it's in a custom bundle.
        if let bundle, let image = UIImage(named: iconName, in: bundle) {
            return image
        }
        
        // Check if it's in the app bundle.
        if let image = UIImage(named: iconName) {
            return image
        }

        // Support for system images.
        if let image = UIImage(systemName: iconName) {
            return image
        }

        // Check if it's bundled.
        if let image = UIImage(named: iconName, in: .streamChatCommonUI) {
            return image
        }

        // Default image.
        return images.imagePlaceholder
    }
}
