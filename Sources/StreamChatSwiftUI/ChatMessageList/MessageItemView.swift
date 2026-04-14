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

    @Injected(\.colors) private var colors
    @Injected(\.utils) private var utils
    @Injected(\.tokens) private var tokens

    let factory: Factory
    let channel: ChatChannel
    let message: ChatMessage
    let width: CGFloat?
    let fixedContentWidth: CGFloat?
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
        fixedContentWidth: CGFloat? = nil,
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
        self.fixedContentWidth = fixedContentWidth
        self.showsAllInfo = showsAllInfo
        self.shownAsPreview = shownAsPreview
        self.isInThread = isInThread
        self.isLast = isLast
        self.onLongPress = onLongPress
        _messageViewModel = .init(
            wrappedValue: viewModel ?? MessageViewModel(
                message: message,
                channel: channel,
                isInThread: isInThread
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
                MessageContainerView(
                    messageViewModel: messageViewModel,
                    factory: factory,
                    channel: channel,
                    message: message,
                    contentWidth: contentWidth,
                    showsAllInfo: showsAllInfo,
                    shownAsPreview: shownAsPreview,
                    isLast: isLast,
                    scrolledId: $scrolledId,
                    onGesture: { handleGestureForMessage(showsMessageActions: $0) }
                )
                .background(
                    GeometryReader { proxy in
                        Rectangle().fill(Color.clear)
                            .onChange(of: computeFrame, perform: { _ in
                                frame = proxy.frame(in: .global)
                            })
                    }
                )
                .contentShape(Rectangle())
                .allowsHitTesting(!shownAsPreview || (messageViewModel.usesScrollView))
                .onTapGesture(count: 2) {
                    if messageViewModel.isDoubleTapOverlayEnabled {
                        handleGestureForMessage(showsMessageActions: true)
                    }
                }
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.3)
                        .onEnded { _ in
                            handleGestureForMessage(showsMessageActions: true)
                        }
                )
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
                    Color(colors.backgroundCoreHighlight)
                } else if messageViewModel.isPinned && !shownAsPreview {
                    Color(colors.backgroundCoreHighlight)
                }
            }
        )
        .padding(.bottom, messageViewModel.isPinned && !shownAsPreview ? tokens.spacingXs : 0)
        .transition(
            message.isSentByCurrentUser ?
                messageListConfig.messageDisplayOptions.currentUserMessageTransition :
                messageListConfig.messageDisplayOptions.otherUserMessageTransition
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("MessageItemView")
        .onChange(of: message) { message in messageViewModel.message = message }
        .onChange(of: channel) { channel in messageViewModel.channel = channel }
    }

    // MARK: - Computed Properties

    private var contentWidth: CGFloat {
        if let fixedContentWidth {
            return fixedContentWidth
        }
        let minimumWidth: CGFloat = 240
        var padding = messageListConfig.messagePaddings.horizontal
        if utils.messageListConfig.messageDisplayOptions.showAvatars(for: channel, incoming: !messageViewModel.isRightAligned) {
            padding += AvatarSize.medium + tokens.spacingXs
        }
        let available = (width ?? 0) - spacerWidth - padding
        return max(minimumWidth, available)
    }

    private var spacerWidth: CGFloat {
        messageListConfig.messageDisplayOptions.spacerWidth(width ?? 0)
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

/// Areas that should not trigger swipe-to-reply (e.g. waveform sliders).
struct SwipeToReplyExcludedFrameKey: PreferenceKey {
    nonisolated static let defaultValue: [CGRect] = []
    static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
        value.append(contentsOf: nextValue())
    }
}

struct SwipeToReplyModifier: ViewModifier {
    let message: ChatMessage
    let channel: ChatChannel
    let isSwipeToQuoteReplyPossible: Bool
    @Binding var quotedMessage: ChatMessage?

    @Environment(\.layoutDirection) private var layoutDirection

    @Injected(\.images) private var images
    @Injected(\.utils) private var utils
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens

    @State private var offsetX: CGFloat
    @State private var swipeExcludedFrames: [CGRect] = []
    @GestureState private var offset: CGSize = .zero

    private let replyThreshold: CGFloat = 60

    init(
        message: ChatMessage,
        channel: ChatChannel,
        isSwipeToQuoteReplyPossible: Bool,
        quotedMessage: Binding<ChatMessage?>,
        initialOffsetX: CGFloat = 0
    ) {
        self.message = message
        self.channel = channel
        self.isSwipeToQuoteReplyPossible = isSwipeToQuoteReplyPossible
        self._quotedMessage = quotedMessage
        self._offsetX = State(initialValue: initialOffsetX)
    }

    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

    private var isRTL: Bool {
        layoutDirection == .rightToLeft
    }

    func body(content: Content) -> some View {
        content
            .coordinateSpace(name: "swipeToReply")
            .offset(x: min(offsetX, maximumHorizontalSwipeDisplacement))
            .gesture(
                DragGesture(
                    minimumDistance: minimumSwipeDistance,
                    coordinateSpace: .named("swipeToReply")
                )
                .updating($offset) { (value, gestureState, _) in
                    guard isSwipeToQuoteReplyPossible else {
                        return
                    }

                    if swipeExcludedFrames.contains(where: { $0.contains(value.startLocation) }) {
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
            .onPreferenceChange(SwipeToReplyExcludedFrameKey.self) { frames in
                swipeExcludedFrames = frames
            }
            .overlay(
                offsetX > 20 ? HStack {
                    Image(systemName: "arrowshape.turn.up.left")
                        .foregroundColor(colors.buttonSecondaryTextOnAccent.toColor)
                        .padding(.all, tokens.spacingXs)
                        .background(colors.buttonSecondaryBackground.toColor)
                        .clipShape(Circle())
                        .offset(x: min(offsetX / 2, 50) + (message.isRightAligned ? 30 : 0))
                    Spacer()
                } : nil
            )
    }

    private var maximumHorizontalSwipeDisplacement: CGFloat {
        replyThreshold + 30
    }

    private var minimumSwipeDistance: CGFloat {
        utils.messageListConfig.messageDisplayOptions.minimumSwipeGestureDistance
    }

    private func dragChanged(to value: CGFloat) {
        let horizontalTranslation = isRTL ? -value : value

        if horizontalTranslation < 0 {
            return
        }

        if horizontalTranslation >= minimumSwipeDistance {
            offsetX = horizontalTranslation
        } else {
            offsetX = 0
        }

        if offsetX > replyThreshold && quotedMessage != message {
            feedbackGenerator.impactOccurred()
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
        TopRightView {
            Image(uiImage: images.messageListErrorIndicator)
                .customizable()
                .frame(width: 20, height: 20)
                .foregroundColor(Color(colors.badgeBackgroundError))
                .padding(2)
                .background(Color(colors.badgeBorder))
                .clipShape(Circle())
                .offset(x: 14, y: 6)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("SendFailureIndicator")
    }
}

// MARK: - Message Display Info

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
