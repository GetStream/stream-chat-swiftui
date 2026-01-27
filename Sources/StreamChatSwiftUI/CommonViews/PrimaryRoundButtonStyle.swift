//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

public enum ButtonSize {
    @MainActor public static var large: CGFloat = 40
    @MainActor public static var medium: CGFloat = 32
    @MainActor public static var small: CGFloat = 24
    @MainActor public static var extraSmall: CGFloat = 20
}

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
