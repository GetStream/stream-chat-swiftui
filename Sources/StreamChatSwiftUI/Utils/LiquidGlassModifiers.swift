//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChatCommonUI
import SwiftUI

public struct LiquidGlassInputViewModifier: ViewModifier {
    @Injected(\.colors) var colors

    public init() {}

    public func body(content: Content) -> some View {
        content
            .modifier(LiquidGlassModifier(
                shape: .roundedRect(cornerRadius),
                isInteractive: true
            ))
    }

    private var cornerRadius: CGFloat {
        DesignSystemTokens.radius3xl
    }
}

struct BorderModifier<BackgroundShape: Shape>: ViewModifier {
    @Injected(\.colors) var colors
    
    var shape: BackgroundShape
    
    func body(content: Content) -> some View {
        content
            .clipShape(shape)
            .background(
                shape
                    .stroke(Color(colors.buttonSecondaryBorder), lineWidth: 1)
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

extension Shape where Self == RoundedRectangle {
    static func roundedRect(_ radius: CGFloat) -> Self {
        RoundedRectangle(cornerRadius: radius)
    }
}
