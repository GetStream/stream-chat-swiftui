//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChatCommonUI
import SwiftUI

public struct LiquidGlassInputViewModifier: ViewModifier {
    @Injected(\.colors) var colors

    var keyboardShown: Bool

    public init(keyboardShown: Bool) {
        self.keyboardShown = keyboardShown
    }

    public func body(content: Content) -> some View {
        content
            .background(Color(colors.composerBg))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color(colors.buttonSecondaryBorder))
            )
            .clipShape(
                RoundedRectangle(cornerRadius: cornerRadius)
            )
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
                .glassEffect(.regular.interactive(isInteractive), in: shape)
                .modifier(BorderModifier(shape: shape))
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
