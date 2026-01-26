//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatCommonUI
import SwiftUI

/// A type that represents the presence indicator on an avatar.
public enum AvatarIndicator: CaseIterable {
    /// An indicator that shows the user is online.
    case online
    /// An indicator that shows the user is offline.
    case offline
    /// No presence indicator.
    case none
}

extension View {
    /// Adds a presence indicator to an avatar view.
    ///
    /// - Parameters:
    ///   - indicator: The presence indicator to display.
    ///   - size: The width and height of the avatar.
    /// - Returns: A view with a presence indicator overlay.
    public func avatarIndicator(_ indicator: AvatarIndicator, size: CGFloat) -> some View {
        modifier(AvatarIndicatorViewModifier(indicator: indicator, size: size))
    }
}

private struct AvatarIndicatorViewModifier: ViewModifier {
    let indicator: AvatarIndicator
    let size: CGFloat
    
    func body(content: Content) -> some View {
        content
            .overlay(
                indicator != .none ? AvatarIndicatorView(online: indicator == .online, size: size) : nil, alignment: .topTrailing
            )
    }

    struct AvatarIndicatorView: View {
        @Injected(\.colors) var colors
        
        let online: Bool
        let size: CGFloat
        
        var body: some View {
            Circle()
                .fill(colors.presenceBorder.toColor)
                .frame(width: diameter, height: diameter)
                .overlay(
                    Circle()
                        .inset(by: borderWidth)
                        .fill(fillColor)
                )
                .offset(x: offset.x, y: offset.y)
        }
        
        var borderWidth: CGFloat {
            size >= AvatarSize.medium ? 2 : 1
        }
        
        var diameter: CGFloat {
            switch size {
            case AvatarSize.sizeClassExtraLarge: 16
            case AvatarSize.sizeClassLarge: 14
            case AvatarSize.sizeClassMedium: 12
            default: 8
            }
        }
        
        var fillColor: Color {
            online ? colors.presenceBackgroundOnline.toColor : colors.presenceBackgroundOffline.toColor
        }
        
        var offset: CGPoint {
            switch size {
            case AvatarSize.sizeClassExtraLarge: .zero
            default: CGPoint(x: borderWidth, y: -borderWidth)
            }
        }
    }
}
