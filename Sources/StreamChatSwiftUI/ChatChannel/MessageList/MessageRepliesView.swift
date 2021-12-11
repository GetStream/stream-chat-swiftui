//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View shown below a message, when there are replies to it.
struct MessageRepliesView<Factory: ViewFactory>: View {
    
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    
    var factory: Factory
    var channel: ChatChannel
    var message: ChatMessage
    var replyCount: Int
    
    var threadDestination: Factory.MessageThreadDestination {
        let threadDestination = factory.makeMessageThreadDestination()
        return threadDestination(channel, message)
    }
    
    var body: some View {
        NavigationLink {
            LazyView(threadDestination)
        } label: {
            HStack {
                if !message.isSentByCurrentUser {
                    MessageAvatarView(
                        author: message.threadParticipants[0],
                        size: .init(width: 16, height: 16)
                    )
                }
                Text("\(replyCount) \(repliesText)")
                    .font(fonts.footnoteBold)
                if message.isSentByCurrentUser {
                    MessageAvatarView(
                        author: message.threadParticipants[0],
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
                    .degrees(message.isSentByCurrentUser ? 180 : 0),
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
