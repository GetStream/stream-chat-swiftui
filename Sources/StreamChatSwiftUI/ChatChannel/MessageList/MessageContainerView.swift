//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import AVKit
import StreamChat
import SwiftUI

public struct MessageContainerView<Factory: ViewFactory>: View {
    @StateObject var messageViewModel: MessageViewModel
    @Environment(\.channelTranslationLanguage) var translationLanguage
    @Environment(\.highlightedMessageId) var highlightedMessageId

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
    @State private var offsetYAvatar: CGFloat = 0
    @GestureState private var offset: CGSize = .zero

    private let replyThreshold: CGFloat = 60
    private var paddingValue: CGFloat {
        utils.messageListConfig.messagePaddings.singleBottom
    }
    
    private var groupMessageInterItemSpacing: CGFloat {
        utils.messageListConfig.messagePaddings.groupBottom
    }

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
                factory.makeSystemMessageView(message: message)
            } else {
                if messageViewModel.isRightAligned {
                    MessageSpacer(spacerWidth: spacerWidth)
                } else {
                    if let userDisplayInfo = messageViewModel.userDisplayInfo {
                        factory.makeMessageAvatarView(
                            for: userDisplayInfo
                        )
                        .opacity(showsAllInfo ? 1 : 0)
                        .offset(y: bottomReactionsShown ? offsetYAvatar : 0)
                        .animation(nil)
                    }
                }

                VStack(alignment: messageViewModel.isRightAligned ? .trailing : .leading) {
                    if messageViewModel.isPinned {
                        MessagePinDetailsView(
                            message: message,
                            reactionsShown: topReactionsShown
                        )
                    }

                    MessageView(
                        factory: factory,
                        message: message,
                        contentWidth: contentWidth,
                        isFirst: showsAllInfo,
                        scrolledId: $scrolledId
                    )
                    .overlay(
                        ZStack {
                            topReactionsShown ?
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
                            messageViewModel.failureIndicatorShown ? SendFailureIndicator() : nil
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
                    .offset(x: min(self.offsetX, maximumHorizontalSwipeDisplacement))
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
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier("MessageView")

                    if !isInThread {
                        if message.replyCount > 0 {
                            factory.makeMessageRepliesView(
                                channel: channel,
                                message: message,
                                replyCount: message.replyCount
                            )
                            .accessibilityElement(children: .contain)
                            .accessibility(identifier: "MessageRepliesView")
                        } else if message.showReplyInChannel,
                                  let parentId = message.parentMessageId,
                                  let controller = utils.channelControllerFactory.currentChannelController,
                                  let parentMessage = controller.dataStore.message(id: parentId) {
                            factory.makeMessageRepliesShownInChannelView(
                                channel: channel,
                                message: message,
                                parentMessage: parentMessage,
                                replyCount: parentMessage.replyCount
                            )
                            .accessibilityElement(children: .contain)
                            .accessibility(identifier: "MessageRepliesView")
                        } else if message.showReplyInChannel, let parentId = message.parentMessageId {
                            /// In case the parent message is not available in the local cache, we need to fetch it from the remote server.
                            /// The lazy view uses the `factory.makeMessageRepliesShownInChannelView` internally once the parent message is fetched.
                            LazyMessageRepliesView(
                                factory: factory,
                                channel: channel,
                                message: message,
                                parentMessageController: chatClient.messageController(
                                    cid: channel.cid,
                                    messageId: parentId
                                )
                            )
                            .accessibilityElement(children: .contain)
                            .accessibility(identifier: "MessageRepliesView")
                        }
                    }
                    
                    if bottomReactionsShown {
                        factory.makeBottomReactionsView(message: message, showsAllInfo: showsAllInfo) {
                            handleGestureForMessage(
                                showsMessageActions: false,
                                showsBottomContainer: false
                            )
                        } onLongPress: {
                            handleGestureForMessage(showsMessageActions: false)
                        }
                        .background(
                            GeometryReader { proxy in
                                let frame = proxy.frame(in: .local)
                                let height = frame.height
                                Color.clear.preference(key: HeightPreferenceKey.self, value: height)
                            }
                        )
                        .onPreferenceChange(HeightPreferenceKey.self) { value in
                            if value != 0 {
                                self.offsetYAvatar = -(value ?? 0)
                            }
                        }
                    }

                    if messageViewModel.translatedText != nil {
                        factory.makeMessageTranslationFooterView(
                            messageViewModel: messageViewModel
                        )
                    }

                    if showsAllInfo && !message.isDeleted {
                        if message.isSentByCurrentUser && channel.config.readEventsEnabled {
                            HStack(spacing: 4) {
                                factory.makeMessageReadIndicatorView(
                                    channel: channel,
                                    message: message
                                )

                                if messageViewModel.messageDateShown {
                                    factory.makeMessageDateView(for: message)
                                }
                            }
                        } else if messageViewModel.authorAndDateShown {
                            factory.makeMessageAuthorAndDateView(for: message)
                        } else if messageViewModel.messageDateShown {
                            factory.makeMessageDateView(for: message)
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

                if !messageViewModel.isRightAligned {
                    MessageSpacer(spacerWidth: spacerWidth)
                }
            }
        }
        .padding(
            .top,
            topReactionsShown && !messageViewModel.isPinned ? messageListConfig.messageDisplayOptions
                .reactionsTopPadding(message) : 0
        )
        .padding(.horizontal, messageListConfig.messagePaddings.horizontal)
        .padding(.bottom, showsAllInfo || messageViewModel.isPinned ? paddingValue : groupMessageInterItemSpacing)
        .padding(.top, isLast ? paddingValue : 0)
        .background(
            Group {
                if utils.messageListConfig.highlightMessageWhenJumping,
                   let highlightedMessageId = highlightedMessageId,
                   highlightedMessageId == message.messageId {
                    Color(colors.messageCellHighlightBackground)
                } else if messageViewModel.isPinned {
                    Color(colors.pinnedBackground)
                }
            }
        )
        .padding(.bottom, messageViewModel.isPinned ? paddingValue / 2 : 0)
        .transition(
            message.isSentByCurrentUser ?
                messageListConfig.messageDisplayOptions.currentUserMessageTransition :
                messageListConfig.messageDisplayOptions.otherUserMessageTransition
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("MessageContainerView")
        // This is needed for the LinkDetectionTextView to work properly.
        // TODO: This should be refactored on v5 so the TextView does not depend directly on the view model.
        .environment(\.messageViewModel, messageViewModel)
        .onChange(of: message, perform: { message in messageViewModel.message = message })
        .onChange(of: channel) { channel in messageViewModel.channel = channel }
    }

    private var maximumHorizontalSwipeDisplacement: CGFloat {
        replyThreshold + 30
    }

    private var contentWidth: CGFloat {
        let padding: CGFloat = messageListConfig.messagePaddings.horizontal
        let minimumWidth: CGFloat = 240
        let available = max(minimumWidth, (width ?? 0) - spacerWidth) - 2 * padding
        let avatarSize: CGFloat = CGSize.messageAvatarSize.width + padding
        let totalWidth = messageViewModel.isRightAligned ? available : available - avatarSize
        return totalWidth
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
            self.offsetX = value
        }
    }

    func handleGestureForMessage(
        showsMessageActions: Bool,
        showsBottomContainer: Bool = true
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
                    showsMessageActions: showsMessageActions,
                    showsBottomContainer: showsBottomContainer
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

public struct MessageDisplayInfo {
    public let message: ChatMessage
    public let frame: CGRect
    public let contentWidth: CGFloat
    public let isFirst: Bool
    public var showsMessageActions: Bool = true
    public var showsBottomContainer: Bool = true
    public var keyboardWasShown: Bool = false

    public init(
        message: ChatMessage,
        frame: CGRect,
        contentWidth: CGFloat,
        isFirst: Bool,
        showsMessageActions: Bool = true,
        showsBottomContainer: Bool = true,
        keyboardWasShown: Bool = false
    ) {
        self.message = message
        self.frame = frame
        self.contentWidth = contentWidth
        self.isFirst = isFirst
        self.showsMessageActions = showsMessageActions
        self.keyboardWasShown = keyboardWasShown
        self.showsBottomContainer = showsBottomContainer
    }
}
