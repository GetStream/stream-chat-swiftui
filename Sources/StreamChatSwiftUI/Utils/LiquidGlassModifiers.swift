//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChatCommonUI
import SwiftUI

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
                .contentShape(shape)
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
