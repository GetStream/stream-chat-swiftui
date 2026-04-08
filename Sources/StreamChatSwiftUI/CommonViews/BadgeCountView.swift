//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// A pill-shaped badge that shows the number of additional avatars not displayed.
public struct BadgeCountView: View {
    @Injected(\.colors) var colors
    @Injected(\.tokens) var tokens
    
    let count: Int
    let size: CGFloat
    
    public init(count: Int, size: CGFloat) {
        self.count = count
        self.size = size
    }
    
    private var displayText: String {
        "+\(min(count, 99))"
    }
    
    private var elevation: BoxShadow { tokens.lightElevation2 }
    
    // MARK: - Size-dependent properties
    
    private var fontSize: CGFloat {
        switch size {
        case AvatarSize.sizeClassExtraExtraLarge: 15
        case AvatarSize.sizeClassExtraLarge: 15
        default: 12
        }
    }
    
    private var horizontalPadding: CGFloat {
        switch size {
        case AvatarSize.sizeClassExtraExtraLarge,
             AvatarSize.sizeClassExtraLarge,
             AvatarSize.sizeClassSmall: tokens.spacingXs
        default: tokens.spacingXxs
        }
    }
    
    // MARK: - Body
    
    public var body: some View {
        Text(displayText)
            .font(.system(size: fontSize, weight: .bold))
            .foregroundColor(colors.badgeText.toColor)
            .environment(\.sizeCategory, .large)
            .padding(.horizontal, horizontalPadding)
            .frame(minWidth: size)
            .frame(height: size)
            .background(
                Capsule()
                    .fill(colors.badgeBackgroundDefault.toColor)
            )
            .overlay(
                Capsule()
                    .strokeBorder(colors.borderCoreSubtle.toColor, lineWidth: 1)
            )
            .shadow(
                color: Color(elevation.color),
                radius: elevation.blur / 2,
                x: elevation.x,
                y: elevation.y
            )
    }
}
