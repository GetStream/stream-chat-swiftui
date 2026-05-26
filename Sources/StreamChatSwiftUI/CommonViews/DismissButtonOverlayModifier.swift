//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Overlays a close button on the top-trailing corner of the view.
struct DismissButtonOverlayModifier: ViewModifier {
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens
    @Injected(\.images) private var images

    @Environment(\.layoutDirection) private var layoutDirection

    let onDismiss: (() -> Void)

    init(onDismiss: @escaping (() -> Void)) {
        self.onDismiss = onDismiss
    }

    func body(content: Content) -> some View {
        content.overlay(
            dismissButton,
            alignment: .topTrailing
        )
    }

    @ViewBuilder
    private var dismissButton: some View {
        Button(action: onDismiss) {
            Image(uiImage: images.overlayDismissIcon)
                .renderingMode(.template)
                .foregroundColor(Color(colors.controlRemoveControlIcon))
                .frame(
                    width: tokens.iconSizeMd,
                    height: tokens.iconSizeMd
                )
                .background(Color(colors.controlRemoveControlBackground))
                .clipShape(Circle())
                .contentShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color(colors.controlRemoveControlBorder), lineWidth: 2)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .offset(x: horizontalOffset, y: -dismissButtonOverlap)
        .accessibilityLabel(L10n.Composer.Quoted.dismiss)
        .accessibilityIdentifier("DismissButtonOverlay")
    }

    /// `.offset` uses absolute screen coordinates, so we mirror the
    /// horizontal nudge in RTL — otherwise the button sticks toward the
    /// inside of the attachment instead of poking out from the corner.
    private var horizontalOffset: CGFloat {
        layoutDirection == .rightToLeft ? -dismissButtonOverlap : dismissButtonOverlap
    }

    private var dismissButtonOverlap: CGFloat {
        tokens.spacingXxs
    }
}

extension View {
    /// Overlays a close button on the top-trailing corner of the view.
    func dismissButtonOverlayModifier(onDismiss: @escaping (() -> Void)) -> some View {
        modifier(DismissButtonOverlayModifier(onDismiss: onDismiss))
    }
}
