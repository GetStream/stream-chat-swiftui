//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChatCommonUI
import SwiftUI

/// The button for sending messages.
public struct SendMessageButton: View {
    @Injected(\.images) private var images
    @Injected(\.colors) private var colors

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
            Image(uiImage: images.composerSend)
                .renderingMode(.template)
                .foregroundColor(Color(colors.staticColorText))
        }
        .frame(width: 32, height: 32)
        .background(Color(backgroundColor))
        .clipShape(.circle)
        .contentShape(.rect)
        .disabled(!enabled)
        .accessibilityLabel(Text(L10n.Composer.Placeholder.message))
        .accessibilityIdentifier("SendMessageButton")
    }

    private var backgroundColor: UIColor {
        enabled ? colors.accentPrimary : colors.alternativeInactiveTint
    }
}

#Preview {
    SendMessageButton(
        enabled: true,
        onTap: {}
    )

    SendMessageButton(
        enabled: false,
        onTap: {}
    )
}
