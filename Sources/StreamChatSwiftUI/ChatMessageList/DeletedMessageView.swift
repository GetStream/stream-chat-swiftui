//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View displayed when a message is deleted.
public struct DeletedMessageView: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens

    var message: ChatMessage
    var isFirst: Bool

    public var body: some View {
        HStack(spacing: tokens.spacingXxs) {
            Image(systemName: "nosign")
                .resizable()
                .scaledToFit()
                .frame(width: tokens.iconSizeSm, height: tokens.iconSizeSm)
                .accessibilityHidden(true)
            Text(L10n.Message.deletedMessagePlaceholder)
                .font(fonts.body)
        }
        .foregroundColor(messageTextColor)
        .standardPadding()
        .messageBubble(for: message, isFirst: isFirst)
        .accessibilityIdentifier("deletedMessageText")
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("DeletedMessageView")
    }

    private var messageTextColor: Color {
        message.isSentByCurrentUser
            ? Color(colors.chatTextOutgoing)
            : Color(colors.chatTextIncoming)
    }
}
