//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChatCommonUI
import SwiftUI

public struct PrimaryRoundButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool
    @Injected(\.colors) private var colors

    let size: CGFloat

    public init(
        size: CGFloat = ButtonSize.medium
    ) {
        self.size = size
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(Color(foregroundColor))
            .frame(width: size, height: size)
            .background(Color(backgroundColor))
            .clipShape(.capsule)
    }

    private var foregroundColor: UIColor {
        isEnabled ? colors.textOnAccent : colors.textDisabled
    }

    private var backgroundColor: UIColor {
        isEnabled ? colors.buttonPrimaryBackground : colors.backgroundCoreDisabled
    }
}
