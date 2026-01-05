//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// View for the  action item in an action list (for channels and messages).
public struct ActionItemView: View {
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images
    @Injected(\.fonts) private var fonts

    var title: String
    var iconName: String
    var isDestructive: Bool
    var boldTitle: Bool = true

    public var body: some View {
        HStack(spacing: 16) {
            Image(uiImage: image)
                .customizable()
                .frame(maxHeight: 18)
                .foregroundColor(
                    isDestructive ? Color(colors.alert) : Color(colors.textLowEmphasis)
                )

            Text(title)
                .font(boldTitle ? fonts.bodyBold : fonts.body)
                .foregroundColor(
                    isDestructive ? Color(colors.alert) : Color(colors.text)
                )

            Spacer()
        }
        .frame(height: 40)
    }

    private var image: UIImage {
        // Check if it's in the app bundle.
        if let image = UIImage(named: iconName) {
            return image
        }

        // Support for system images.
        if let image = UIImage(systemName: iconName) {
            return image
        }

        // Check if it's bundled.
        if let image = UIImage(named: iconName, in: .streamChatUI) {
            return image
        }

        // Default image.
        return images.photoDefault
    }
}
