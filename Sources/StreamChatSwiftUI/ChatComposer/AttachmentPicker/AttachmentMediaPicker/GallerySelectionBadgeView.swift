//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChatCommonUI
import SwiftUI

/// A circular selection indicator for gallery view items.
public struct GallerySelectionBadgeView: View {
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images

    public let isSelected: Bool

    public init(isSelected: Bool) {
        self.isSelected = isSelected
    }

    public var body: some View {
        ZStack {
            if isSelected {
                Circle()
                    .fill(Color(colors.controlRadiocheckBackgroundSelected))
                    .overlay(
                        borderView
                    )
                Image(uiImage: images.gallerySelectionBadgeIcon)
                    .renderingMode(.template)
                    .foregroundColor(Color(colors.controlRadiocheckIconSelected))
            } else {
                borderView
            }
        }
        .frame(width: 24, height: 24)
        .accessibilityLabel(isSelected ? "Selected" : "Not selected")
    }

    private var borderView: some View {
        Circle()
            .strokeBorder(Color(colors.borderCoreOnAccent), lineWidth: 2)
    }
}

// TODO: Move to common module

extension Appearance.Images {
    var gallerySelectionBadgeIcon: UIImage {
        UIImage(
            systemName: "checkmark",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        )!
    }
}
