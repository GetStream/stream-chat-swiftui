//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// View for the button for sending messages.
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
            Image(uiImage: images.sendArrow)
                .renderingMode(.template)
                .rotationEffect(enabled ? Angle(degrees: -90) : .zero)
                .foregroundColor(
                    Color(
                        enabled ? enabledBackground : colors.disabledColorForColor(enabledBackground)
                    )
                )
        }
        .disabled(!enabled)
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier("SendMessageButton")
    }

    private var enabledBackground: UIColor {
        colors.highlightedAccentBackground
    }
}
