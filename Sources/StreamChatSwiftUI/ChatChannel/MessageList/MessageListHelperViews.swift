//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View that displays the message author and the date of sending.
public struct MessageAuthorAndDateView: View {
    
    @Injected(\.utils) private var utils
    
    var message: ChatMessage
    
    public init(message: ChatMessage) {
        self.message = message
    }
    
    public var body: some View {
        HStack {
            MessageAuthorView(message: message)
                .accessibilityIdentifier("MessageAuthorView")
            if utils.messageListConfig.messageDisplayOptions.showMessageDate {
                MessageDateView(message: message)
                    .accessibilityIdentifier("MessageDateView")
            }
            Spacer()
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("MessageAuthorAndDateView")
    }
}

/// View that displays the message author.
public struct MessageAuthorView: View {
    
    @Injected(\.utils) private var utils
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    
    var message: ChatMessage
    
    public init(message: ChatMessage) {
        self.message = message
    }
    
    public var body: some View {
        Text(utils.messageCachingUtils.authorName(for: message))
            .lineLimit(1)
            .font(fonts.footnoteBold)
            .foregroundColor(Color(colors.textLowEmphasis))
    }
}

/// View that displays the sending date of a message.
struct MessageDateView: View {
    @Injected(\.utils) private var utils
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    
    private var dateFormatter: DateFormatter {
        utils.dateFormatter
    }
    
    var message: ChatMessage
    
    var text: String {
        var text = dateFormatter.string(from: message.createdAt)
        let showMessageEditedLabel = utils.messageListConfig.isMessageEditedLabelEnabled
            && message.textUpdatedAt != nil
            && !message.isDeleted
        if showMessageEditedLabel {
            text = text + " • " + L10n.Message.Cell.edited
        }
        return text
    }
    
    var body: some View {
        Text(text)
            .font(fonts.footnote)
            .foregroundColor(Color(colors.textLowEmphasis))
            .animation(nil)
            .accessibilityIdentifier("MessageDateView")
    }
}

/// View that displays the read indicator for a message.
public struct MessageReadIndicatorView: View {
    @Injected(\.images) private var images
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    
    var readUsers: [ChatUser]
    var showReadCount: Bool
    var localState: LocalMessageState?
    
    public init(readUsers: [ChatUser], showReadCount: Bool, localState: LocalMessageState? = nil) {
        self.readUsers = readUsers
        self.showReadCount = showReadCount
        self.localState = localState
    }
    
    public var body: some View {
        HStack(spacing: 2) {
            if showReadCount && !readUsers.isEmpty {
                Text("\(readUsers.count)")
                    .font(fonts.footnoteBold)
                    .foregroundColor(colors.tintColor)
                    .accessibilityIdentifier("readIndicatorCount")
            }
            Image(
                uiImage: image
            )
            .customizable()
            .foregroundColor(!readUsers.isEmpty ? colors.tintColor : Color(colors.textLowEmphasis))
            .frame(height: 16)
            .accessibilityIdentifier("readIndicatorCheckmark")
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("MessageReadIndicatorView")
    }
    
    private var image: UIImage {
        !readUsers.isEmpty ? images.readByAll : (localState == .pendingSend ? images.messageReceiptSending : images.messageSent)
    }
}

/// Message spacer view, used for adding space depending on who sent the message..
struct MessageSpacer: View {
    var spacerWidth: CGFloat?
    
    var body: some View {
        Spacer()
            .frame(minWidth: spacerWidth)
            .layoutPriority(-1)
    }
}

/// View that's displayed when a message is pinned.
public struct MessagePinDetailsView: View {
    
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images
    @Injected(\.fonts) private var fonts
    
    var message: ChatMessage
    var reactionsShown: Bool
    
    public init(message: ChatMessage, reactionsShown: Bool) {
        self.message = message
        self.reactionsShown = reactionsShown
    }
    
    public var body: some View {
        HStack {
            Image(uiImage: images.pin)
                .customizable()
                .frame(maxHeight: 12)
            Text("\(L10n.Message.Cell.pinnedBy) \(message.pinDetails?.pinnedBy.name ?? L10n.Message.Cell.unknownPin)")
                .font(fonts.footnote)
        }
        .foregroundColor(Color(colors.textLowEmphasis))
        .frame(height: 16)
        .padding(.bottom, reactionsShown ? 16 : 0)
        .padding(.top, 4)
        .accessibilityIdentifier("MessagePinDetailsView")
    }
}

public struct TopLeftView<Content: View>: View {
    
    var content: () -> Content
    
    public init(content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        VStack {
            HStack {
                content()
                Spacer()
            }
            Spacer()
        }
    }
}

extension View {
    
    public func textColor(for message: ChatMessage) -> Color {
        @Injected(\.colors) var colors
        
        if message.isSentByCurrentUser {
            return Color(colors.messageCurrentUserTextColor)
        } else {
            return Color(colors.messageOtherUserTextColor)
        }
    }
}
