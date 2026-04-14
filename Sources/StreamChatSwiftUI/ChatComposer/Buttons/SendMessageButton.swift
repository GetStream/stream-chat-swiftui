//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// The button for sending messages.
public struct SendMessageButton: View {
    @Environment(\.layoutDirection) private var layoutDirection

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
            Image(uiImage: images.composerSend)
                .renderingMode(.template)
                .frame(width: tokens.iconSizeMd, height: tokens.iconSizeMd)
                .scaleEffect(x: layoutDirection == .rightToLeft ? -1 : 1, y: 1)
        }
        .disabled(!enabled)
        .accessibilityLabel(Text(L10n.Composer.Placeholder.message))
        .accessibilityIdentifier("SendMessageButton")
    }
}

@available(iOS 15, *)
#Preview {
    HStack(spacing: 16) {
        VStack {
            Section("Light") {
                SendMessageButton(
                    enabled: true,
                    onTap: {}
                )

                SendMessageButton(
                    enabled: false,
                    onTap: {}
                )
            }
        }
        .padding()
        .frame(width: 120)

        VStack {
            Text("Dark")
            SendMessageButton(
                enabled: true,
                onTap: {}
            )

            SendMessageButton(
                enabled: false,
                onTap: {}
            )
        }
        .padding()
        .frame(width: 120)
        .colorScheme(.dark)
        .background(Color.black)
    }
}
