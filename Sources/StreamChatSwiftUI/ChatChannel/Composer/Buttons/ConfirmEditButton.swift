//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// The button for confirming an edited message.
public struct ConfirmEditButton: View {
    @Injected(\.images) private var images

    var enabled: Bool
    var onTap: () -> Void

    public init(enabled: Bool, onTap: @escaping () -> Void) {
        self.enabled = enabled
        self.onTap = onTap
    }

    public var body: some View {
        Button {
            onTap()
        } label: {
            Image(uiImage: images.whiteCheckmark)
                .renderingMode(.template)
        }
        .buttonStyle(PrimaryRoundButtonStyle())
        .disabled(!enabled)
        .accessibilityLabel(Text(L10n.Composer.Title.edit))
        .accessibilityIdentifier("ConfirmEditButton")
    }
}
