//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Modifier for adding shadow to a view.
public struct ShadowModifier: ViewModifier {
    public init(
        firstRadius: CGFloat = 10,
        firstY: CGFloat = 12
    ) {
        self.firstRadius = firstRadius
        self.firstY = firstY
    }
    
    var firstRadius: CGFloat
    var firstY: CGFloat

    public func body(content: Content) -> some View {
        content
            .shadow(color: Color.black.opacity(0.1), radius: firstRadius, x: 0, y: firstY)
            .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
    }
}

/// View modifier that applies default padding to elements.
struct StandardPaddingModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
    }
}

struct RoundedBorderModifier: ViewModifier {
    @Injected(\.colors) private var colors
    var cornerRadius: CGFloat = 18

    func body(content: Content) -> some View {
        content.overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color(colors.borderCoreDefault), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

struct IconOverImageModifier: ViewModifier {
    @Injected(\.colors) private var colors

    func body(content: Content) -> some View {
        content
            .foregroundColor(Color(colors.backgroundCoreElevation0))
            .padding(.all, 4)
    }
}

struct ChangeChannelBarsVisibilityModifier: ViewModifier {
    @Injected(\.utils) private var utils
    
    var shouldShow: Bool
    
    func body(content: Content) -> some View {
        if #available(iOS 16, *), !utils.messageListConfig.handleTabBarVisibility {
            content
                .navigationBarHidden(!shouldShow)
                .toolbar(shouldShow ? .visible : .hidden, for: .tabBar)
        } else {
            content
                .navigationBarHidden(!shouldShow)
        }
    }
}

extension View {
    /// View extension that applies default padding to elements.
    public func standardPadding() -> some View {
        modifier(StandardPaddingModifier())
    }

    public func roundWithBorder(cornerRadius: CGFloat = 18) -> some View {
        modifier(RoundedBorderModifier(cornerRadius: cornerRadius))
    }

    public func applyDefaultIconOverlayStyle() -> some View {
        modifier(IconOverImageModifier())
    }
}

extension Image {
    public func customizable() -> some View {
        renderingMode(.template)
            .resizable()
            .scaledToFit()
    }
}

extension Animation {
    static var composerVoiceRecordingSpring: Animation {
        .interactiveSpring(response: 0.35, dampingFraction: 0.88)
    }
}
