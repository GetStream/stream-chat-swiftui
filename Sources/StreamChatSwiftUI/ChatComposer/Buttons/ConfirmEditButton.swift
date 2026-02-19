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

    public init(enabled: Bool, onTap: @escaping () -> Void) {
        self.enabled = enabled
        self.onTap = onTap
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
        .accessibilityLabel(Text(L10n.Composer.Title.edit))
        .accessibilityIdentifier("ConfirmEditButton")
    }
}
