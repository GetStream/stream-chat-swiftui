//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View for the check whether the view should be send in the channel.
struct SendInChannelView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens

    @Binding var sendInChannel: Bool

    private let checkboxSize: CGFloat = 20

    var body: some View {
        Button {
            sendInChannel.toggle()
        } label: {
            HStack(alignment: .top, spacing: tokens.spacingXs) {
                checkbox
                Text(L10n.Composer.Checkmark.channelReply)
                    .font(fonts.footnote)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(sendInChannel ? Color(colors.textPrimary) : Color(colors.textTertiary))
                Spacer()
            }
        }
        .padding(.horizontal, tokens.spacingXs)
        .padding(.bottom, tokens.spacingSm)
        .accessibilityIdentifier("SendInChannelView")
    }

    @ViewBuilder
    private var checkbox: some View {
        ZStack {
            if sendInChannel {
                RoundedRectangle(cornerRadius: tokens.radiusSm)
                    .fill(Color(colors.controlRadioCheckBackgroundSelected))
                    .frame(width: checkboxSize, height: checkboxSize)
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(colors.controlRadioCheckIcon))
            } else {
                RoundedRectangle(cornerRadius: tokens.radiusSm)
                    .stroke(Color(colors.controlRadioCheckBorder), lineWidth: 1)
                    .frame(width: checkboxSize, height: checkboxSize)
            }
        }
        .frame(width: checkboxSize, height: checkboxSize)
    }
}
