//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Overlays a close button on the top-trailing corner of the view.
struct DismissButtonOverlayModifier: ViewModifier {
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens
    @Injected(\.images) private var images

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
        .offset(x: dismissButtonOverlap, y: -dismissButtonOverlap)
        .accessibilityLabel(L10n.Composer.Quoted.dismiss)
        .accessibilityIdentifier("DismissButtonOverlay")
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
