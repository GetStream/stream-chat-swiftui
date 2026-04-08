//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// A circular radio/checkbox component with selected and unselected states.
struct RadioCheckView: View {
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images
    @Injected(\.tokens) private var tokens

    let isSelected: Bool
    var isDisabled: Bool = false
    var borderColorOverride: UIColor?

    var body: some View {
        ZStack {
            if isSelected {
                selectedView
            } else {
                unselectedView
            }
        }
        .frame(width: tokens.buttonVisualHeightXs, height: tokens.buttonVisualHeightXs)
        .accessibilityIdentifier("RadioCheckView")
    }

    private var unselectedView: some View {
        Circle()
            .strokeBorder(
                Color(unselectedBorderColor),
                lineWidth: 1
            )
    }

    private var selectedView: some View {
        ZStack {
            Circle()
                .fill(Color(selectedBackgroundColor))
            Image(uiImage: images.selectionBadgeIcon)
                .customizable()
                .frame(width: tokens.iconSizeXs, height: tokens.iconSizeXs)
                .foregroundColor(Color(selectedIconColor))
        }
    }

    private var unselectedBorderColor: UIColor {
        if isDisabled {
            return colors.borderUtilityDisabled
        }
        return borderColorOverride ?? colors.controlRadioCheckBorder
    }

    private var selectedBackgroundColor: UIColor {
        if isDisabled {
            return colors.backgroundUtilityDisabled
        }
        return colors.controlRadioCheckBackgroundSelected
    }

    private var selectedIconColor: UIColor {
        if isDisabled {
            return colors.textDisabled
        }
        return colors.controlRadioCheckIcon
    }
}

#Preview("RadioCheckView") {
    VStack(spacing: 16) {
        HStack(spacing: 16) {
            RadioCheckView(isSelected: false)
            Text("Unselected")
        }
        HStack(spacing: 16) {
            RadioCheckView(isSelected: true)
            Text("Selected")
        }
        HStack(spacing: 16) {
            RadioCheckView(isSelected: false, isDisabled: true)
            Text("Disabled Unselected")
        }
        HStack(spacing: 16) {
            RadioCheckView(isSelected: true, isDisabled: true)
            Text("Disabled Selected")
        }
    }
    .padding()
}
