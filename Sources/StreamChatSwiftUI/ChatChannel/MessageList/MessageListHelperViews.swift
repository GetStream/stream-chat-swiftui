//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct MessageAuthorAndDateView: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    
    var message: ChatMessage
    
    var body: some View {
        HStack {
            Text(message.author.name ?? "")
                .font(fonts.footnoteBold)
                .foregroundColor(Color(colors.textLowEmphasis))
            MessageDateView(message: message)
            Spacer()
        }
    }
}

struct MessageDateView: View {
    @Injected(\.utils) private var utils
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    
    private var dateFormatter: DateFormatter {
        utils.dateFormatter
    }
    
    var message: ChatMessage
    
    var body: some View {
        Text(dateFormatter.string(from: message.createdAt))
            .font(fonts.footnote)
            .foregroundColor(Color(colors.textLowEmphasis))
    }
}

struct MessageReadIndicatorView: View {
    @Injected(\.images) private var images
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    
    var readUsers: [ChatUser]
    var showReadCount: Bool
    
    var body: some View {
        HStack(spacing: 2) {
            if showReadCount && !readUsers.isEmpty {
                Text("\(readUsers.count)")
                    .font(fonts.footnoteBold)
                    .foregroundColor(colors.tintColor)
            }
            Image(
                uiImage: !readUsers.isEmpty ? images.readByAll : images.messageSent
            )
            .customizable()
            .foregroundColor(!readUsers.isEmpty ? colors.tintColor : Color(colors.textLowEmphasis))
            .frame(height: 16)
        }
    }
}

struct MessageSpacer: View {
    var spacerWidth: CGFloat?
    
    var body: some View {
        Spacer()
            .frame(minWidth: spacerWidth)
            .layoutPriority(-1)
    }
}

struct MessagePinDetailsView: View {
    
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images
    @Injected(\.fonts) private var fonts
    
    var message: ChatMessage
    var reactionsShown: Bool
    
    var body: some View {
        HStack {
            Image(uiImage: images.pin)
                .customizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 12)
            Text("\(L10n.Message.Cell.pinnedBy) \(message.pinDetails?.pinnedBy.name ?? L10n.Message.Cell.unknownPin)")
                .font(fonts.footnote)
        }
        .foregroundColor(Color(colors.textLowEmphasis))
        .frame(height: 16)
        .padding(.bottom, reactionsShown ? 16 : 0)
        .padding(.top, 4)
    }
}
