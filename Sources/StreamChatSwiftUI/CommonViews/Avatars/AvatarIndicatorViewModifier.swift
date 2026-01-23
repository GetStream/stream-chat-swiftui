//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatCommonUI
import SwiftUI

public enum AvatarIndicator: CaseIterable {
    case online, offline, none
}

extension View {
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
                .offset(x: borderWidth, y: -borderWidth)
        }
        
        var borderWidth: CGFloat {
            size >= AvatarSize.medium ? 2 : 1
        }
        
        var diameter: CGFloat {
            switch size {
            case AvatarSize.largeSizeClass: 14
            case AvatarSize.mediumSizeClass: 12
            default: 8
            }
        }
        
        var fillColor: Color {
            online ? colors.presenceBgOnline.toColor : colors.presenceBgOffline.toColor
        }
    }
}
