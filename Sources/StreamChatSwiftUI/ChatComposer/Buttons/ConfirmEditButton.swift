//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// The button for confirming an edited message.
public struct ConfirmEditButton: View {
    @Injected(\.images) private var images
    @Injected(\.tokens) private var tokens

    var enabled: Bool
    var onTap: () -> Void
    var accessibilityLabel: String?

    public init(
        enabled: Bool,
        onTap: @escaping () -> Void,
        accessibilityLabel: String? = nil
    ) {
        self.enabled = enabled
        self.onTap = onTap
        self.accessibilityLabel = accessibilityLabel
    }

    public var body: some View {
        StreamIconButton(
            role: .primary,
            style: .solid,
            size: .small,
            action: onTap
        ) {
            Image(uiImage: images.whiteCheckmark)
                .customizable()
                .frame(width: tokens.iconSizeMd, height: tokens.iconSizeMd)
        }
        .disabled(!enabled)
        .accessibilityLabel(Text(resolvedAccessibilityLabel))
        .accessibilityIdentifier("ConfirmEditButton")
    }

    private var resolvedAccessibilityLabel: String {
        accessibilityLabel ?? L10n.Composer.Title.edit
    }
}
