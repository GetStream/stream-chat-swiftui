//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View for the check whether the view should be send in the channel.
struct SendInChannelView: View {

    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts

    @Binding var sendInChannel: Bool
    var isDirectMessage: Bool

    var body: some View {
        HStack {
            Button {
                sendInChannel.toggle()
            } label: {
                Image(systemName: sendInChannel ? "checkmark.square.fill" : "square")
                    .foregroundColor(sendInChannel ? colors.tintColor : Color(colors.background7))
            }

            Text(isDirectMessage ? L10n.Composer.Checkmark.directMessageReply : L10n.Composer.Checkmark.channelReply)
                .font(fonts.footnote)
                .foregroundColor(Color(colors.textLowEmphasis))

            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
        .accessibilityIdentifier("SendInChannelView")
    }
}
