//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import AVKit
import Nuke
import NukeUI
import StreamChat
import SwiftUI

struct MessageContainerView<Factory: ViewFactory>: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images
    @Injected(\.chatClient) private var chatClient
    
    var factory: Factory
    let channel: ChatChannel
    let message: ChatMessage
    let isInGroup: Bool
    var width: CGFloat?
    var showsAllInfo: Bool
    var isInThread: Bool
    @Binding var scrolledId: String?
    @Binding var quotedMessage: ChatMessage?
    var onLongPress: (MessageDisplayInfo) -> Void
    
    @State private var frame: CGRect = .zero
    @State private var computeFrame = false
    @State private var offsetX: CGFloat = 0
    @GestureState private var offset: CGSize = .zero
    
    private let replyThreshold: CGFloat = 60
    
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
                
                if offsetX > 0 {
                    VStack {
                        Image(uiImage: images.messageActionInlineReply)
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                
                VStack(alignment: message.isSentByCurrentUser ? .trailing : .leading) {
                    MessageView(
                        factory: factory,
                        message: message,
                        contentWidth: contentWidth,
                        isFirst: showsAllInfo,
                        scrolledId: $scrolledId
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
                    .offset(x: self.offsetX)
                    .simultaneousGesture(
                        DragGesture(
                            minimumDistance: 10,
                            coordinateSpace: .local
                        )
                        .updating($offset) { (value, gestureState, _) in
                            if message.isDeleted {
                                return
                            }
                            // Using updating since onEnded is not called if the gesture is canceled.
                            let diff = CGSize(
                                width: value.location.x - value.startLocation.x,
                                height: value.location.y - value.startLocation.y
                            )
                            
                            if diff == .zero {
                                gestureState = .zero
                            } else {
                                gestureState = value.translation
                            }
                        }
                    )
                    .onChange(of: offset, perform: { _ in
                        if offset == .zero {
                            // gesture ended or cancelled
                            setOffsetX(value: 0)
                        } else {
                            dragChanged(to: offset.width)
                        }
                    })
                    
                    if message.replyCount > 0 && !message.threadParticipants.isEmpty && !isInThread {
                        MessageRepliesView(
                            factory: factory,
                            channel: channel,
                            message: message,
                            replyCount: message.replyCount
                        )
                    }
                                        
                    if showsAllInfo && !message.isDeleted {
                        if isInGroup && !message.isSentByCurrentUser {
                            MessageAuthorAndDateView(message: message)
                        } else if message.isSentByCurrentUser {
                            HStack(spacing: 4) {
                                factory.makeMessageReadIndicatorView(
                                    readUsers: channel.readUsers(
                                        currentUserId: chatClient.currentUserId
                                    ),
                                    showReadCount: isInGroup
                                )
                                MessageDateView(message: message)
                            }
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
    
    private func dragChanged(to value: CGFloat) {
        let horizontalTranslation = value
         
        if horizontalTranslation < 0 {
            // prevent swiping to right.
            return
        }
                 
        if horizontalTranslation > 0 {
            offsetX = horizontalTranslation
        } else {
            offsetX = 0
        }
        
        if offsetX > replyThreshold && quotedMessage != message {
            triggerHapticFeedback(style: .medium)
            withAnimation {
                quotedMessage = message
            }
        }
    }
    
    private func setOffsetX(value: CGFloat) {
        withAnimation {
            self.offsetX = value
        }
    }
}

public struct MessageDisplayInfo {
    let message: ChatMessage
    let frame: CGRect
    let contentWidth: CGFloat
    let isFirst: Bool
}
