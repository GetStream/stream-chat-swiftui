//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

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

    var factory: Factory
    var channel: ChatChannel
    var message: ChatMessage
    var replyCount: Int
    var isRightAligned: Bool
    var showReplyCount: Bool
    var threadReplyMessage: ChatMessage? // The actual reply message (for showReplyInChannel messages)

    public init(
        factory: Factory,
        channel: ChatChannel,
        message: ChatMessage,
        replyCount: Int,
        showReplyCount: Bool = true,
        isRightAligned: Bool? = nil,
        threadReplyMessage: ChatMessage? = nil
    ) {
        self.factory = factory
        self.channel = channel
        self.message = message
        self.replyCount = replyCount
        self.isRightAligned = isRightAligned ?? message.isRightAligned
        self.showReplyCount = showReplyCount
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
            HStack {
                if !isRightAligned {
                    messageAvatarView
                }
                Text(title)
                    .font(fonts.footnoteBold)
                if isRightAligned {
                    messageAvatarView
                }
            }
            .padding(.horizontal, 16)
            .overlay(
                Path { path in
                    let corner: CGFloat = 16
                    let height: CGFloat = 2 * corner
                    let startX: CGFloat = 0
                    let endX = startX + corner

                    path.move(to: CGPoint(x: startX, y: 0))
                    path.addLine(to: CGPoint(x: startX, y: height - corner))
                    path.addQuadCurve(
                        to: CGPoint(x: endX, y: height),
                        control: CGPoint(x: startX, y: height)
                    )
                }
                .stroke(
                    Color(colors.innerBorder),
                    style: StrokeStyle(
                        lineWidth: 1.0,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .offset(y: -24)
                .rotation3DEffect(
                    .degrees(isRightAligned ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )
            )
            .foregroundColor(colors.tintColor)
        }
    }
    
    var title: String {
        if showReplyCount {
            return "\(replyCount) \(repliesText)"
        } else {
            return L10n.Message.Threads.reply
        }
    }

    var repliesText: String {
        if message.replyCount == 1 {
            return L10n.Message.Threads.reply
        } else {
            return L10n.Message.Threads.replies
        }
    }

    private var messageAvatarView: some View {
        // This is just a fallback for backwards compatibility
        // In practice thread participants will never be empty.
        // So, the factory method will always run.
        Group {
            if let participant = message.threadParticipants.first {
                let displayInfo = UserDisplayInfo(
                    id: participant.id,
                    name: participant.name ?? participant.id,
                    imageURL: participant.imageURL,
                    size: .init(width: 16, height: 16)
                )
                factory.makeMessageAvatarView(for: displayInfo)
            } else {
                MessageAvatarView(
                    avatarURL: message.threadParticipants.first?.imageURL,
                    size: .init(width: 16, height: 16)
                )
            }
        }
    }
}

/// Lazy view that uses the message controller to fetch the parent message before creating message replies view.
/// This is needed when the parent message is not available in the local cache.
/// Changing the `parentMessage` to `nil` in the `MessageRepliesView` would case multiple changes including breaking changes.
struct LazyMessageRepliesView<Factory: ViewFactory>: View {
    @StateObject private var parentMessageObserver: ChatMessageController.ObservableObject

    var factory: Factory
    var channel: ChatChannel
    var message: ChatMessage

    init(
        factory: Factory,
        channel: ChatChannel,
        message: ChatMessage,
        parentMessageController: ChatMessageController
    ) {
        _parentMessageObserver = StateObject(wrappedValue: parentMessageController.observableObject)
        self.factory = factory
        self.channel = channel
        self.message = message
    }

    var body: some View {
        VStack {
            if let parentMessage = parentMessageObserver.message {
                factory.makeMessageRepliesShownInChannelView(
                    channel: channel,
                    message: message,
                    parentMessage: parentMessage,
                    replyCount: parentMessage.replyCount
                )
            } else {
                EmptyView()
            }
        }.onAppear {
            if parentMessageObserver.message == nil {
                parentMessageObserver.controller.synchronize()
            }
        }
    }
}
