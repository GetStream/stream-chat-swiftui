//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// A view modifier that overlays the jump-to-unread button on top of the message list.
public struct JumpToUnreadButtonOverlayModifier: ViewModifier {
    @Injected(\.tokens) var tokens

    var isShown: Bool
    var unreadCount: Int
    var onJumpToMessage: () -> Void
    var onClose: () -> Void

    public func body(content: Content) -> some View {
        content.overlay(
            VStack {
                if isShown {
                    JumpToUnreadButton(
                        unreadCount: unreadCount,
                        onTap: onJumpToMessage,
                        onClose: onClose
                    )
                    .padding(.top, tokens.spacingXs)
                    .transition(
                        .modifier(
                            active: ButtonOverlayTransitionModifier(opacity: 0, offset: -10),
                            identity: ButtonOverlayTransitionModifier(opacity: 1, offset: 0)
                        )
                    )
                }

                Spacer()
            }
            .animation(.easeInOut(duration: 0.2), value: isShown)
        )
    }
}

struct JumpToUnreadButton: View {
    @Injected(\.colors) var colors
    @Injected(\.tokens) var tokens
    @Injected(\.fonts) var fonts

    var unreadCount: Int
    var onTap: () -> Void
    var onClose: () -> Void

    var body: some View {
        HStack(spacing: tokens.spacingXxs) {
            Button(action: onTap) {
                HStack(spacing: tokens.spacingXs) {
                    Image(systemName: "arrow.up")
                        .frame(width: tokens.iconSizeSm, height: tokens.iconSizeSm)
                    Text(L10n.Message.Unread.count(unreadCount))
                        .padding(.vertical, tokens.spacingXxxs)
                }
                .font(fonts.subheadline.weight(.semibold))
                .padding(.horizontal, tokens.spacingXs)
                .padding(.vertical, tokens.spacingXxs)
            }

            Divider()

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(fonts.subheadline.weight(.semibold))
                    .frame(width: tokens.iconSizeSm, height: tokens.iconSizeSm)
            }
            .frame(width: tokens.buttonVisualHeightSm, height: tokens.buttonVisualHeightSm)
            .accessibilityLabel(Text("Dismiss"))
        }
        .padding(tokens.spacingXxs)
        .fixedSize()
        .foregroundColor(Color(colors.buttonSecondaryText))
        .background(Color(colors.backgroundCoreElevation1))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color(colors.borderCoreDefault), lineWidth: 1)
        )
        .shadow(
            color: Color(tokens.lightElevation3.color),
            radius: tokens.lightElevation3.blur / 2,
            x: tokens.lightElevation3.x,
            y: tokens.lightElevation3.y
        )
    }
}
