//
// Copyright © 2026 Stream.io Inc. All rights reserved.
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
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("MessageAuthorAndDateView")
    }
}

/// View that displays the message author.
public struct MessageAuthorView: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    
    var message: ChatMessage
    
    public init(message: ChatMessage) {
        self.message = message
    }
    
    var authorName: String {
        message.author.name ?? message.author.id
    }
    
    public var body: some View {
        Text(authorName)
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
        let messageListConfig = utils.messageListConfig
        let showMessageEditedLabel = messageListConfig.isMessageEditedLabelEnabled
            && !messageListConfig.skipEditedMessageLabel(message)
            && message.textUpdatedAt != nil
            && !message.isDeleted
        if showMessageEditedLabel {
            text = text + " • " + L10n.Message.Cell.edited
        }
        return text
    }
    
    var accessibilityLabel: String {
        L10n.Message.Cell.sentAt(text)
    }
    
    var body: some View {
        Text(text)
            .font(fonts.footnote)
            .foregroundColor(Color(colors.textLowEmphasis))
            .animation(nil)
            .accessibilityLabel(Text(accessibilityLabel))
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
    var showDelivered: Bool
    var localState: LocalMessageState?
    
    public init(
        readUsers: [ChatUser],
        showReadCount: Bool,
        showDelivered: Bool = false,
        localState: LocalMessageState? = nil
    ) {
        self.readUsers = readUsers
        self.showReadCount = showReadCount
        self.showDelivered = showDelivered
        self.localState = localState
    }
    
    public var body: some View {
        HStack(spacing: 2) {
            if showReadCount && shouldShowReads {
                Text("\(readUsers.count)")
                    .font(fonts.footnoteBold)
                    .foregroundColor(colors.tintColor)
                    .accessibilityIdentifier("readIndicatorCount")
            }
            Image(
                uiImage: image
            )
            .customizable()
            .foregroundColor(shouldShowReads ? colors.tintColor : Color(colors.textLowEmphasis))
            .frame(height: 16)
            .opacity(localState == .sendingFailed || localState == .syncingFailed ? 0.0 : 1)
            .accessibilityLabel(
                Text(
                    readUsers.isEmpty ? L10n.Message.ReadStatus.seenByNoOne : L10n.Message.ReadStatus.seenByOthers
                )
            )
            .accessibilityIdentifier("readIndicatorCheckmark")
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("MessageReadIndicatorView")
    }
    
    private var image: UIImage {
        shouldShowReads || showDelivered ? images.readByAll : (isMessageSending ? images.messageReceiptSending : images.messageSent)
    }

    private var isMessageSending: Bool {
        localState == .sending || localState == .pendingSend || localState == .syncing
    }

    private var shouldShowReads: Bool {
        !readUsers.isEmpty && !isMessageSending
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
                .accessibilityHidden(true)
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
        
        if message.isDeleted {
            return Color(colors.textLowEmphasis)
        }
        if message.isSentByCurrentUser {
            return Color(colors.messageCurrentUserTextColor)
        } else {
            return Color(colors.messageOtherUserTextColor)
        }
    }
    
    func textColor(currentUser: Bool) -> Color {
        @Injected(\.colors) var colors
        return currentUser ? Color(colors.messageCurrentUserTextColor) : Color(colors.messageOtherUserTextColor)
    }
}
