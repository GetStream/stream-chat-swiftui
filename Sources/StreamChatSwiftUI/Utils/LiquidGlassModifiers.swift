//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChatCommonUI
import SwiftUI

struct BorderModifier<BackgroundShape: Shape>: ViewModifier {
    @Injected(\.colors) var colors
    
    var shape: BackgroundShape
    
    func body(content: Content) -> some View {
        content
            .background(
                shape
                    .stroke(Color(colors.buttonSecondaryBorder), lineWidth: 0.5)
                    .shadow(
                        color: .black.opacity(0.2),
                        radius: 12,
                        y: 6
                    )
            )
    }
}

public struct LiquidGlassModifier<BackgroundShape: Shape>: ViewModifier {
    var shape: BackgroundShape
    var isInteractive: Bool

    public init(
        shape: BackgroundShape,
        isInteractive: Bool = false
    ) {
        self.shape = shape
        self.isInteractive = isInteractive
    }
    
    public func body(content: Content) -> some View {
        #if swift(>=6.2)
        if #available(iOS 26.0, *) {
            content
                .modifier(BorderModifier(shape: shape))
                .glassEffect(.regular.interactive(isInteractive), in: shape)
        } else {
            content
        }
        #else
        content
        #endif
    }
}

struct CustomRoundedShape: Shape {
    var radius: CGFloat = DesignSystemTokens.radius3xl
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
