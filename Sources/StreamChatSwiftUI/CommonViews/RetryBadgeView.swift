//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// A circular badge shown when an attachment upload or download fails.
public struct RetryBadgeView: View {
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens

    private let size: CGFloat = 32
    private let borderWidth: CGFloat = 2
    private var iconSize: CGFloat {
        tokens.iconSizeSm
    }

    public init() {}

    public var body: some View {
        ZStack {
            Circle()
                .fill(Color(colors.accentError))
                .overlay(
                    Circle()
                        .inset(by: -borderWidth / 2)
                        .stroke(Color(colors.backgroundCoreElevation0), lineWidth: borderWidth)
                )
            Image(systemName: "arrow.trianglehead.clockwise.rotate.90")
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
                .font(Font.system(size: iconSize, weight: .bold))
                .foregroundColor(Color(colors.backgroundCoreElevation0))
        }
        .frame(width: size, height: size)
        .accessibilityIdentifier("RetryBadgeView")
    }
}
