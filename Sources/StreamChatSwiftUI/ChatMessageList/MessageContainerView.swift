//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public struct MessageContainerView<Factory: ViewFactory>: View {
    @StateObject var messageViewModel: MessageViewModel
    @Environment(\.highlightedMessageId) var highlightedMessageId

    @Injected(\.colors) private var colors
    @Injected(\.images) private var images
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

    public init(
        factory: Factory,
        channel: ChatChannel,
        message: ChatMessage,
        width: CGFloat? = nil,
        showsAllInfo: Bool,
        isInThread: Bool,
        isLast: Bool,
        scrolledId: Binding<String?>,
        quotedMessage: Binding<ChatMessage?>,
        onLongPress: @escaping (MessageDisplayInfo) -> Void,
        viewModel: MessageViewModel? = nil
    ) {
        self.factory = factory
        self.channel = channel
        self.message = message
        self.width = width
        self.showsAllInfo = showsAllInfo
        self.isInThread = isInThread
        self.isLast = isLast
        self.onLongPress = onLongPress
        _messageViewModel = .init(
            wrappedValue: viewModel ?? MessageViewModel(
                message: message,
                channel: channel
            )
        )
        _scrolledId = scrolledId
        _quotedMessage = quotedMessage
    }

    public var body: some View {
        HStack(alignment: .bottom) {
            if messageViewModel.systemMessageShown {
                factory.makeSystemMessageView(options: SystemMessageViewOptions(message: message))
            } else {
                MessageDecoratedView(
                    factory: factory,
                    channel: channel,
                    message: message,
                    contentWidth: contentWidth,
                    isFirst: showsAllInfo,
                    isInThread: isInThread,
                    isLast: isLast,
                    isPinned: messageViewModel.isPinned,
                    scrolledId: $scrolledId,
                    viewModel: messageViewModel,
                    onReactionTap: {
                        handleGestureForMessage(showsMessageActions: false)
                    },
                    onReactionLongPress: {
                        handleGestureForMessage(showsMessageActions: false)
                    }
                )
                .background(
                    GeometryReader { proxy in
                        Rectangle().fill(Color.clear)
                            .onChange(of: computeFrame, perform: { _ in
                                frame = proxy.frame(in: .global)
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
                .offset(x: min(offsetX, maximumHorizontalSwipeDisplacement))
                .simultaneousGesture(
                    DragGesture(
                        minimumDistance: minimumSwipeDistance,
                        coordinateSpace: .local
                    )
                    .updating($offset) { (value, gestureState, _) in
                        guard messageViewModel.isSwipeToQuoteReplyPossible else {
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
                    if !channel.config.quotesEnabled {
                        return
                    }

                    if offset == .zero {
                        // gesture ended or cancelled
                        setOffsetX(value: 0)
                    } else {
                        dragChanged(to: offset.width)
                    }
                })
                .overlay(
                    offsetX > 0 ?
                        TopLeftView {
                            Image(uiImage: images.messageActionInlineReply)
                        }
                        .offset(x: -32)
                        : nil
                )
            }
        }
        .background(
            Group {
                if utils.messageListConfig.highlightMessageWhenJumping,
                   let highlightedMessageId = highlightedMessageId,
                   highlightedMessageId == message.messageId {
                    Color(colors.messageCellHighlightBackground)
                } else if messageViewModel.isPinned {
                    Color(colors.pinnedMessageBackground)
                }
            }
        )
        .transition(
            message.isSentByCurrentUser ?
                messageListConfig.messageDisplayOptions.currentUserMessageTransition :
                messageListConfig.messageDisplayOptions.otherUserMessageTransition
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("MessageContainerView")
    }

    private var maximumHorizontalSwipeDisplacement: CGFloat {
        replyThreshold + 30
    }

    private var contentWidth: CGFloat {
        let padding: CGFloat = messageListConfig.messagePaddings.horizontal
        let minimumWidth: CGFloat = 240
        let available = max(minimumWidth, (width ?? 0) - spacerWidth) - 2 * padding
        let avatarSize: CGFloat = AvatarSize.medium + padding
        return available - avatarSize
    }

    private var spacerWidth: CGFloat {
        messageListConfig.messageDisplayOptions.spacerWidth(width ?? 0)
    }

    private var topReactionsShown: Bool {
        if messageListConfig.messageDisplayOptions.reactionsPlacement == .bottom {
            return false
        }
        return reactionsShown
    }
    
    private var bottomReactionsShown: Bool {
        if messageListConfig.messageDisplayOptions.reactionsPlacement == .top {
            return false
        }
        return reactionsShown
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

        if horizontalTranslation >= minimumSwipeDistance {
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

    private var minimumSwipeDistance: CGFloat {
        utils.messageListConfig.messageDisplayOptions.minimumSwipeGestureDistance
    }

    private func setOffsetX(value: CGFloat) {
        withAnimation(.interpolatingSpring(stiffness: 170, damping: 20)) {
            offsetX = value
        }
    }

    func handleGestureForMessage(
        showsMessageActions: Bool
    ) {
        guard message.isInteractionEnabled else {
            return
        }

        computeFrame.toggle()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
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

// Environment plumbing colocated to avoid adding new files to the package list.
private struct HighlightedMessageIdKey: EnvironmentKey {
    static let defaultValue: String? = nil
}

extension EnvironmentValues {
    var highlightedMessageId: String? {
        get { self[HighlightedMessageIdKey.self] }
        set { self[HighlightedMessageIdKey.self] = newValue }
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
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("SendFailureIndicator")
    }
}

public final class MessageDisplayInfo: Sendable {
    public let message: ChatMessage
    public let frame: CGRect
    public let contentWidth: CGFloat
    public let isFirst: Bool
    public let showsMessageActions: Bool
    public let keyboardWasShown: Bool

    public init(
        message: ChatMessage,
        frame: CGRect,
        contentWidth: CGFloat,
        isFirst: Bool,
        showsMessageActions: Bool = true,
        keyboardWasShown: Bool = false
    ) {
        self.message = message
        self.frame = frame
        self.contentWidth = contentWidth
        self.isFirst = isFirst
        self.showsMessageActions = showsMessageActions
        self.keyboardWasShown = keyboardWasShown
    }
}
