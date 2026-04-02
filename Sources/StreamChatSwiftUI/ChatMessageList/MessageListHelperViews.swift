//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View that displays the message author and the date of sending.
public struct MessageAuthorAndDateView: View {
    @Injected(\.utils) private var utils
    @Injected(\.colors) private var colors
    
    var message: ChatMessage
    /// When true, the `textOnAccent` color is used instead of the default darker text color.
    var usesInvertedStyle: Bool
    
    public init(message: ChatMessage, usesInvertedStyle: Bool = false) {
        self.message = message
        self.usesInvertedStyle = usesInvertedStyle
    }
    
    public var body: some View {
        HStack {
            MessageAuthorView(message: message, usesInvertedStyle: usesInvertedStyle)
                .accessibilityIdentifier("MessageAuthorView")
            if utils.messageListConfig.messageDisplayOptions.showMessageDate {
                MessageDateView(message: message, usesInvertedStyle: usesInvertedStyle)
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
    /// When true, the `textOnAccent` color is used instead of the default darker text color.
    var usesInvertedStyle: Bool
    
    public init(message: ChatMessage, usesInvertedStyle: Bool = false) {
        self.message = message
        self.usesInvertedStyle = usesInvertedStyle
    }
    
    var authorName: String {
        message.author.name ?? message.author.id
    }
    
    public var body: some View {
        Text(authorName)
            .lineLimit(1)
            .font(fonts.footnoteBold)
            .foregroundColor(usesInvertedStyle ? colors.textOnAccent.toColor : colors.chatTextUsername.toColor)
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
    
    let message: ChatMessage
    /// When true, the `textOnAccent` color is used instead of the default darker text color.
    var usesInvertedStyle: Bool = false
    
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
            .foregroundColor(usesInvertedStyle ? colors.textOnAccent.toColor : colors.chatTextTimestamp.toColor)
            .animation(nil, value: text)
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
    var showDelivered: Bool
    var localState: LocalMessageState?
    /// When true, the `textOnAccent` color is used instead of the default darker text color.
    var usesInvertedStyle: Bool
    
    public init(
        readUsers: [ChatUser],
        showDelivered: Bool = false,
        localState: LocalMessageState? = nil,
        usesInvertedStyle: Bool = false
    ) {
        self.readUsers = readUsers
        self.showDelivered = showDelivered
        self.localState = localState
        self.usesInvertedStyle = usesInvertedStyle
    }
    
    public var body: some View {
        HStack(spacing: 2) {
            Image(
                uiImage: image
            )
            .customizable()
            .foregroundColor(usesInvertedStyle ? colors.textOnAccent.toColor : (shouldShowReads ? Color(colors.accentPrimary) : colors.chatTextTimestamp.toColor))
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
        shouldShowReads || showDelivered ? images.messageDeliveryStatusRead : (isMessageSending ? images.messageDeliveryStatusSending : images.messageDeliveryStatusSent)
    }

    private var isMessageSending: Bool {
        localState == .sending || localState == .pendingSend || localState == .syncing
    }

    private var shouldShowReads: Bool {
        !readUsers.isEmpty && !isMessageSending
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
            return Color(colors.chatTextOutgoing)
        } else {
            return Color(colors.chatTextIncoming)
        }
    }
    
    func textColor(currentUser: Bool) -> Color {
        @Injected(\.colors) var colors
        return currentUser ? Color(colors.chatTextOutgoing) : Color(colors.chatTextIncoming)
    }
}
