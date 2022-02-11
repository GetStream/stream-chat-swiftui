//
// Copyright © 2022 Stream.io Inc. All rights reserved.
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
    var currentDateString: String?
    var listId: String
    var isMessageThread: Bool
    
    var onMessageAppear: (Int) -> Void
    var onScrollToBottom: () -> Void
    var onLongPress: (MessageDisplayInfo) -> Void
    
    @State private var width: CGFloat?
    @State private var height: CGFloat?
    @State private var keyboardShown = false
    @State private var pendingKeyboardUpdate: Bool?
    
    private var dateFormatter: DateFormatter {
        utils.dateFormatter
    }
    
    private var messageListConfig: MessageListConfig {
        utils.messageListConfig
    }
    
    private var shouldShowTypingIndicator: Bool {
        !channel.currentlyTypingUsersFiltered(currentUserId: chatClient.currentUserId).isEmpty
            && messageListConfig.typingIndicatorPlacement == .bottomOverlay
            && channel.config.typingEventsEnabled
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
        isMessageThread: Bool,
        onMessageAppear: @escaping (Int) -> Void,
        onScrollToBottom: @escaping () -> Void,
        onLongPress: @escaping (MessageDisplayInfo) -> Void
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
        _scrolledId = scrolledId
        _showScrollToLatestButton = showScrollToLatestButton
        _quotedMessage = quotedMessage
    }
    
    public var body: some View {
        ZStack {
            ScrollViewReader { scrollView in
                ScrollView {
                    GeometryReader { proxy in
                        let frame = proxy.frame(in: .named(scrollAreaId))
                        let offset = frame.minY
                        let width = frame.width
                        let height = frame.height
                        Color.clear.preference(key: ScrollViewOffsetPreferenceKey.self, value: offset)
                        Color.clear.preference(key: WidthPreferenceKey.self, value: width)
                        Color.clear.preference(key: HeightPreferenceKey.self, value: height)
                    }
                    
                    LazyVStack(spacing: 0) {
                        ForEach(messages, id: \.messageId) { message in
                            factory.makeMessageContainerView(
                                channel: channel,
                                message: message,
                                width: width,
                                showsAllInfo: showsAllData(for: message),
                                isInThread: isMessageThread,
                                scrolledId: $scrolledId,
                                quotedMessage: $quotedMessage,
                                onLongPress: handleLongPress(messageDisplayInfo:),
                                isLast: message == messages.last
                            )
                            .flippedUpsideDown()
                            .onAppear {
                                let index = messages.firstIndex { msg in
                                    msg.id == message.id
                                }
                                
                                if let index = index {
                                    onMessageAppear(index)
                                }
                            }
                        }
                        .id(listId)
                    }
                }
                .background(Color(colors.background))
                .coordinateSpace(name: scrollAreaId)
                .onPreferenceChange(WidthPreferenceKey.self) { value in
                    if let value = value, value != width {
                        self.width = value
                    }
                }
                .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
                    DispatchQueue.main.async {
                        let offsetValue = value ?? 0
                        showScrollToLatestButton = offsetValue < -20
                        if keyboardShown {
                            resignFirstResponder()
                        }
                    }
                }
                .onPreferenceChange(HeightPreferenceKey.self) { value in
                    if let value = value, value != height {
                        self.height = value
                    }
                }
                .flippedUpsideDown()
                .frame(minWidth: self.width, minHeight: height)
                .onChange(of: scrolledId) { scrolledId in
                    if !self.scrolledIdAvailableInMessages {
                        self.scrolledId = nil
                        return
                    }
                    if let scrolledId = scrolledId {
                        if scrolledId == messages.first?.messageId {
                            self.scrolledId = nil
                        } else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                self.scrolledId = nil
                            }
                        }
                        withAnimation {
                            scrollView.scrollTo(scrolledId, anchor: .bottom)
                        }
                    }
                }
            }
            
            if showScrollToLatestButton {
                factory.makeScrollToBottomButton(
                    unreadCount: channel.unreadCount.messages,
                    onScrollToBottom: onScrollToBottom
                )
            }
            
            if let date = currentDateString {
                factory.makeDateIndicatorView(dateString: date)
            }
                
            if shouldShowTypingIndicator {
                TypingIndicatorBottomView(
                    typingIndicatorString: channel.typingIndicatorString(currentUserId: chatClient.currentUserId)
                )
            }
        }
        .onReceive(keyboardPublisher) { visible in
            if currentDateString != nil {
                pendingKeyboardUpdate = visible
            } else {
                keyboardShown = visible
            }
        }
        .onChange(of: currentDateString, perform: { dateString in
            if dateString == nil, let keyboardUpdate = pendingKeyboardUpdate {
                keyboardShown = keyboardUpdate
                pendingKeyboardUpdate = nil
            }
        })
        .modifier(HideKeyboardOnTapGesture(shouldAdd: keyboardShown))
    }
    
    private var scrolledIdAvailableInMessages: Bool {
        if let scrolledId = scrolledId {
            return messages.map(\.messageId).contains(scrolledId)
        } else {
            return false
        }
    }
    
    private func showsAllData(for message: ChatMessage) -> Bool {
        if !messageListConfig.groupMessages {
            return true
        }
        let dateString = dateFormatter.string(from: message.createdAt)
        let prefix = message.author.id
        let key = "\(prefix)-\(dateString)"
        let inMessagingGroup = messagesGroupingInfo[key]?.contains(message.id) ?? false
        return inMessagingGroup
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
                isFirst: messageDisplayInfo.isFirst
            )
            
            onLongPress(updatedDisplayInfo)
        } else {
            onLongPress(messageDisplayInfo)
        }
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
            .padding()
            .overlay(
                unreadCount > 0 ?
                    UnreadButtonIndicator(unreadCount: unreadCount) : nil
            )
        }
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
    
    var date: String
    
    public var body: some View {
        VStack {
            Text(date)
                .font(fonts.footnote)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .foregroundColor(.white)
                .background(Color(colors.textLowEmphasis))
                .cornerRadius(16)
                .padding(.all, 8)
            Spacer()
        }
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
                    .font(.footnote)
                    .foregroundColor(Color(colors.textLowEmphasis))
                Spacer()
            }
            .standardPadding()
            .background(
                Color(colors.background)
                    .opacity(0.9)
            )
        }
    }
}
