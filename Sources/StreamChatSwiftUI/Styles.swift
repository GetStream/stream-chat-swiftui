//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import SwiftUI

@MainActor
public protocol Styles {
    var composerPlacement: ComposerPlacement { get set }
    
    associatedtype ComposerInputViewModifier: ViewModifier
    var composerInputViewModifier: ComposerInputViewModifier { get set }
    
    associatedtype ComposerButtonViewModifier: ViewModifier
    var composerButtonViewModifier: ComposerButtonViewModifier { get set }
}

public class LiquidGlassStyles: Styles {
    public var composerPlacement: ComposerPlacement = .floating
    public var composerInputViewModifier = LiquidGlassModifier(shape: .capsule)
    public var composerButtonViewModifier = LiquidGlassModifier(shape: .circle)
    
    public init() {}
}

public struct StandardInputViewModifier: ViewModifier {
    @Injected(\.colors) var colors
    
    public func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: TextSizeConstants.cornerRadius)
                    .stroke(Color(colors.innerBorder))
            )
            .clipShape(
                RoundedRectangle(cornerRadius: TextSizeConstants.cornerRadius)
            )
    }
}
