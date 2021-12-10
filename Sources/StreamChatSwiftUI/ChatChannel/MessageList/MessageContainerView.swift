//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import AVKit
import Nuke
import NukeUI
import StreamChat
import SwiftUI

struct MessageContainerView<Factory: ViewFactory>: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    
    var factory: Factory
    let channel: ChatChannel
    let message: ChatMessage
    let isInGroup: Bool
    var width: CGFloat?
    var showsAllInfo: Bool
    var isInThread: Bool
    var onLongPress: (MessageDisplayInfo) -> Void
    
    @State private var frame: CGRect = .zero
    @State private var computeFrame = false
    
    var body: some View {
        HStack(alignment: .bottom) {
            if message.type == .system {
                SystemMessageView(message: message.text)
            } else {
                if message.isSentByCurrentUser {
                    MessageSpacer(spacerWidth: spacerWidth)
                } else {
                    if showsAllInfo {
                        factory.makeMessageAvatarView(for: message.author)
                    } else {
                        Color.clear
                            .frame(width: CGSize.messageAvatarSize.width)
                    }
                }
                
                VStack(alignment: message.isSentByCurrentUser ? .trailing : .leading) {
                    MessageView(
                        factory: factory,
                        message: message,
                        contentWidth: contentWidth,
                        isFirst: showsAllInfo
                    )
                    .overlay(
                        reactionsShown ?
                            factory.makeMessageReactionView(message: message)
                            : nil
                    )
                    .background(
                        GeometryReader { proxy in
                            Rectangle().fill(Color.clear)
                                .onChange(of: computeFrame, perform: { _ in
                                    DispatchQueue.main.async {
                                        frame = proxy.frame(in: .global)
                                    }
                                })
                        }
                    )
                    .onTapGesture {}
                    .onLongPressGesture(perform: {
                        computeFrame = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            computeFrame = false
                            triggerHapticFeedback(style: .medium)
                            onLongPress(
                                MessageDisplayInfo(
                                    message: message,
                                    frame: frame,
                                    contentWidth: contentWidth,
                                    isFirst: showsAllInfo
                                )
                            )
                        }

                    })
                    
                    if message.replyCount > 0 && !message.threadParticipants.isEmpty && !isInThread {
                        MessageRepliesView(
                            factory: factory,
                            channel: channel,
                            message: message
                        )
                    }
                                        
                    if showsAllInfo && !message.isDeleted {
                        if isInGroup && !message.isSentByCurrentUser {
                            MessageAuthorAndDateView(message: message)
                        } else {
                            MessageDateView(message: message)
                        }
                    }
                }
                
                if !message.isSentByCurrentUser {
                    MessageSpacer(spacerWidth: spacerWidth)
                }
            }
        }
        .padding(.top, reactionsShown ? 24 : 0)
    }
    
    private var contentWidth: CGFloat {
        let padding: CGFloat = 8
        let minimumWidth: CGFloat = 240
        let available = max(minimumWidth, (width ?? 0) - spacerWidth) - 2 * padding
        let avatarSize: CGFloat = CGSize.messageAvatarSize.width + padding
        let totalWidth = message.isSentByCurrentUser ? available : available - avatarSize
        return totalWidth
    }
    
    private var spacerWidth: CGFloat {
        (width ?? 0) / 4
    }
    
    private var reactionsShown: Bool {
        !message.reactionScores.isEmpty && !message.isDeleted
    }
}

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

struct MessageSpacer: View {
    var spacerWidth: CGFloat?
    
    var body: some View {
        Spacer()
            .frame(minWidth: spacerWidth)
            .layoutPriority(-1)
    }
}

public struct MessageDisplayInfo {
    let message: ChatMessage
    let frame: CGRect
    let contentWidth: CGFloat
    let isFirst: Bool
}
