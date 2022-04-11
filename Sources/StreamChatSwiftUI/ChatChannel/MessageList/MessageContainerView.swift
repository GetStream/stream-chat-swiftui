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
    @Injected(\.utils) private var utils
    
    var factory: Factory
    let channel: ChatChannel
    let message: ChatMessage
    var width: CGFloat?
    var showsAllInfo: Bool
    var isInThread: Bool
    var isLast: Bool
    @Binding var scrolledId: String?
    @Binding var quotedMessage: ChatMessage?
    var onLongPress: (MessageDisplayInfo) -> Void
    
    @State private var frame: CGRect = .zero
    @State private var computeFrame = false
    @State private var offsetX: CGFloat = 0
    @GestureState private var offset: CGSize = .zero
    
    private let replyThreshold: CGFloat = 60
    private let paddingValue: CGFloat = 8
    
    var body: some View {
        HStack(alignment: .bottom) {
            if message.type == .system {
                factory.makeSystemMessageView(message: message)
            } else {
                if message.isSentByCurrentUser {
                    MessageSpacer(spacerWidth: spacerWidth)
                } else {
                    if messageListConfig.messageDisplayOptions.showAvatars {
                        factory.makeMessageAvatarView(
                            for: utils.messageCachingUtils.authorInfo(from: message)
                        )
                        .opacity(showsAllInfo ? 1 : 0)
                    }
                }
                
                VStack(alignment: message.isSentByCurrentUser ? .trailing : .leading) {
                    if isMessagePinned {
                        MessagePinDetailsView(
                            message: message,
                            reactionsShown: reactionsShown
                        )
                    }
                    
                    MessageView(
                        factory: factory,
                        message: message,
                        contentWidth: contentWidth,
                        isFirst: showsAllInfo,
                        scrolledId: $scrolledId
                    )
                    .animation(nil)
                    .overlay(
                        ZStack {
                            reactionsShown ?
                                factory.makeMessageReactionView(
                                    message: message,
                                    onTapGesture: {
                                        handleGestureForMessage(showsMessageActions: false)
                                    },
                                    onLongPressGesture: {
                                        handleGestureForMessage(showsMessageActions: false)
                                    }
                                )
                                : nil
                            
                            message.localState == .sendingFailed ? SendFailureIndicator() : nil
                        }
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
                    .onTapGesture(count: 2) {
                        if messageListConfig.doubleTapOverlayEnabled {
                            handleGestureForMessage(showsMessageActions: true)
                        }
                    }
                    .onLongPressGesture(perform: {
                        handleGestureForMessage(showsMessageActions: true)
                    })
                    .offset(x: self.offsetX)
                    .simultaneousGesture(
                        DragGesture(
                            minimumDistance: 10,
                            coordinateSpace: .local
                        )
                        .updating($offset) { (value, gestureState, _) in
                            if message.isDeleted || !channel.config.repliesEnabled {
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
                    
                    if message.replyCount > 0 && !isInThread {
                        MessageRepliesView(
                            factory: factory,
                            channel: channel,
                            message: message,
                            replyCount: message.replyCount
                        )
                    }
                                        
                    if showsAllInfo && !message.isDeleted {
                        if message.isSentByCurrentUser && channel.config.readEventsEnabled {
                            HStack(spacing: 4) {
                                factory.makeMessageReadIndicatorView(
                                    channel: channel,
                                    message: message
                                )
                                
                                if messageListConfig.messageDisplayOptions.showMessageDate {
                                    MessageDateView(message: message)
                                }
                            }
                        } else if !message.isSentByCurrentUser && !channel.isDirectMessageChannel {
                            MessageAuthorAndDateView(message: message)
                        } else if messageListConfig.messageDisplayOptions.showMessageDate {
                            MessageDateView(message: message)
                        }
                    }
                }
                .overlay(
                    offsetX > 0 ?
                        TopLeftView {
                            Image(uiImage: images.messageActionInlineReply)
                        }
                        .offset(x: -32)
                        : nil
                )
                
                if !message.isSentByCurrentUser {
                    MessageSpacer(spacerWidth: spacerWidth)
                }
            }
        }
        .padding(.top, reactionsShown && !isMessagePinned ? 3 * paddingValue : 0)
        .padding(.horizontal, messageListConfig.messagePaddings.horizontal)
        .padding(.bottom, showsAllInfo || isMessagePinned ? paddingValue : 2)
        .padding(.top, isLast ? paddingValue : 0)
        .background(isMessagePinned ? Color(colors.pinnedBackground) : nil)
        .padding(.bottom, isMessagePinned ? paddingValue / 2 : 0)
        .transition(
            message.isSentByCurrentUser ?
                messageListConfig.messageDisplayOptions.currentUserMessageTransition :
                messageListConfig.messageDisplayOptions.otherUserMessageTransition
        )
    }
        
    private var isMessagePinned: Bool {
        message.pinDetails != nil
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
        let proposedViewWidth = width ?? 0
        if isIPad {
            return 2 * proposedViewWidth / 3
        } else {
            return proposedViewWidth / 4
        }
    }
    
    private var reactionsShown: Bool {
        !message.reactionScores.isEmpty
            && !message.isDeleted
            && channel.config.reactionsEnabled
    }
    
    private var messageListConfig: MessageListConfig {
        utils.messageListConfig
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
    
    private func handleGestureForMessage(showsMessageActions: Bool) {
        computeFrame = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            computeFrame = false
            triggerHapticFeedback(style: .medium)
            onLongPress(
                MessageDisplayInfo(
                    message: message,
                    frame: frame,
                    contentWidth: contentWidth,
                    isFirst: showsAllInfo,
                    showsMessageActions: showsMessageActions
                )
            )
        }
    }
}

struct SendFailureIndicator: View {
    
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images
    
    var body: some View {
        BottomRightView {
            Image(uiImage: images.messageListErrorIndicator)
                .customizable()
                .frame(width: 16, height: 16)
                .foregroundColor(Color(colors.alert))
                .offset(y: 4)
        }
    }
}

public struct MessageDisplayInfo {
    let message: ChatMessage
    let frame: CGRect
    let contentWidth: CGFloat
    let isFirst: Bool
    var showsMessageActions: Bool = true
}
