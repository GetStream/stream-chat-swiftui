//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

struct SheetHeaderView: View {
    static let minHeight: CGFloat = 72

    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.images) private var images
    @Injected(\.tokens) private var tokens

    let title: String
    let onClose: @MainActor () -> Void
    var onConfirm: (@MainActor () -> Void)?
    var confirmDisabled = false
    var confirmAccessibilityLabel: String?

    var body: some View {
        ZStack {
            Text(title)
                .font(fonts.bodyBold)
                .foregroundColor(Color(colors.textPrimary))
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, tokens.buttonHitTargetMinWidth + tokens.spacingSm)
                .accessibilityAddTraits(.isHeader)

            HStack {
                StreamIconButton(role: .secondary, style: .outline, size: .medium, action: onClose) {
                    Image(uiImage: images.close)
                        .renderingMode(.template)
                        .frame(width: tokens.iconSizeMd, height: tokens.iconSizeMd)
                }
                .accessibilityLabel(Text(L10n.Alert.Actions.cancel))
                .accessibilityIdentifier("SheetHeaderCloseButton")

                Spacer()

                if let onConfirm {
                    StreamIconButton(role: .primary, style: .solid, size: .medium, action: onConfirm) {
                        Image(uiImage: images.whiteCheckmark)
                            .customizable()
                            .frame(width: tokens.iconSizeMd, height: tokens.iconSizeMd)
                    }
                    .disabled(confirmDisabled)
                    .accessibilityLabel(Text(confirmAccessibilityLabel ?? L10n.Alert.Actions.ok))
                    .accessibilityIdentifier("SheetHeaderConfirmButton")
                }
            }
        }
        .padding(.horizontal, tokens.spacingMd)
        // Keeps a title that wraps at large text sizes away from the drag indicator.
        .padding(.vertical, tokens.spacingSm)
        .frame(maxWidth: .infinity, minHeight: Self.minHeight)
    }
}
