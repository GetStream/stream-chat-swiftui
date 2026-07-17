//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Non-inverted message list for the "messages start at the top" mode.
///
/// Messages are laid out oldest → newest in a plain (non-flipped) `LazyVStack`,
/// so a short conversation naturally sits at the top. On load it scrolls to the
/// newest message, which is a no-op when everything already fits and scrolls to
/// the bottom when it doesn't — so a long conversation opens like a regular chat.
public struct TopAlignedMessageListView<Factory: ViewFactory>: View {
    @Injected(\.utils) private var utils

    private var factory: Factory
    private var channel: ChatChannel
    private var messages: [ChatMessage]
    private var messagesGroupingInfo: [String: [String]]
    @Binding private var scrolledId: String?
    @Binding private var quotedMessage: ChatMessage?
    private var scrollToNewestToken: Int
    private var onLoadOlder: () -> Void
    private var onLongPress: (MessageDisplayInfo) -> Void

    @State private var width: CGFloat?
    @State private var didInitialScroll = false
    @State private var readyForPagination = false
    @State private var lastOffset: CGFloat = 0
    @State private var previousFirstMessageId: String?
    @State private var previousLastMessageId: String?
    @State private var pendingScrollToNewest = false

    /// How close (in points) the top of the content must be to the visible top
    /// before older history is loaded.
    private let loadOlderThreshold: CGFloat = 300

    private let scrollAreaId = "topAlignedScrollArea"

    public init(
        factory: Factory,
        channel: ChatChannel,
        messages: [ChatMessage],
        messagesGroupingInfo: [String: [String]],
        scrolledId: Binding<String?>,
        quotedMessage: Binding<ChatMessage?>,
        scrollToNewestToken: Int = 0,
        onLoadOlder: @escaping () -> Void,
        onLongPress: @escaping (MessageDisplayInfo) -> Void
    ) {
        self.factory = factory
        self.channel = channel
        self.messages = messages
        self.messagesGroupingInfo = messagesGroupingInfo
        _scrolledId = scrolledId
        _quotedMessage = quotedMessage
        self.scrollToNewestToken = scrollToNewestToken
        self.onLoadOlder = onLoadOlder
        self.onLongPress = onLongPress
    }

    public var body: some View {
        ScrollViewReader { scrollView in
            ScrollView {
                GeometryReader { proxy in
                    let frame = proxy.frame(in: .named(scrollAreaId))
                    Color.clear.preference(key: ScrollViewOffsetPreferenceKey.self, value: frame.minY)
                    Color.clear.preference(key: WidthPreferenceKey.self, value: frame.width)
                }
                .frame(height: 0)

                LazyVStack(spacing: 0) {
                    ForEach(messages, id: \.id) { message in
                        factory.makeMessageItemView(
                            options: MessageItemViewOptions(
                                channel: channel,
                                message: message,
                                width: width,
                                showsAllInfo: showsAllData(for: message),
                                isInThread: false,
                                scrolledId: $scrolledId,
                                quotedMessage: $quotedMessage,
                                onLongPress: handleLongPress(messageDisplayInfo:),
                                isLast: message == messages.last
                            )
                        )
                        .id(message.id)
                    }
                }
            }
            .coordinateSpace(name: scrollAreaId)
            .onPreferenceChange(WidthPreferenceKey.self) { value in
                if let value, value != width {
                    width = value
                }
            }
            .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
                handleOffsetChange(value ?? 0)
            }
            .onAppear {
                scrollToNewestIfNeeded(scrollView)
            }
            .onChange(of: messages.count) { _ in
                handleMessagesCountChange(scrollView)
            }
            .onChange(of: scrolledId) { id in
                guard let id else { return }
                withAnimation {
                    scrollView.scrollTo(id, anchor: .center)
                }
            }
            .onChange(of: scrollToNewestToken) { _ in
                // The token is bumped just before a message is sent, before it
                // exists in the list. Scroll now (for the keyboard case) and mark
                // a pending scroll so the message is followed once it appends.
                pendingScrollToNewest = true
                forceScrollToNewest(scrollView)
            }
        }
        .frame(maxWidth: .infinity)
    }

    /// Scrolls to the newest message once, after the first page loads. No-op when
    /// the content fits (few messages stay at the top); scrolls to the bottom when
    /// it overflows (many messages open at the newest).
    private func scrollToNewestIfNeeded(_ scrollView: ScrollViewProxy) {
        guard !didInitialScroll, let newest = messages.last?.id else { return }
        didInitialScroll = true
        previousFirstMessageId = messages.first?.id
        previousLastMessageId = messages.last?.id
        DispatchQueue.main.async {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                scrollView.scrollTo(newest, anchor: .bottom)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                readyForPagination = true
            }
        }
    }

    /// Handles a change in the number of messages. On the first load it scrolls to
    /// the newest; afterwards, when older messages prepend at the top, it pins the
    /// previously-oldest message so the list keeps its position instead of jumping
    /// to the newly loaded top (which would also re-trigger pagination).
    private func handleMessagesCountChange(_ scrollView: ScrollViewProxy) {
        let oldFirst = previousFirstMessageId
        let oldLast = previousLastMessageId
        defer {
            previousFirstMessageId = messages.first?.id
            previousLastMessageId = messages.last?.id
        }

        guard didInitialScroll else {
            scrollToNewestIfNeeded(scrollView)
            return
        }

        // Older messages loaded (prepend at the top): keep the previously-oldest
        // message pinned so the list doesn't jump.
        if let oldFirst,
           oldFirst != messages.first?.id,
           messages.contains(where: { $0.id == oldFirst }) {
            restoreScrollAnchor(oldFirst, scrollView)
            return
        }

        let didAppend = oldLast != messages.last?.id

        // A message we just sent has now appended: follow it.
        if didAppend, pendingScrollToNewest {
            pendingScrollToNewest = false
            forceScrollToNewest(scrollView)
            return
        }

        // Any other message the current user sent (e.g. from another device).
        if didAppend, messages.last?.isSentByCurrentUser == true {
            forceScrollToNewest(scrollView)
        }
    }

    private func forceScrollToNewest(_ scrollView: ScrollViewProxy) {
        guard let newest = messages.last?.id else { return }
        DispatchQueue.main.async {
            withAnimation {
                scrollView.scrollTo(newest, anchor: .bottom)
            }
        }
    }

    /// Pins the given message to the top after a prepend, without animation, so the
    /// visible content does not move.
    private func restoreScrollAnchor(_ id: String, _ scrollView: ScrollViewProxy) {
        DispatchQueue.main.async {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                scrollView.scrollTo(id, anchor: .top)
            }
        }
    }

    private func handleOffsetChange(_ offset: CGFloat) {
        let diff = offset - lastOffset
        lastOffset = offset

        // `offset` is the content top's position within the scroll view: it is 0
        // at the very top (oldest visible) and increasingly negative as the list
        // scrolls toward the newest. Only load older history while actually
        // scrolling up (content moving down) and while close to the top — so
        // opening a channel at the newest never eagerly paginates.
        guard readyForPagination else { return }
        let scrollingUp = diff > 1
        let nearTop = offset > -loadOlderThreshold
        if scrollingUp, nearTop {
            onLoadOlder()
        }
    }

    private func handleLongPress(messageDisplayInfo: MessageDisplayInfo) {
        onLongPress(messageDisplayInfo)
    }

    private func showsAllData(for message: ChatMessage) -> Bool {
        if !utils.messageListConfig.groupMessages {
            return true
        }
        let groupInfo = messagesGroupingInfo[message.id] ?? []
        return groupInfo.contains(firstMessageKey)
    }
}
