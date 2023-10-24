//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

enum MessageRepliesConstants {
    static let selectedMessageThread = "selectedMessageThread"
    static let selectedMessage = "selectedMessage"
}

/// View shown below a message, when there are replies to it.
public struct MessageRepliesView<Factory: ViewFactory>: View {

    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors

    var factory: Factory
    var channel: ChatChannel
    var message: ChatMessage
    var replyCount: Int

    public init(factory: Factory, channel: ChatChannel, message: ChatMessage, replyCount: Int) {
        self.factory = factory
        self.channel = channel
        self.message = message
        self.replyCount = replyCount
    }

    public var body: some View {
        Button {
            // NOTE: Needed because of a bug in iOS 16.
            resignFirstResponder()
            // NOTE: this is used to avoid breaking changes.
            // Will be updated in a major release.
            NotificationCenter.default.post(
                name: NSNotification.Name(MessageRepliesConstants.selectedMessageThread),
                object: nil,
                userInfo: [MessageRepliesConstants.selectedMessage: message]
            )
        } label: {
            HStack {
                if !message.isRightAligned {
                    MessageAvatarView(
                        avatarURL: message.threadParticipants.first?.imageURL,
                        size: .init(width: 16, height: 16)
                    )
                }
                Text("\(replyCount) \(repliesText)")
                    .font(fonts.footnoteBold)
                if message.isRightAligned {
                    MessageAvatarView(
                        avatarURL: message.threadParticipants.first?.imageURL,
                        size: .init(width: 16, height: 16)
                    )
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
                    .degrees(message.isRightAligned ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )
            )
            .foregroundColor(colors.tintColor)
        }
    }

    var repliesText: String {
        if message.replyCount == 1 {
            return L10n.Message.Threads.reply
        } else {
            return L10n.Message.Threads.replies
        }
    }
}
