//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

struct BorderModifier<BackgroundShape: Shape>: ViewModifier {
    @Injected(\.colors) var colors
    
    var shape: BackgroundShape
    
    func body(content: Content) -> some View {
        content
            .background(
                shape
                    .stroke(Color(colors.innerBorder), lineWidth: 0.5)
                    .shadow(
                        color: .black.opacity(0.2),
                        radius: 12,
                        y: 6
                    )
            )
    }
}

// TODO: fallback
@available(iOS 26.0, *)
public struct LiquidGlassModifier<BackgroundShape: Shape>: ViewModifier {
    var shape: BackgroundShape
    
    public init(shape: BackgroundShape) {
        self.shape = shape
    }
    
    public func body(content: Content) -> some View {
        content
            .modifier(BorderModifier(shape: shape))
            .glassEffect(.regular, in: shape)
    }
}

struct CustomRoundedShape: Shape {
    var radius: CGFloat = 16
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
