//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public struct MessageListView<Factory: ViewFactory>: View, KeyboardReadable {
    @Injected(\.utils) private var utils
    @Injected(\.chatClient) private var chatClient
    @Injected(\.colors) private var colors

    var factory: Factory
    var channel: ChatChannel
    var messages: LazyCachedMapCollection<ChatMessage>
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
    
    var onMessageAppear: (Int, ScrollDirection) -> Void
    var onScrollToBottom: () -> Void
    var onLongPress: (MessageDisplayInfo) -> Void
    var onJumpToMessage: ((String) -> Bool)?
    
    @State private var width: CGFloat?
    @State private var keyboardShown = false
    @State private var pendingKeyboardUpdate: Bool?
    @State private var scrollDirection = ScrollDirection.up
    @State private var unreadMessagesBannerShown = false
    @State private var unreadButtonDismissed = false

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
    
    private var newMessagesSeparatorSize: CGFloat {
        messageListConfig.messageDisplayOptions.newMessagesSeparatorSize
    }

    private let scrollAreaId = "scrollArea"

    public init(
        factory: Factory,
        channel: ChatChannel,
        messages: LazyCachedMapCollection<ChatMessage>,
        messagesGroupingInfo: [String: [String]],
        scrolledId: Binding<String?>,
        showScrollToLatestButton: Binding<Bool>,
        quotedMessage: Binding<ChatMessage?>,
        currentDateString: String? = nil,
        listId: String,
        isMessageThread: Bool = false,
        shouldShowTypingIndicator: Bool = false,
        scrollPosition: Binding<String?> = .constant(nil),
        loadingNextMessages: Bool = false,
        firstUnreadMessageId: Binding<MessageId?> = .constant(nil),
        onMessageAppear: @escaping (Int, ScrollDirection) -> Void,
        onScrollToBottom: @escaping () -> Void,
        onLongPress: @escaping (MessageDisplayInfo) -> Void,
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
            self.messages = LazyCachedMapCollection(
                source: messages.filter { !skipRenderingMessageIds.contains($0.id) },
                map: { $0 }
            )
        }
    }
    
    public init(
        factory: Factory = DefaultViewFactory.shared,
        channel: ChatChannel,
        viewModel: ChatChannelViewModel,
        onLongPress: @escaping (MessageDisplayInfo) -> Void = { _ in }
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
            shouldShowTypingIndicator: viewModel.shouldShowTypingIndicator,
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

                    LazyVStack(spacing: 0) {
                        ForEach(messages, id: \.messageId) { message in
                            var index: Int? = messageListDateUtils.indexForMessageDate(message: message, in: messages)
                            let messageDate: Date? = messageListDateUtils.showMessageDate(for: index, in: messages)
                            let messageIsFirstUnread = firstUnreadMessageId?.contains(message.id) == true
                            let showUnreadSeparator = messageListConfig.showNewMessagesSeparator &&
                                messageIsFirstUnread &&
                                !isMessageThread
                            let showsLastInGroupInfo = showsLastInGroupInfo(for: message, channel: channel)
                            factory.makeMessageContainerView(
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
                            .environment(\.channelTranslationLanguage, channel.membership?.language)
                            .onAppear {
                                if index == nil {
                                    index = messageListDateUtils.index(for: message, in: messages)
                                }
                                if let index = index {
                                    onMessageAppear(index, scrollDirection)
                                }
                            }
                            .padding(
                                .top,
                                messageDate != nil ?
                                    offsetForDateIndicator(
                                        showsLastInGroupInfo: showsLastInGroupInfo,
                                        showUnreadSeparator: showUnreadSeparator
                                    ) :
                                    additionalTopPadding(
                                        showsLastInGroupInfo: showsLastInGroupInfo,
                                        showUnreadSeparator: showUnreadSeparator
                                    )
                            )
                            .overlay(
                                (messageDate != nil || showsLastInGroupInfo || showUnreadSeparator) ?
                                    VStack(spacing: 0) {
                                        messageDate != nil ?
                                            factory.makeMessageListDateIndicator(date: messageDate!)
                                            .frame(maxHeight: messageListConfig.messageDisplayOptions.dateLabelSize)
                                            : nil
                                        
                                        showUnreadSeparator ?
                                            factory.makeNewMessagesIndicatorView(
                                                newMessagesStartId: $firstUnreadMessageId,
                                                count: newMessagesCount(for: index, message: message)
                                            )
                                            .onAppear {
                                                unreadMessagesBannerShown = true
                                            }
                                            .onDisappear {
                                                unreadMessagesBannerShown = false
                                            }
                                            : nil

                                        showsLastInGroupInfo ?
                                            factory.makeLastInGroupHeaderView(for: message)
                                            .frame(maxHeight: lastInGroupHeaderSize)
                                            : nil

                                        Spacer()
                                    }
                                    : nil
                            )
                            .flippedUpsideDown()
                            .animation(nil, value: messageDate != nil)
                        }
                        .id(listId)
                    }
                    .delayedRendering()
                    .modifier(factory.makeMessageListModifier())
                    .modifier(ScrollTargetLayoutModifier(enabled: loadingNextMessages))
                }
                .modifier(ScrollPositionModifier(scrollPosition: loadingNextMessages ? $scrollPosition : .constant(nil)))
                .background(
                    factory.makeMessageListBackground(
                        colors: colors,
                        isInThread: isMessageThread
                    )
                )
                .coordinateSpace(name: scrollAreaId)
                .onPreferenceChange(WidthPreferenceKey.self) { value in
                    if let value = value, value != width {
                        self.width = value
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
                            showScrollToLatestButton = scrollButtonShown
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
                .flippedUpsideDown()
                .frame(maxWidth: .infinity)
                .clipped()
                .onChange(of: scrolledId) { scrolledId in
                    DispatchQueue.main.async {
                        if let scrolledId = scrolledId {
                            let shouldJump = onJumpToMessage?(scrolledId) ?? false
                            if !shouldJump {
                                return
                            }
                            withAnimation {
                                if messages.first?.id == scrolledId {
                                    scrollView.scrollTo(scrolledId, anchor: .top)
                                } else {
                                    scrollView.scrollTo(scrolledId, anchor: messageListConfig.scrollingAnchor)
                                }
                            }
                        }
                    }
                }
                .accessibilityIdentifier("MessageListScrollView")
            }

            if showScrollToLatestButton {
                factory.makeScrollToBottomButton(
                    unreadCount: channel.unreadCount.messages,
                    onScrollToBottom: onScrollToBottom
                )
            }

            if shouldShowTypingIndicator {
                factory.makeTypingIndicatorBottomView(
                    channel: channel,
                    currentUserId: chatClient.currentUserId
                )
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
        .overlay(
            (channel.unreadCount.messages > 0 && !unreadMessagesBannerShown && !isMessageThread && !unreadButtonDismissed) ?
                factory.makeJumpToUnreadButton(
                    channel: channel,
                    onJumpToMessage: {
                        _ = onJumpToMessage?(firstUnreadMessageId ?? .unknownMessageId)
                    },
                    onClose: {
                        chatClient.channelController(for: channel.cid).markRead()
                        unreadButtonDismissed = true
                    }
                ) : nil
        )
        .modifier(factory.makeMessageListContainerModifier())
        .onDisappear {
            messageRenderingUtil.update(previousTopMessage: nil)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("MessageListView")
    }
    
    private func additionalTopPadding(showsLastInGroupInfo: Bool, showUnreadSeparator: Bool) -> CGFloat {
        var padding = showsLastInGroupInfo ? lastInGroupHeaderSize : 0
        if showUnreadSeparator {
            padding += newMessagesSeparatorSize
        }
        return padding
    }

    private func offsetForDateIndicator(showsLastInGroupInfo: Bool, showUnreadSeparator: Bool) -> CGFloat {
        var offset = messageListConfig.messageDisplayOptions.dateLabelSize
        offset += additionalTopPadding(showsLastInGroupInfo: showsLastInGroupInfo, showUnreadSeparator: showUnreadSeparator)
        return offset
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
                showsBottomContainer: messageDisplayInfo.showsBottomContainer,
                keyboardWasShown: true
            )

            onLongPress(updatedDisplayInfo)
        } else {
            onLongPress(messageDisplayInfo)
        }
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

public enum ScrollDirection {
    case up
    case down
}

public struct NewMessagesIndicator: View {
    @Injected(\.colors) var colors
    
    @Binding var newMessagesStartId: String?
    var count: Int
    
    public init(newMessagesStartId: Binding<String?>, count: Int) {
        _newMessagesStartId = newMessagesStartId
        self.count = count
    }
    
    public var body: some View {
        HStack {
            Text("\(L10n.MessageList.newMessages(count))")
                .foregroundColor(Color(colors.textLowEmphasis))
                .font(.headline)
                .padding(.all, 8)
        }
        .frame(maxWidth: .infinity)
        .background(Color(colors.background8))
        .padding(.top, 4)
    }
}

public struct ScrollToBottomButton: View {
    @Injected(\.images) private var images
    @Injected(\.colors) private var colors

    private let buttonSize: CGFloat = 40

    var unreadCount: Int
    var onScrollToBottom: () -> Void

    public var body: some View {
        BottomRightView {
            Button {
                onScrollToBottom()
            } label: {
                Image(uiImage: images.scrollDownArrow)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: buttonSize, height: buttonSize)
                    .modifier(ShadowViewModifier(cornerRadius: buttonSize / 2))
            }
            .accessibilityLabel(Text(L10n.Channel.List.ScrollToBottom.title))
            .padding()
            .overlay(
                unreadCount > 0 ?
                    UnreadButtonIndicator(unreadCount: unreadCount) : nil
            )
        }
        .accessibilityIdentifier("ScrollToBottomButton")
    }
}

struct UnreadButtonIndicator: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts

    private let size: CGFloat = 16

    var unreadCount: Int

    var body: some View {
        Text("\(unreadCount)")
            .lineLimit(1)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .font(fonts.footnoteBold)
            .frame(width: unreadCount < 10 ? size : nil, height: size)
            .padding(.horizontal, unreadCount < 10 ? 2 : 6)
            .background(Color(colors.highlightedAccentBackground))
            .cornerRadius(9)
            .foregroundColor(Color(colors.staticColorText))
            .offset(y: -size)
    }
}

public struct DateIndicatorView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts

    var dateString: String

    public init(date: Date) {
        dateString = DateFormatter.messageListDateOverlay.string(from: date)
    }

    public init(dateString: String) {
        self.dateString = dateString
    }

    public var body: some View {
        VStack {
            Text(dateString)
                .font(fonts.footnote)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .foregroundColor(.white)
                .background(Color(colors.textLowEmphasis))
                .cornerRadius(16)
                .padding(.all, 8)
            Spacer()
        }
        .accessibilityAddTraits(.isHeader)
    }
}

struct TypingIndicatorBottomView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts

    var typingIndicatorString: String

    var body: some View {
        VStack {
            Spacer()
            HStack {
                TypingIndicatorView()
                Text(typingIndicatorString)
                    .font(fonts.footnote)
                    .foregroundColor(Color(colors.textLowEmphasis))
                Spacer()
            }
            .standardPadding()
            .background(
                Color(colors.background)
                    .opacity(0.9)
            )
            .accessibilityIdentifier("TypingIndicatorBottomView")
        }
        .accessibilityElement(children: .contain)
    }
}

private class MessageRenderingUtil {
    private var previousTopMessage: ChatMessage?

    static let shared = MessageRenderingUtil()

    var hasPreviousMessageSet: Bool {
        previousTopMessage != nil
    }

    func update(previousTopMessage: ChatMessage?) {
        self.previousTopMessage = previousTopMessage
    }

    func messagesToSkipRendering(newMessages: LazyCachedMapCollection<ChatMessage>) -> [String] {
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

private struct ChannelTranslationLanguageKey: EnvironmentKey {
    static let defaultValue: TranslationLanguage? = nil
}

private struct MessageViewModelKey: EnvironmentKey {
    static let defaultValue: MessageViewModel? = nil
}

extension EnvironmentValues {
    var channelTranslationLanguage: TranslationLanguage? {
        get {
            self[ChannelTranslationLanguageKey.self]
        }
        set {
            self[ChannelTranslationLanguageKey.self] = newValue
        }
    }

    var messageViewModel: MessageViewModel? {
        get {
            self[MessageViewModelKey.self]
        }
        set {
            self[MessageViewModelKey.self] = newValue
        }
    }
}
