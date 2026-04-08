//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// A circular selection indicator for gallery view items.
public struct SelectionBadgeView: View {
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images
    @Injected(\.tokens) private var tokens

    public let isSelected: Bool

    public init(isSelected: Bool) {
        self.isSelected = isSelected
    }

    public var body: some View {
        ZStack {
            if isSelected {
                Circle()
                    .fill(Color(colors.controlRadioCheckBackgroundSelected))
                    .overlay(
                        borderView
                    )
                Image(uiImage: images.selectionBadgeIcon)
                    .customizable()
                    .frame(width: tokens.iconSizeXs, height: tokens.iconSizeXs)
                    .foregroundColor(Color(colors.controlRadioCheckIcon))
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
