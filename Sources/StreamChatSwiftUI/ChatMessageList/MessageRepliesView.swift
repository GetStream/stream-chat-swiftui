//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Combine
import StreamChat
import SwiftUI

enum MessageRepliesConstants {
    static let selectedMessageThread = "selectedMessageThread"
    static let selectedMessage = "selectedMessage"
    static let threadReplyMessage = "threadReplyMessage"
}

/// View shown below a message, when there are replies to it.
public struct MessageRepliesView<Factory: ViewFactory>: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens

    var factory: Factory
    var channel: ChatChannel
    var message: ChatMessage
    var replyCount: Int
    var isRightAligned: Bool
    var showReplyCount: Bool
    /// When true, the `textOnAccent` color is used instead of the default darker text color.
    var usesInvertedStyle: Bool
    var threadReplyMessage: ChatMessage?

    public init(
        factory: Factory,
        channel: ChatChannel,
        message: ChatMessage,
        replyCount: Int,
        showReplyCount: Bool = true,
        isRightAligned: Bool? = nil,
        usesInvertedStyle: Bool = false,
        threadReplyMessage: ChatMessage? = nil
    ) {
        self.factory = factory
        self.channel = channel
        self.message = message
        self.replyCount = replyCount
        self.isRightAligned = isRightAligned ?? message.isRightAligned
        self.showReplyCount = showReplyCount
        self.usesInvertedStyle = usesInvertedStyle
        self.threadReplyMessage = threadReplyMessage
    }

    public var body: some View {
        Button {
            // NOTE: Needed because of a bug in iOS 16.
            resignFirstResponder()
            // NOTE: this is used to avoid breaking changes.
            // Will be updated in a major release.
            var userInfo: [String: Any] = [MessageRepliesConstants.selectedMessage: message]
            if let threadReplyMessage = threadReplyMessage {
                userInfo[MessageRepliesConstants.threadReplyMessage] = threadReplyMessage
            }
            NotificationCenter.default.post(
                name: NSNotification.Name(MessageRepliesConstants.selectedMessageThread),
                object: nil,
                userInfo: userInfo
            )
        } label: {
            HStack(spacing: tokens.spacingXs) {
                if !isRightAligned {
                    messageAvatarView
                }
                Text(title)
                    .font(fonts.footnoteBold)
                if isRightAligned {
                    messageAvatarView
                }
            }
            .padding(.horizontal, 16 + tokens.spacingXs)
            .padding(.top, tokens.spacingXxs)
            .overlay(
                Path { path in
                    path.move(to: CGPoint(x: 0.5, y: 0))
                    path.addLine(to: CGPoint(x: 0.5, y: 20.5))
                    path.addCurve(
                        to: CGPoint(x: 16, y: 36),
                        control1: CGPoint(x: 0.5, y: 29.0604),
                        control2: CGPoint(x: 7.43959, y: 36)
                    )
                }
                .stroke(
                    Color(message.isSentByCurrentUser ? colors.chatBackgroundOutgoing : colors.chatBackgroundIncoming),
                    style: StrokeStyle(
                        lineWidth: 1.0,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .frame(width: 16, height: 48)
                .offset(y: -10)
                .rotation3DEffect(
                    .degrees(isRightAligned ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0)
                ),
                alignment: isRightAligned ? .trailing : .leading
            )
            .foregroundColor(usesInvertedStyle ? colors.textOnAccent.toColor : colors.textPrimary.toColor)
        }
    }
    
    var title: String {
        if showReplyCount {
            "\(replyCount) \(repliesText)"
        } else {
            L10n.Message.Threads.reply
        }
    }

    var repliesText: String {
        if message.replyCount == 1 {
            L10n.Message.Threads.reply
        } else {
            L10n.Message.Threads.replies
        }
    }

    @ViewBuilder private var messageAvatarView: some View {
        if let participant = message.threadParticipants.first {
            factory.makeUserAvatarView(
                options: .init(
                    user: participant,
                    size: AvatarSize.extraSmall,
                    showsIndicator: false
                )
            )
        } else {
            UserAvatar(url: nil, initials: "", size: AvatarSize.extraSmall, indicator: .none)
        }
    }
}

extension ChatMessageController {
    @MainActor var observableObject: ObservableObject { .init(controller: self) }

    final class ObservableObject: SwiftUI.ObservableObject, ChatMessageControllerDelegate {
        let controller: ChatMessageController
        @Published public private(set) var message: ChatMessage?

        init(controller: ChatMessageController) {
            self.controller = controller
            controller.delegate = self
            message = controller.message
        }
        
        func messageController(
            _ controller: ChatMessageController,
            didChangeMessage change: EntityChange<ChatMessage>
        ) {
            message = controller.message
        }
    }
}
