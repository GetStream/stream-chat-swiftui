//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI
import UIKit

/// View displaying slow mode countdown.
public struct SlowModeView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts

    private let size: CGFloat = 32

    var cooldownDuration: Int
    
    public init(cooldownDuration: Int) {
        self.cooldownDuration = cooldownDuration
    }

    public var body: some View {
        Text("\(cooldownDuration)")
            .font(fonts.bodyBold)
            .frame(width: size, height: size)
            .background(Color(colors.backgroundCoreDisabled))
            .foregroundColor(Color(colors.textDisabled))
            .clipShape(Capsule())
            .accessibilityIdentifier("SlowModeView")
    }
}
