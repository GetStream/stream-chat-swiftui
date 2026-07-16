//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI
#if !os(macOS)
import UIKit
#endif

public struct MessageListView<Factory: ViewFactory>: View, KeyboardReadable {
    @Injected(\.utils) private var utils
    @Injected(\.chatClient) private var chatClient
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens

    var factory: Factory
    var channel: ChatChannel
    var messages: [ChatMessage]
    var messagesGroupingInfo: [String: [String]]
    @Binding var scrolledId: String?
    @Binding var showScrollToLatestButton: Bool
    @Binding var quotedMessage: ChatMessage?
    @Binding var scrollPosition: String?
    @Binding var firstUnreadMessageId: MessageId?
    var loadingNextMessages: Bool
    var currentDateString: String?
    var listId: String
    var isMessageThread: Bool
    var shouldShowTypingIndicator: Bool
    var bottomInset: CGFloat

    var onMessageAppear: (Int, ScrollDirection) -> Void
    var onScrollToBottom: @MainActor () -> Void
    var onLongPress: (MessageDisplayInfo) -> Void
    var onJumpToMessage: ((String) -> Bool)?

    @State private var width: CGFloat?
    @State private var keyboardShown = false
    @State private var pendingKeyboardUpdate: Bool?
    @State private var scrollDirection = ScrollDirection.up
    @State private var unreadMessagesBannerShown = false
    @State private var unreadButtonDismissed = false
    /// Whether the top-align clamp currently treats content as fitting the list.
    /// Used to skip auto-`scrollTo` newest (never drives layout).
    /// Defaults to `true` so we do not race a jump before the clamp binds.
    @State private var isMessageListTopAligned = true
    /// One-way latch: once content has overflowed into regular scrolling,
    /// keep insert animations enabled. Driving `.transition` / `.transaction`
    /// from the live fits flag caused a freeze when it oscillated at the boundary.
    @State private var hasLeftTopAlignedRegime = false

    private var messageRenderingUtil = MessageRenderingUtil.shared
    private var skipRenderingMessageIds = [String]()

    private var dateFormatter: DateFormatter {
        utils.dateFormatter
    }

    private var messageListConfig: MessageListConfig {
        utils.messageListConfig
    }

    private var messageListDateUtils: MessageListDateUtils {
        utils.messageListDateUtils
    }

    private var lastInGroupHeaderSize: CGFloat {
        messageListConfig.messageDisplayOptions.lastInGroupHeaderSize
    }

    // The configured size is a fixed reservation used to lay out the divider
    // without measuring its real (lazily-rendered) content, but the divider's
    // footnote text grows with Dynamic Type. Scaling this metric against the
    // same `.footnote` text style keeps the reservation (and the divider's
    // `maxHeight`, which shares this value) in step with the text, instead of
    // the divider clipping and losing its surrounding spacing at larger sizes.
    // `max` only ever grows the configured value, never shrinks it.
    @ScaledMetric(relativeTo: .footnote) private var scaledMessagesSeparatorSize: CGFloat = 50

    private var newMessagesSeparatorSize: CGFloat {
        max(messageListConfig.messageDisplayOptions.newMessagesSeparatorSize, scaledMessagesSeparatorSize)
    }

    @ScaledMetric(relativeTo: .footnote) private var scaledDateLabelSize: CGFloat = 40

    private var dateLabelSize: CGFloat {
        max(messageListConfig.messageDisplayOptions.dateLabelSize, scaledDateLabelSize)
    }

    private let bottomAnchorId = "BottomID"
    private let topAnchorId = "TopID"
    private let scrollAreaId = "scrollArea"

    public init(
        factory: Factory,
        channel: ChatChannel,
        messages: [ChatMessage],
        messagesGroupingInfo: [String: [String]],
        scrolledId: Binding<String?>,
        showScrollToLatestButton: Binding<Bool>,
        quotedMessage: Binding<ChatMessage?>,
        currentDateString: String? = nil,
        listId: String,
        isMessageThread: Bool = false,
        shouldShowTypingIndicator: Bool = false,
        bottomInset: CGFloat = 0,
        scrollPosition: Binding<String?> = .constant(nil),
        loadingNextMessages: Bool = false,
        firstUnreadMessageId: Binding<MessageId?> = .constant(nil),
        onMessageAppear: @escaping @MainActor (Int, ScrollDirection) -> Void,
        onScrollToBottom: @escaping @MainActor () -> Void,
        onLongPress: @escaping @MainActor (MessageDisplayInfo) -> Void,
        onJumpToMessage: ((String) -> Bool)? = nil
    ) {
        self.factory = factory
        self.channel = channel
        self.messages = messages
        self.messagesGroupingInfo = messagesGroupingInfo
        self.currentDateString = currentDateString
        self.listId = listId
        self.isMessageThread = isMessageThread
        self.onMessageAppear = onMessageAppear
        self.onScrollToBottom = onScrollToBottom
        self.onLongPress = onLongPress
        self.onJumpToMessage = onJumpToMessage
        self.shouldShowTypingIndicator = shouldShowTypingIndicator
        self.bottomInset = bottomInset
        self.loadingNextMessages = loadingNextMessages
        _scrolledId = scrolledId
        _showScrollToLatestButton = showScrollToLatestButton
        _quotedMessage = quotedMessage
        _scrollPosition = scrollPosition
        _firstUnreadMessageId = firstUnreadMessageId
        if !messageRenderingUtil.hasPreviousMessageSet
            || self.showScrollToLatestButton == false
            || self.scrolledId != nil
            || messages.first?.isSentByCurrentUser == true {
            messageRenderingUtil.update(previousTopMessage: messages.first)
        }
        skipRenderingMessageIds = messageRenderingUtil.messagesToSkipRendering(newMessages: messages)
        if !skipRenderingMessageIds.isEmpty {
            self.messages = messages.filter { !skipRenderingMessageIds.contains($0.id) }
        }
    }

    public init(
        factory: Factory = DefaultViewFactory.shared,
        channel: ChatChannel,
        viewModel: ChatChannelViewModel,
        onLongPress: @escaping @MainActor (MessageDisplayInfo) -> Void = { _ in }
    ) {
        self.init(
            factory: factory,
            channel: channel,
            messages: viewModel.messages,
            messagesGroupingInfo: viewModel.messagesGroupingInfo,
            scrolledId: Binding(
                get: { viewModel.scrolledId },
                set: { viewModel.scrolledId = $0 }
            ),
            showScrollToLatestButton: Binding(
                get: { viewModel.showScrollToLatestButton },
                set: { viewModel.showScrollToLatestButton = $0 }
            ),
            quotedMessage: Binding(
                get: { viewModel.quotedMessage },
                set: { viewModel.quotedMessage = $0 }
            ),
            currentDateString: viewModel.currentDateString,
            listId: viewModel.listId,
            isMessageThread: viewModel.isMessageThread,
            shouldShowTypingIndicator: viewModel.shouldShowInlineTypingIndicator,
            bottomInset: 0,
            scrollPosition: Binding(
                get: { viewModel.scrollPosition },
                set: { viewModel.scrollPosition = $0 }
            ),
            loadingNextMessages: viewModel.loadingNextMessages,
            firstUnreadMessageId: Binding(
                get: { viewModel.firstUnreadMessageId },
                set: { viewModel.firstUnreadMessageId = $0 }
            ),
            onMessageAppear: viewModel.handleMessageAppear(index:scrollDirection:),
            onScrollToBottom: viewModel.scrollToLastMessage,
            onLongPress: onLongPress,
            onJumpToMessage: viewModel.jumpToMessage(messageId:)
        )
    }

    public var body: some View {
        if messageListConfig.shouldMessagesStartAtTheTop {
            GeometryReader { proxy in
                messageListContent(containerHeight: proxy.size.height)
            }
        } else {
            messageListContent(containerHeight: nil)
        }
    }

    private func messageListContent(containerHeight: CGFloat?) -> some View {
        ZStack {
            ScrollViewReader { scrollView in
                ScrollView {
                    GeometryReader { proxy in
                        let frame = proxy.frame(in: .named(scrollAreaId))
                        let offset = frame.minY
                        let width = frame.width
                        Color.clear.preference(key: ScrollViewOffsetPreferenceKey.self, value: offset)
                        Color.clear.preference(key: WidthPreferenceKey.self, value: width)
                    }
                    // A GeometryReader has a 10-point ideal height inside a
                    // vertical ScrollView. Always zero it while the feature is
                    // on so it cannot create phantom top overflow. Do not gate
                    // this on a fits/overflow regime — that feedback freezes
                    // the app.
                    .frame(height: messageListConfig.shouldMessagesStartAtTheTop ? 0 : nil)

                    LazyVStack(spacing: 0) {
                        topAnchorView

                        if shouldShowTypingIndicator {
                            factory.makeInlineTypingIndicatorView(
                                options: TypingIndicatorViewOptions(
                                    channel: channel,
                                    currentUserId: chatClient.currentUserId
                                )
                            )
                            .flippedUpsideDown()
                        }

                        ForEach(messages, id: \.messageId) { message in
                            var index: Int? = messageListDateUtils.indexForMessageDate(message: message, in: messages)
                            let messageDate: Date? = messageListDateUtils.showMessageDate(for: index, in: messages)
                            let messageIsFirstUnread = firstUnreadMessageId?.contains(message.id) == true
                            let showUnreadSeparator = messageListConfig.showNewMessagesSeparator &&
                                messageIsFirstUnread &&
                                !isMessageThread
                            let showsLastInGroupInfo = showsLastInGroupInfo(for: message, channel: channel)
                            let showThreadRepliesSeparator = isThreadRepliesSeparatorShown(for: message)
                            factory.makeMessageItemView(
                                options: MessageItemViewOptions(
                                    channel: channel,
                                    message: message,
                                    width: width,
                                    showsAllInfo: showsAllData(for: message),
                                    isInThread: isMessageThread,
                                    scrolledId: $scrolledId,
                                    quotedMessage: $quotedMessage,
                                    onLongPress: handleLongPress(messageDisplayInfo:),
                                    isLast: !showsLastInGroupInfo && message == messages.last
                                )
                            )
                            .onAppear {
                                if index == nil {
                                    index = messageListDateUtils.index(for: message, in: messages)
                                }
                                if let index {
                                    onMessageAppear(index, scrollDirection)
                                }
                            }
                            .padding(.bottom, message == messages.first ? bottomInset : 0)
                            .padding(
                                .top,
                                topPadding(
                                    hasMessageDate: messageDate != nil,
                                    showsLastInGroupInfo: showsLastInGroupInfo,
                                    showUnreadSeparator: showUnreadSeparator,
                                    showThreadRepliesSeparator: showThreadRepliesSeparator
                                )
                            )
                            .overlay(
                                (messageDate != nil || showsLastInGroupInfo || showUnreadSeparator || showThreadRepliesSeparator) ?
                                    VStack(spacing: 0) {
                                        messageDate != nil ?
                                            factory.makeMessageListDateIndicator(options: MessageListDateIndicatorViewOptions(date: messageDate!))
                                            .frame(maxHeight: dateLabelSize)
                                            : nil

                                        showUnreadSeparator ?
                                            factory.makeNewMessagesDividerView(
                                                options: NewMessagesDividerViewOptions(
                                                    newMessagesStartId: $firstUnreadMessageId,
                                                    count: newMessagesCount(for: index, message: message)
                                                )
                                            )
                                            .onAppear {
                                                unreadMessagesBannerShown = true
                                            }
                                            .onDisappear {
                                                unreadMessagesBannerShown = false
                                            }
                                            : nil

                                        showThreadRepliesSeparator ?
                                            factory.makeThreadRepliesDividerView(
                                                options: ThreadRepliesDividerViewOptions(
                                                    replyCount: messages.last?.replyCount ?? (messages.count - 1)
                                                )
                                            )
                                            .frame(maxHeight: newMessagesSeparatorSize)
                                            : nil

                                        showsLastInGroupInfo ?
                                            factory.makeLastInGroupHeaderView(options: LastInGroupHeaderViewOptions(message: message))
                                            .frame(maxHeight: lastInGroupHeaderSize)
                                            : nil
                                    }
                                    : nil,
                                alignment: .top
                            )
                            .flippedUpsideDown()
                            .animation(nil, value: messageDate != nil)
                            // Identity only before the list has ever overflowed.
                            // After that, keep opacity — do not flip back when
                            // fits oscillates near the boundary (that froze the app).
                            .transition(
                                messageListConfig.shouldMessagesStartAtTheTop && !hasLeftTopAlignedRegime
                                    ? .identity
                                    : .opacity
                            )
                        }
                        .id(listId)

                        // Trailing spacer in the flipped stack becomes leading
                        // space under the navigation bar, keeping the time bubble
                        // from sitting flush against it.
                        if messageListConfig.shouldMessagesStartAtTheTop {
                            Color.clear
                                .frame(height: tokens.spacingSm)
                                .accessibilityHidden(true)
                        }
                    }
                    .modifier(TopAlignedFillModifier(minHeight: containerHeight))
                    .modifier(
                        TopAlignedScrollClampBridgeModifier(
                            enabled: messageListConfig.shouldMessagesStartAtTheTop,
                            contentFits: $isMessageListTopAligned
                        )
                    )
                    .onChange(of: isMessageListTopAligned) { fits in
                        // Latch only; never clear from fits bouncing true again.
                        if !fits {
                            hasLeftTopAlignedRegime = true
                        }
                    }
                    .onChange(of: listId) { _ in
                        hasLeftTopAlignedRegime = false
                    }
                    .delayedRendering()
                    .modifier(factory.styles.makeMessageListModifier(options: MessageListModifierOptions()))
                    .modifier(ScrollTargetLayoutModifier(enabled: loadingNextMessages))
                    .overlay(
                        VStack {
                            // Workaround to make scrolling to bottom more precise
                            bottomAnchorView

                            Spacer()
                        }
                    )
                }
                .modifier(ScrollPositionModifier(scrollPosition: loadingNextMessages ? $scrollPosition : .constant(nil)))
                .background(
                    factory.makeMessageListBackground(
                        options: MessageListBackgroundOptions(
                            isInThread: isMessageThread
                        )
                    )
                )
                .coordinateSpace(name: scrollAreaId)
                .onPreferenceChange(WidthPreferenceKey.self) { value in
                    if let value, value != width {
                        width = value
                    }
                }
                .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
                    DispatchQueue.main.async {
                        let offsetValue = value ?? 0
                        let diff = offsetValue - utils.messageCachingUtils.scrollOffset
                        if abs(diff) > 15 {
                            if diff > 0 {
                                if scrollDirection == .up {
                                    scrollDirection = .down
                                }
                            } else if diff < 0 && scrollDirection == .down {
                                scrollDirection = .up
                            }
                            utils.messageCachingUtils.scrollOffset = offsetValue
                        }
                        let scrollButtonShown = offsetValue < -20
                        if scrollButtonShown != showScrollToLatestButton {
                            if scrollButtonShown {
                                withAnimation(.easeOut(duration: 0.18)) {
                                    showScrollToLatestButton = true
                                }
                            } else {
                                withAnimation(.easeIn(duration: 0.12)) {
                                    showScrollToLatestButton = false
                                }
                            }
                        }
                        if messageListConfig.resignsFirstResponderOnScrollDown && keyboardShown && diff < -20 {
                            keyboardShown = false
                            resignFirstResponder()
                        }
                        if offsetValue > 5 {
                            onMessageAppear(0, .down)
                        }
                    }
                }
                .modifier(
                    TopAlignedScrollBounceModifier(
                        enabled: messageListConfig.shouldMessagesStartAtTheTop
                    )
                )
                .flippedUpsideDown()
                .frame(maxWidth: .infinity)
                .clipped()
                .onChange(of: scrolledId) { scrolledId in
                    if let scrolledId {
                        let shouldJump = onJumpToMessage?(scrolledId) ?? false
                        if !shouldJump {
                            return
                        }
                        // While top-aligned, the clamp already pins to the visual
                        // top. Auto-scrolling to newest (visual bottom) fights that
                        // pin and causes a visible jump on every insert/update.
                        let isNewestMessage = scrolledId == messages.first?.messageId
                            || scrolledId == messages.first?.id
                        if messageListConfig.shouldMessagesStartAtTheTop,
                           isMessageListTopAligned,
                           isNewestMessage {
                            return
                        }
                        if messageListConfig.shouldMessagesStartAtTheTop, isMessageListTopAligned {
                            var transaction = Transaction()
                            transaction.disablesAnimations = true
                            withTransaction(transaction) {
                                if isNewestMessage {
                                    scrollView.scrollTo(bottomAnchorId, anchor: .bottom)
                                } else {
                                    scrollView.scrollTo(scrolledId, anchor: messageListConfig.scrollingAnchor)
                                }
                            }
                            return
                        }
                        withAnimation {
                            if isNewestMessage {
                                scrollView.scrollTo(bottomAnchorId, anchor: .bottom)
                            } else {
                                scrollView.scrollTo(scrolledId, anchor: messageListConfig.scrollingAnchor)
                            }
                        }
                    }
                }
                .accessibilityIdentifier("MessageListScrollView")
                .transaction { transaction in
                    // Disable list animations only before the list has overflowed.
                    // The live fits flag must not drive this — oscillation at the
                    // boundary recreated the freeze loop.
                    if messageListConfig.shouldMessagesStartAtTheTop, !hasLeftTopAlignedRegime {
                        transaction.disablesAnimations = true
                        transaction.animation = nil
                    }
                }
            }

            if showScrollToLatestButton {
                factory.makeScrollToBottomButton(
                    options: ScrollToBottomButtonOptions(
                        unreadCount: channel.unreadCount.messages,
                        onScrollToBottom: onScrollToBottom
                    )
                )
                .transition(
                    .modifier(
                        active: ButtonOverlayTransitionModifier(opacity: 0, offset: 10),
                        identity: ButtonOverlayTransitionModifier(opacity: 1, offset: 0)
                    )
                )
                .offset(y: -bottomInset)
            }
        }
        .onReceive(keyboardDidChangePublisher) { visible in
            if currentDateString != nil {
                pendingKeyboardUpdate = visible
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    keyboardShown = visible
                }
            }
        }
        .onChange(of: currentDateString, perform: { dateString in
            if dateString == nil, let keyboardUpdate = pendingKeyboardUpdate {
                keyboardShown = keyboardUpdate
                pendingKeyboardUpdate = nil
            }
        })
        .modifier(
            factory.makeJumpToUnreadButtonOverlay(
                options: JumpToUnreadButtonOptions(
                    isShown: shouldShowJumpToUnreadButton,
                    channel: channel,
                    onJumpToMessage: {
                        _ = onJumpToMessage?(firstUnreadMessageId ?? .unknownMessageId)
                    },
                    onClose: {
                        withAnimation {
                            chatClient.channelController(for: channel.cid).markRead()
                            unreadButtonDismissed = true
                        }
                    }
                )
            )
        )
        .modifier(factory.styles.makeMessageListContainerModifier(options: MessageListContainerModifierOptions()))
        .onDisappear {
            messageRenderingUtil.update(previousTopMessage: nil)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("MessageListView")
    }

    private var shouldShowJumpToUnreadButton: Bool {
        channel.unreadCount.messages > 0
            && !unreadMessagesBannerShown
            && !isMessageThread
            && !unreadButtonDismissed
    }

    /// The top padding reserved for the date/separator overlay above a message row.
    private func topPadding(
        hasMessageDate: Bool,
        showsLastInGroupInfo: Bool,
        showUnreadSeparator: Bool,
        showThreadRepliesSeparator: Bool
    ) -> CGFloat {
        hasMessageDate
            ? offsetForDateIndicator(
                showsLastInGroupInfo: showsLastInGroupInfo,
                showUnreadSeparator: showUnreadSeparator,
                showThreadRepliesSeparator: showThreadRepliesSeparator
            )
            : additionalTopPadding(
                showsLastInGroupInfo: showsLastInGroupInfo,
                showUnreadSeparator: showUnreadSeparator,
                showThreadRepliesSeparator: showThreadRepliesSeparator
            )
    }

    private func additionalTopPadding(
        showsLastInGroupInfo: Bool,
        showUnreadSeparator: Bool,
        showThreadRepliesSeparator: Bool = false
    ) -> CGFloat {
        var padding = showsLastInGroupInfo ? lastInGroupHeaderSize : 0
        if showUnreadSeparator {
            padding += newMessagesSeparatorSize
        }
        if showThreadRepliesSeparator {
            padding += newMessagesSeparatorSize
        }
        return padding
    }

    private func offsetForDateIndicator(
        showsLastInGroupInfo: Bool,
        showUnreadSeparator: Bool,
        showThreadRepliesSeparator: Bool = false
    ) -> CGFloat {
        var offset = dateLabelSize
        offset += additionalTopPadding(
            showsLastInGroupInfo: showsLastInGroupInfo,
            showUnreadSeparator: showUnreadSeparator,
            showThreadRepliesSeparator: showThreadRepliesSeparator
        )
        return offset
    }

    private func isThreadRepliesSeparatorShown(for message: ChatMessage) -> Bool {
        guard isMessageThread, messages.count > 1 else { return false }
        let allRepliesLoaded = messages.count - 1 >= (messages.last?.replyCount ?? 0)
        guard allRepliesLoaded else { return false }
        return message.id == messages[messages.count - 2].id
    }

    private func newMessagesCount(for index: Int?, message: ChatMessage) -> Int {
        channel.unreadCount.messages
    }

    private func showsAllData(for message: ChatMessage) -> Bool {
        if !messageListConfig.groupMessages {
            return true
        }
        let groupInfo = messagesGroupingInfo[message.id] ?? []
        return groupInfo.contains(firstMessageKey) == true
    }

    private func showsLastInGroupInfo(
        for message: ChatMessage,
        channel: ChatChannel
    ) -> Bool {
        guard channel.memberCount > 2
            && !message.isSentByCurrentUser
            && (lastInGroupHeaderSize > 0) else {
            return false
        }
        let groupInfo = messagesGroupingInfo[message.id] ?? []
        return groupInfo.contains(lastMessageKey) == true
    }

    private func handleLongPress(messageDisplayInfo: MessageDisplayInfo) {
        if keyboardShown {
            resignFirstResponder()
            let updatedFrame = CGRect(
                x: messageDisplayInfo.frame.origin.x,
                y: messageDisplayInfo.frame.origin.y,
                width: messageDisplayInfo.frame.width,
                height: messageDisplayInfo.frame.height
            )

            let updatedDisplayInfo = MessageDisplayInfo(
                message: messageDisplayInfo.message,
                frame: updatedFrame,
                contentWidth: messageDisplayInfo.contentWidth,
                isFirst: messageDisplayInfo.isFirst,
                showsMessageActions: messageDisplayInfo.showsMessageActions,
                keyboardWasShown: true
            )

            onLongPress(updatedDisplayInfo)
        } else {
            onLongPress(messageDisplayInfo)
        }
    }

    private var topAnchorView: some View {
        Color.clear
            .frame(height: 0)
            .id(topAnchorId)
            .accessibilityHidden(true)
    }

    private var bottomAnchorView: some View {
        Color.clear
            .frame(height: 0)
            .id(bottomAnchorId)
    }
}

struct ScrollPositionModifier: ViewModifier {
    @Binding var scrollPosition: String?

    func body(content: Content) -> some View {
        #if swift(>=5.9)
        if #available(iOS 17, *) {
            content
                .scrollPosition(id: $scrollPosition, anchor: .top)
        } else {
            content
        }
        #else
        content
        #endif
    }
}

struct ScrollTargetLayoutModifier: ViewModifier {
    var enabled: Bool

    func body(content: Content) -> some View {
        if !enabled {
            return content
        }
        #if swift(>=5.9)
        if #available(iOS 17, *) {
            return content
                .scrollTargetLayout(isEnabled: enabled)
                .scrollTargetBehavior(.paging)
        } else {
            return content
        }
        #else
        return content
        #endif
    }
}

/// Disables rubber-banding while scroll content fits the viewport, so a
/// top-aligned (flipped) list cannot be pulled under the navigation bar.
struct TopAlignedScrollBounceModifier: ViewModifier {
    var enabled: Bool

    func body(content: Content) -> some View {
        if enabled {
            if #available(iOS 16.4, *) {
                content.scrollBounceBehavior(.basedOnSize)
            } else {
                content
            }
        } else {
            content
        }
    }
}

/// UIKit clamp: while content fits, disables scrolling/bouncing/indicators and
/// pins offset to the visual top. Reports `contentFits` for scroll-gating only
/// (skip auto-`scrollTo` newest) — never for frames or scroll indicators in SwiftUI.
struct TopAlignedScrollClampBridgeModifier: ViewModifier {
    var enabled: Bool
    @Binding var contentFits: Bool

    func body(content: Content) -> some View {
        #if !os(macOS)
        if enabled {
            content.background(
                TopAlignedScrollClampBridge(contentFits: $contentFits)
                    .frame(width: 0, height: 0)
                    .accessibilityHidden(true)
            )
        } else {
            content
                .onAppear {
                    if contentFits {
                        contentFits = false
                    }
                }
        }
        #else
        content
        #endif
    }
}

#if !os(macOS)
private struct TopAlignedScrollClampBridge: UIViewRepresentable {
    @Binding var contentFits: Bool

    func makeUIView(context: Context) -> TopAlignedScrollClampView {
        let view = TopAlignedScrollClampView()
        view.onContentFitsChange = { [contentFits = $contentFits] fits in
            DispatchQueue.main.async {
                if contentFits.wrappedValue != fits {
                    contentFits.wrappedValue = fits
                }
            }
        }
        return view
    }

    func updateUIView(_ uiView: TopAlignedScrollClampView, context: Context) {
        uiView.onContentFitsChange = { [contentFits = $contentFits] fits in
            DispatchQueue.main.async {
                if contentFits.wrappedValue != fits {
                    contentFits.wrappedValue = fits
                }
            }
        }
        // Apply scroll flags only — never settle here. SwiftUI calls updateUIView
        // on every body refresh (including mid-scroll preference updates), and
        // settling from that fights the gesture and looks like a jump.
        uiView.applyScrollFlagsIfNeeded()
    }
}

private final class TopAlignedScrollClampView: UIView {
    /// Hysteresis so we do not flip scroll-enabled at the exact boundary.
    private static let fitSlop: CGFloat = 1
    private static let overflowSlop: CGFloat = 24
    private static let settleDuration: TimeInterval = 0.25

    var onContentFitsChange: ((Bool) -> Void)?

    private var contentFits = true
    private var contentSizeObservation: NSKeyValueObservation?
    private var boundsObservation: NSKeyValueObservation?
    private weak var observedScrollView: UIScrollView?
    private var isUpdating = false
    private var isSettling = false
    private var isUserPanning = false
    private var panTargetInstalled = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        backgroundColor = .clear
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        applyScrollFlagsIfNeeded()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyScrollFlagsIfNeeded()
    }

    /// Updates fits state + scroll enabled/bounce/indicator. Does not move offset.
    func applyScrollFlagsIfNeeded() {
        guard !isUpdating else { return }
        isUpdating = true
        defer { isUpdating = false }

        bindScrollViewIfNeeded()
        guard let scrollView = observedScrollView ?? findScrollView() else { return }
        guard scrollView.bounds.height > 0 else { return }

        let overflow = scrollView.contentSize.height - scrollView.bounds.height
        let previousFits = contentFits
        if contentFits {
            if overflow > Self.overflowSlop {
                contentFits = false
            }
        } else if overflow <= Self.fitSlop {
            contentFits = true
        }
        if previousFits != contentFits {
            onContentFitsChange?(contentFits)
        }

        let shouldScroll = !contentFits
        // Re-apply every pass — SwiftUI may reset these on its own updates.
        if scrollView.isScrollEnabled != shouldScroll {
            scrollView.isScrollEnabled = shouldScroll
        }
        if scrollView.bounces != shouldScroll {
            scrollView.bounces = shouldScroll
        }
        if scrollView.alwaysBounceVertical != shouldScroll {
            scrollView.alwaysBounceVertical = shouldScroll
        }
        if scrollView.showsVerticalScrollIndicator != shouldScroll {
            scrollView.showsVerticalScrollIndicator = shouldScroll
        }
    }

    /// Animates back to the visual-top pin after the user finishes a gesture,
    /// or when layout changes while content fits.
    func settleIfNeeded() {
        applyScrollFlagsIfNeeded()
        guard contentFits else {
            isSettling = false
            return
        }
        guard !isUserPanning, !isSettling else { return }
        guard let scrollView = observedScrollView else { return }

        // The stack is bottom-aligned inside the minHeight fill. After the
        // upside-down flip, that end is the visual top. Pin to the max offset
        // (not 0) — offset 0 shows the empty fill and reads as the visual bottom.
        let maxOffsetY = max(0, scrollView.contentSize.height - scrollView.bounds.height)
        if abs(scrollView.contentOffset.y - maxOffsetY) <= 0.5 {
            isSettling = false
            return
        }

        isSettling = true
        let target = CGPoint(x: scrollView.contentOffset.x, y: maxOffsetY)
        UIView.animate(
            withDuration: Self.settleDuration,
            delay: 0,
            options: [.curveEaseOut, .beginFromCurrentState, .allowUserInteraction]
        ) {
            scrollView.contentOffset = target
        } completion: { [weak self] _ in
            self?.isSettling = false
        }
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began, .changed:
            isUserPanning = true
        case .ended, .cancelled, .failed:
            isUserPanning = false
            // Settle only after the gesture ends — never while the finger moves.
            // SwiftUI's UIScrollView often does not report isDragging reliably,
            // so contentOffset KVO + isDragging checks used to fight the scroll.
            settleIfNeeded()
        default:
            break
        }
    }

    private func bindScrollViewIfNeeded() {
        guard let scrollView = findScrollView() else { return }
        guard observedScrollView !== scrollView else { return }
        observedScrollView = scrollView

        contentSizeObservation = scrollView.observe(\.contentSize, options: [.new]) { [weak self] _, _ in
            // Layout change while fitting: re-pin after content size settles.
            self?.settleIfNeeded()
        }
        boundsObservation = scrollView.observe(\.bounds, options: [.old, .new]) { [weak self] _, change in
            // `bounds.origin` tracks contentOffset during scroll — ignore it.
            // Only re-pin when the scroll view's size actually changes.
            guard let old = change.oldValue, let new = change.newValue,
                  old.size != new.size else { return }
            self?.settleIfNeeded()
        }

        // Prefer the pan gesture over contentOffset / isDragging KVO. Offset KVO
        // fires continuously during a drag and (with unreliable isDragging on
        // SwiftUI scroll views) was re-settling mid-scroll — the jump when
        // dragging toward the visual top on the inverted list.
        if !panTargetInstalled {
            scrollView.panGestureRecognizer.addTarget(self, action: #selector(handlePan(_:)))
            panTargetInstalled = true
        }

        onContentFitsChange?(contentFits)
        // Initial pin once bound.
        DispatchQueue.main.async { [weak self] in
            self?.settleIfNeeded()
        }
    }

    private func findScrollView() -> UIScrollView? {
        var ancestor = superview
        while let current = ancestor {
            if let scrollView = current as? UIScrollView {
                return scrollView
            }
            ancestor = current.superview
        }
        return nil
    }
}
#endif

/// Gives the message stack a minimum height (the visible list height) and bottom
/// aligns it, so that with `shouldMessagesStartAtTheTop` the messages fill from the
/// top and the remaining space becomes an implicit bottom spacer. A `nil`
/// `minHeight` leaves the layout untouched, so other consumers pay no extra cost.
///
/// Deliberately avoids branching (`if let minHeight { ... } else { ... }`):
/// `minHeight` can change while an animation is in flight (e.g. while the
/// keyboard is showing/hiding), and branching would change this view's
/// underlying identity at that point, causing SwiftUI to cross-fade between the
/// two branches instead of just smoothly animating the frame's size. `.frame`
/// already treats a `nil` `minHeight` as a no-op, so passing it straight through
/// keeps the view's identity (and the animation) stable.
struct TopAlignedFillModifier: ViewModifier {
    var minHeight: CGFloat?

    func body(content: Content) -> some View {
        content.frame(minHeight: minHeight, alignment: .bottom)
    }
}

public enum ScrollDirection {
    case up
    case down
}

/// A full-width divider with centered text, a subtle background, and
/// hairline top/bottom borders. Used by ``NewMessagesDivider`` and
/// ``ThreadRepliesDivider``.
public struct MessageListDivider: View {
    @Injected(\.colors) var colors
    @Injected(\.tokens) var tokens
    @Injected(\.fonts) var fonts

    var title: String

    public init(title: String) {
        self.title = title
    }

    public var body: some View {
        Text(title)
            .font(fonts.footnote.weight(.semibold))
            .foregroundColor(Color(colors.chatTextSystem))
            .frame(maxWidth: .infinity)
            .padding(.horizontal, tokens.spacingMd)
            .padding(.vertical, tokens.spacingXs)
            .background(Color(colors.backgroundCoreSurfaceSubtle))
            .overlay(
                VStack(spacing: 0) {
                    Color(colors.borderCoreSubtle).frame(height: 1)
                    Spacer()
                    Color(colors.borderCoreSubtle).frame(height: 1)
                }
            )
            .accessibilityAddTraits(.isHeader)
    }
}

/// Divider shown between read and unread messages in the message list.
public struct NewMessagesDivider: View {
    @Injected(\.tokens) var tokens

    @Binding var newMessagesStartId: String?
    var count: Int

    public init(newMessagesStartId: Binding<String?>, count: Int) {
        _newMessagesStartId = newMessagesStartId
        self.count = count
    }

    public var body: some View {
        MessageListDivider(title: L10n.MessageList.newMessages(count))
            .padding(.vertical, tokens.spacingXs)
    }
}

/// Divider shown between the parent message and replies in a thread.
public struct ThreadRepliesDivider: View {
    var replyCount: Int

    public init(replyCount: Int) {
        self.replyCount = replyCount
    }

    public var body: some View {
        MessageListDivider(title: L10n.Message.Threads.count(replyCount))
    }
}

public struct ScrollToBottomButton<Factory: ViewFactory>: View {
    @Injected(\.images) private var images
    @Injected(\.tokens) private var tokens

    var factory: Factory
    var unreadCount: Int
    var onScrollToBottom: () -> Void

    public var body: some View {
        BottomRightView {
            StreamIconButton(
                role: .secondary,
                style: .outline,
                size: .medium,
                action: onScrollToBottom
            ) {
                Image(uiImage: images.scrollDownArrow)
                    .renderingMode(.template)
                    .frame(width: tokens.iconSizeMd, height: tokens.iconSizeMd)
            }
            .modifier(factory.styles.makeScrollToBottomButtonModifier(options: .init()))
            .accessibilityLabel(Text(L10n.Channel.List.ScrollToBottom.title))
            .accessibilityIdentifier("ScrollToBottomButton")
            // Floats over the message list, so raise the sort priority to make it
            // reachable from VoiceOver without swiping through every message in between.
            .accessibilitySortPriority(1)
            .badgeNotification(count: unreadCount)
            .padding(tokens.spacingMd)
        }
    }
}

struct ButtonOverlayTransitionModifier: ViewModifier {
    let opacity: Double
    let offset: CGFloat

    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .offset(y: offset)
    }
}

public struct DateIndicatorView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens

    var dateString: String

    public init(date: Date) {
        dateString = InjectedValues[\.utils].messageDateSeparatorFormatter.format(date)
    }

    public init(dateString: String) {
        self.dateString = dateString
    }

    public var body: some View {
        Text(dateString)
            .font(fonts.footnote.weight(.semibold))
            .padding(.vertical, tokens.spacingXxs)
            .padding(.horizontal, tokens.spacingXs)
            .foregroundColor(colors.chatTextSystem.toColor)
            .background(Color(colors.backgroundCoreSurfaceSubtle))
            .cornerRadius(tokens.radiusMax)
            .padding(.vertical, tokens.spacingXs)
            .accessibilityAddTraits(.isHeader)
    }
}

private class MessageRenderingUtil {
    private var previousTopMessage: ChatMessage?

    @MainActor static let shared = MessageRenderingUtil()

    var hasPreviousMessageSet: Bool {
        previousTopMessage != nil
    }

    func update(previousTopMessage: ChatMessage?) {
        self.previousTopMessage = previousTopMessage
    }

    func messagesToSkipRendering(newMessages: [ChatMessage]) -> [String] {
        let newTopMessage = newMessages.first
        if newTopMessage?.id == previousTopMessage?.id {
            return []
        }

        if newTopMessage?.cid != previousTopMessage?.cid {
            previousTopMessage = newTopMessage
            return []
        }

        var skipRendering = [String]()
        for message in newMessages {
            if previousTopMessage?.id == message.id {
                break
            } else {
                skipRendering.append(message.id)
            }
        }

        return skipRendering
    }
}
