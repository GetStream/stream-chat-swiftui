//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// A view that renders a single message item in the message list, including
/// the avatar, bubble, reactions, thread replies, delivery status, and gesture handling.
public struct MessageItemView<Factory: ViewFactory>: View {
    @StateObject var messageViewModel: MessageViewModel
    @Environment(\.highlightedMessageId) var highlightedMessageId

    @Injected(\.chatClient) private var chatClient
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images
    @Injected(\.utils) private var utils
    @Injected(\.tokens) private var tokens

    let factory: Factory
    let channel: ChatChannel
    let message: ChatMessage
    let width: CGFloat?
    let showsAllInfo: Bool
    let shownAsPreview: Bool
    let isInThread: Bool
    let isLast: Bool
    @Binding var scrolledId: String?
    @Binding var quotedMessage: ChatMessage?
    let onLongPress: (MessageDisplayInfo) -> Void

    @State private var frame: CGRect = .zero
    @State private var computeFrame = false

    /// Creates a new message item view.
    /// - Parameters:
    ///   - factory: The view factory used to create subviews.
    ///   - channel: The channel the message belongs to.
    ///   - message: The message to display.
    ///   - width: The available width for laying out the message content.
    ///   - showsAllInfo: Whether to show the full message info (avatar, timestamp, delivery status).
    ///   - shownAsPreview: Whether the message is rendered as a preview (e.g. on the reactions overlay).
    ///   - isInThread: Whether the message is displayed inside a thread.
    ///   - isLast: Whether this is the last (topmost) message in the list.
    ///   - scrolledId: Binding to the currently scrolled-to message ID.
    ///   - quotedMessage: Binding to the message being quoted via swipe-to-reply.
    ///   - onLongPress: Called when the user long-presses or double-taps the message bubble.
    ///   - viewModel: An optional pre-existing view model; one is created automatically when `nil`.
    public init(
        factory: Factory,
        channel: ChatChannel,
        message: ChatMessage,
        width: CGFloat? = nil,
        showsAllInfo: Bool,
        shownAsPreview: Bool = false,
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
        self.shownAsPreview = shownAsPreview
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
                messageView
                    .background(
                        GeometryReader { proxy in
                            Rectangle().fill(Color.clear)
                                .onChange(of: computeFrame, perform: { _ in
                                    frame = proxy.frame(in: .global)
                                })
                        }
                    )
                    .onTapGesture(count: 2) {
                        if messageViewModel.isDoubleTapOverlayEnabled {
                            handleGestureForMessage(showsMessageActions: true)
                        }
                    }
                    .onLongPressGesture(perform: {
                        handleGestureForMessage(showsMessageActions: true)
                    })
                    .modifier(SwipeToReplyModifier(
                        message: message,
                        channel: channel,
                        isSwipeToQuoteReplyPossible: !shownAsPreview && messageViewModel.isSwipeToQuoteReplyPossible,
                        quotedMessage: $quotedMessage
                    ))
            }
        }
        .background(
            Group {
                if messageViewModel.isHighlighted(messageId: highlightedMessageId) {
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
        .accessibilityIdentifier("MessageItemView")
        // TODO: Refactor so LinkDetectionTextView does not depend directly on the view model through @Environment.
        .environment(\.messageViewModel, messageViewModel)
        .onChange(of: message) { message in messageViewModel.message = message }
        .onChange(of: channel) { channel in messageViewModel.channel = channel }
    }

    // MARK: - Message Content

    private var messageView: some View {
        HStack(alignment: .bottom, spacing: tokens.spacingXs) {
            if !messageViewModel.isRightAligned
                && utils.messageListConfig.messageDisplayOptions.showAvatars(for: channel, incoming: true) {
                avatarView
            }

            VStack(
                alignment: messageViewModel.isRightAligned ? .trailing : .leading,
                spacing: tokens.spacingXxs
            ) {
                if messageViewModel.isPinned {
                    MessagePinDetailsView(
                        message: message,
                        reactionsShown: topReactionsShown
                    )
                }

                messageBubbleContent
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier("MessageView")

                if !isInThread {
                    threadRepliesView
                }

                if bottomReactionsShown {
                    factory.makeBottomReactionsView(
                        options: ReactionsBottomViewOptions(
                            message: message,
                            showsAllInfo: showsAllInfo,
                            onTap: {
                                handleGestureForMessage(showsMessageActions: false)
                            },
                            onLongPress: {
                                handleGestureForMessage(showsMessageActions: false)
                            }
                        )
                    )
                }

                if messageViewModel.translatedText != nil {
                    factory.makeMessageTranslationFooterView(
                        options: MessageTranslationFooterViewOptions(
                            messageViewModel: messageViewModel,
                            usesInvertedStyle: shownAsPreview
                        )
                    )
                }

                if showsAllInfo && !message.isDeleted {
                    deliveryStatusView
                }
            }

            if messageViewModel.isRightAligned
                && utils.messageListConfig.messageDisplayOptions.showAvatars(for: channel, incoming: false) {
                avatarView
            }
        }
        .frame(maxWidth: .infinity, alignment: messageViewModel.isRightAligned ? .trailing : .leading)
        .padding(
            .top,
            topReactionsShown && !messageViewModel.isPinned ? messageListConfig.messageDisplayOptions
                .reactionsTopPadding(message) : 0
        )
        .padding(.horizontal, messageListConfig.messagePaddings.horizontal)
        .padding(.bottom, showsAllInfo || messageViewModel.isPinned ? paddingValue : groupMessageInterItemSpacing)
        .padding(.top, isLast ? paddingValue : 0)
    }

    // MARK: - Sub-views

    @ViewBuilder
    private var messageBubbleContent: some View {
        Group {
            if messageViewModel.usesScrollView {
                ScrollView {
                    MessageView(
                        factory: factory,
                        message: message,
                        contentWidth: contentWidth,
                        isFirst: showsAllInfo,
                        scrolledId: $scrolledId
                    )
                }
            } else {
                MessageView(
                    factory: factory,
                    message: message,
                    contentWidth: contentWidth,
                    isFirst: showsAllInfo,
                    scrolledId: $scrolledId
                )
            }
        }
        .overlay(
            topReactionsShown ?
                factory.makeMessageReactionView(
                    options: MessageReactionViewOptions(
                        message: message,
                        onTapGesture: {
                            handleGestureForMessage(showsMessageActions: false)
                        },
                        onLongPressGesture: {
                            handleGestureForMessage(showsMessageActions: false)
                        }
                    )
                )
                : nil,
            alignment: messageViewModel.isRightAligned ? .trailing : .leading
        )
        .overlay(
            messageViewModel.failureIndicatorShown ? SendFailureIndicator() : nil
        )
        .frame(maxWidth: contentWidth, alignment: messageViewModel.isRightAligned ? .trailing : .leading)
    }

    @ViewBuilder
    private var avatarView: some View {
        factory.makeUserAvatarView(
            options: UserAvatarViewOptions(
                user: message.author,
                size: AvatarSize.medium,
                showsIndicator: false
            )
        )
        .opacity(isLast || showsAllInfo ? 1 : 0)
    }

    @ViewBuilder
    private var threadRepliesView: some View {
        if message.replyCount > 0 {
            factory.makeMessageRepliesView(
                options: MessageRepliesViewOptions(
                    channel: channel,
                    message: message,
                    replyCount: message.replyCount,
                    usesInvertedStyle: shownAsPreview
                )
            )
            .accessibilityElement(children: .contain)
            .accessibility(identifier: "MessageRepliesView")
        } else if message.showReplyInChannel, let parentId = message.parentMessageId {
            Group {
                if let controller = utils.channelControllerFactory.currentChannelController,
                   let parentMessage = controller.dataStore.message(id: parentId) {
                    factory.makeMessageRepliesShownInChannelView(
                        options: MessageRepliesShownInChannelViewOptions(
                            channel: channel,
                            message: message,
                            parentMessage: parentMessage,
                            replyCount: parentMessage.replyCount,
                            usesInvertedStyle: shownAsPreview
                        )
                    )
                    .accessibilityElement(children: .contain)
                    .accessibility(identifier: "MessageRepliesView")
                } else {
                    LazyMessageRepliesView(
                        factory: factory,
                        channel: channel,
                        message: message,
                        parentMessageController: chatClient.messageController(
                            cid: channel.cid,
                            messageId: parentId
                        ),
                        usesInvertedStyle: shownAsPreview
                    )
                    .accessibilityElement(children: .contain)
                    .accessibility(identifier: "MessageRepliesView")
                }
            }
        }
    }

    @ViewBuilder
    private var deliveryStatusView: some View {
        if message.isSentByCurrentUser && channel.config.readEventsEnabled {
            HStack(spacing: tokens.spacingXxs) {
                factory.makeMessageReadIndicatorView(
                    options: MessageReadIndicatorViewOptions(
                        channel: channel,
                        message: message,
                        usesInvertedStyle: shownAsPreview
                    )
                )

                if messageViewModel.messageDateShown {
                    factory.makeMessageDateView(
                        options: MessageDateViewOptions(message: message, usesInvertedStyle: shownAsPreview)
                    )
                }
            }
            .padding(.bottom, tokens.spacingXxs)
        } else if messageViewModel.authorAndDateShown {
            factory.makeMessageAuthorAndDateView(
                options: MessageAuthorAndDateViewOptions(message: message, usesInvertedStyle: shownAsPreview)
            )
            .padding(.bottom, tokens.spacingXxs)
        } else if messageViewModel.messageDateShown {
            factory.makeMessageDateView(
                options: MessageDateViewOptions(message: message, usesInvertedStyle: shownAsPreview)
            )
            .padding(.bottom, tokens.spacingXxs)
        }
    }

    // MARK: - Computed Properties

    private var contentWidth: CGFloat {
        let minimumWidth: CGFloat = 240
        let padding = messageListConfig.messagePaddings.horizontal
        let avatarWithSpacing = AvatarSize.medium + tokens.spacingXs
        let available = (width ?? 0) - spacerWidth - padding - avatarWithSpacing
        return max(minimumWidth, available)
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

    private var paddingValue: CGFloat {
        messageListConfig.messagePaddings.singleBottom
    }

    private var groupMessageInterItemSpacing: CGFloat {
        messageListConfig.messagePaddings.groupBottom
    }

    private var messageListConfig: MessageListConfig {
        utils.messageListConfig
    }

    // MARK: - Gesture Handling

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

// MARK: - Swipe to Reply

private struct SwipeToReplyModifier: ViewModifier {
    let message: ChatMessage
    let channel: ChatChannel
    let isSwipeToQuoteReplyPossible: Bool
    @Binding var quotedMessage: ChatMessage?

    @Injected(\.images) private var images
    @Injected(\.utils) private var utils

    @State private var offsetX: CGFloat = 0
    @GestureState private var offset: CGSize = .zero

    private let replyThreshold: CGFloat = 60

    func body(content: Content) -> some View {
        content
            .offset(x: min(offsetX, maximumHorizontalSwipeDisplacement))
            .simultaneousGesture(
                DragGesture(
                    minimumDistance: minimumSwipeDistance,
                    coordinateSpace: .local
                )
                .updating($offset) { (value, gestureState, _) in
                    guard isSwipeToQuoteReplyPossible else {
                        return
                    }
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

    private var maximumHorizontalSwipeDisplacement: CGFloat {
        replyThreshold + 30
    }

    private var minimumSwipeDistance: CGFloat {
        utils.messageListConfig.messageDisplayOptions.minimumSwipeGestureDistance
    }

    private func dragChanged(to value: CGFloat) {
        let horizontalTranslation = value

        if horizontalTranslation < 0 {
            return
        }

        if horizontalTranslation >= minimumSwipeDistance {
            offsetX = horizontalTranslation
        } else {
            offsetX = 0
        }

        if offsetX > replyThreshold && quotedMessage != message {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            withAnimation {
                quotedMessage = message
            }
        }
    }

    private func setOffsetX(value: CGFloat) {
        withAnimation(.interpolatingSpring(stiffness: 170, damping: 20)) {
            offsetX = value
        }
    }
}

// MARK: - Environment

private struct HighlightedMessageIdKey: EnvironmentKey {
    static let defaultValue: String? = nil
}

extension EnvironmentValues {
    var highlightedMessageId: String? {
        get { self[HighlightedMessageIdKey.self] }
        set { self[HighlightedMessageIdKey.self] = newValue }
    }
}

// MARK: - Supporting Types

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
