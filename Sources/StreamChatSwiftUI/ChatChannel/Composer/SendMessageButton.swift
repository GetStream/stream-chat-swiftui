//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// The button for sending messages.
public struct SendMessageButton: View {
    @Injected(\.images) private var images

    var enabled: Bool
    var onTap: () -> Void

    public init(enabled: Bool, onTap: @escaping () -> Void) {
        self.enabled = enabled
        self.onTap = onTap
    }

    public var body: some View {
        StreamButton(
            icon: Image(uiImage: images.composerSend).renderingMode(.template),
            text: nil,
            role: .primary,
            style: .solid,
            size: .small,
            action: onTap
        )
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
