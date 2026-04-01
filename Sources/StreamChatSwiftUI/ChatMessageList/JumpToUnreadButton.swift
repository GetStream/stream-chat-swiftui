//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct JumpToUnreadButton: View {
    @Injected(\.colors) var colors
    @Injected(\.tokens) var tokens
    @Injected(\.fonts) var fonts

    var unreadCount: Int
    var onTap: () -> Void
    var onClose: () -> Void

    var body: some View {
        HStack(spacing: tokens.spacingNone) {
            Button(action: onTap) {
                HStack(spacing: tokens.spacingXs) {
                    Image(systemName: "arrow.up")
                        .font(fonts.body.weight(.regular))
                        .frame(width: tokens.iconSizeMd, height: tokens.iconSizeMd)
                    Text(L10n.Message.Unread.count(unreadCount))
                }
                .font(fonts.body.weight(.semibold))
                .padding(.horizontal, tokens.buttonPaddingXWithLabelMd)
                .padding(.vertical, tokens.buttonPaddingYMd)
            }

            Divider()

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(fonts.body.weight(.semibold))
                    .frame(width: tokens.iconSizeMd, height: tokens.iconSizeMd)
            }
            .frame(width: tokens.buttonVisualHeightMd, height: tokens.buttonVisualHeightMd)
        }
        .fixedSize()
        .foregroundColor(Color(colors.buttonSecondaryText))
        .background(Color(colors.backgroundElevation1))
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
