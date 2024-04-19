//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Combine
import StreamChat
import SwiftUI

/// View model for the `ChatChannelView`.
@MainActor open class ChatChannelViewModel: ObservableObject, MessagesDataSource {
    
    @Injected(\.chatClient) private var chatClient
    @Injected(\.utils) private var utils
    @Injected(\.images) private var images
    
    private var channelDataSource: ChannelDataSource
    private var cancellables = Set<AnyCancellable>()
    private var lastRefreshThreshold = 200
    private let refreshThreshold = 200
    private static let newerMessagesLimit: Int = {
        if #available(iOS 17, *) {
            // On iOS 17 we can maintain the scroll position.
            return 25
        } else {
            return 5
        }
    }()
    
    private var timer: Timer?
    private var currentDate: Date? {
        didSet {
            handleDateChange()
        }
    }

    private var isActive = true
    private var readsString = ""
    private var canMarkRead = true
    
    private let messageListDateOverlay: DateFormatter = DateFormatter.messageListDateOverlay
    
    private lazy var messagesDateFormatter = utils.dateFormatter
    private lazy var messageCachingUtils = utils.messageCachingUtils
    
    private var loadingPreviousMessages: Bool = false
    private var loadingMessagesAround: Bool = false
    private var lastMessageRead: String?
    private var disableDateIndicator = false
    private var channelName = ""
    private var onlineIndicatorShown = false
    private var lastReadMessageId: String?
    private let throttler = Throttler(interval: 3, broadcastLatestEvent: true)
    
    public var chat: Chat
    public var messageId: MessageId?
    
    @Published public var scrolledId: String?
    @Published public var listId = UUID().uuidString

    @Published public var showScrollToLatestButton = false

    @Published public var currentDateString: String?
    @Published public var messages = StreamCollection<ChatMessage>([]) {
        didSet {
            if utils.messageListConfig.groupMessages {
                groupMessages()
            }
        }
    }

    @Published public var messagesGroupingInfo = [String: [String]]()
    @Published public var currentSnapshot: UIImage? {
        didSet {
            withAnimation {
                reactionsShown = currentSnapshot != nil
                    && utils.messageListConfig.messagePopoverEnabled
                    && channel?.isFrozen == false
            }
        }
    }

    @Published public var reactionsShown = false {
        didSet {
            // When reactions are shown, the navigation bar is hidden.
            // Check the header type and trigger an update.
            guard let channel else { return }
            checkHeaderType(for: channel)
        }
    }

    @Published public var quotedMessage: ChatMessage? {
        didSet {
            if oldValue != nil && quotedMessage == nil {
                disableDateIndicator = true
            }
        }
    }

    @Published public var editedMessage: ChatMessage?
    @Published public var channelHeaderType: ChannelHeaderType = .regular
    @Published public var threadMessage: ChatMessage?
    @Published public var threadMessageShown = false {
        didSet {
            if threadMessageShown == false {
                threadMessage = nil
            }
            utils.messageCachingUtils.messageThreadShown = threadMessageShown
        }
    }

    @Published public var shouldShowTypingIndicator = false
    @Published public var scrollPosition: String?
    @Published public private(set) var loadingNextMessages: Bool = false
    @Published public var firstUnreadMessageId: String? {
        didSet {
            if oldValue != nil && firstUnreadMessageId == nil && (channel?.unreadCount.messages ?? 0) > 0 {
                Task {
                    try await chat.markRead()
                }
            }
        }
    }
    
    public var channel: ChatChannel? {
        chat.state.channel
    }
    
    public var isMessageThread: Bool {
        messageId != nil
    }
            
    public init(
        chat: Chat,
        messageId: MessageId? = nil,
        scrollToMessage: ChatMessage? = nil
    ) {
        self.chat = chat
        if let messageId {
            self.messageId = messageId
            channelDataSource = MessageThreadDataSource(
                chat: chat,
                messageId: messageId
            )
        } else {
            channelDataSource = ChatChannelDataSource(chat: chat)
        }
        channelDataSource.delegate = self
        messages = channelDataSource.messages
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            if let scrollToMessage, let parentMessageId = scrollToMessage.parentMessageId, messageId == nil {
                let message = chat.localMessage(for: parentMessageId)
                self?.threadMessage = message
                self?.threadMessageShown = true
                self?.messageCachingUtils.jumpToReplyId = scrollToMessage.messageId
            } else if messageId != nil, let jumpToReplyId = self?.messageCachingUtils.jumpToReplyId {
                self?.scrolledId = jumpToReplyId
                self?.messageCachingUtils.jumpToReplyId = nil
            } else if messageId == nil {
                self?.scrolledId = scrollToMessage?.messageId
            }
        }
              
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        
        if messageId == nil {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(selectedMessageThread(notification:)),
                name: NSNotification.Name(MessageRepliesConstants.selectedMessageThread),
                object: nil
            )
        }
                
        channelName = channel?.name ?? ""
        checkUnreadCount()
    }
    
    @objc
    private func selectedMessageThread(notification: Notification) {
        if let message = notification.userInfo?[MessageRepliesConstants.selectedMessage] as? ChatMessage {
            threadMessage = message
            threadMessageShown = true
        }
    }
    
    @objc
    private func didReceiveMemoryWarning() {
        ImageCache.shared.removeAll()
        messageCachingUtils.clearCache()
    }
    
    @objc
    private func applicationWillEnterForeground() {
        guard let first = messages.first else { return }
        if canMarkRead {
            sendReadEventIfNeeded(for: first)
        }
    }
    
    public func scrollToLastMessage() {
        if channelDataSource.hasLoadedAllNextMessages {
            updateScrolledIdToNewestMessage()
        } else {
            Task { @MainActor in
                try await channelDataSource.loadFirstPage()
                self.scrolledId = self.messages.first?.messageId
            }
        }
    }
        
    public func jumpToMessage(messageId: String) -> Bool {
        if messageId == .unknownMessageId {
            if firstUnreadMessageId == nil, let lastReadMessageId {
                Task {
                    try await channelDataSource.loadPageAroundMessageId(lastReadMessageId)
                    if let firstUnread = channelDataSource.firstUnreadMessageId,
                       let message = chat.localMessage(for: firstUnread) {
                        firstUnreadMessageId = message.messageId
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                            self?.scrolledId = message.messageId
                        }
                    }
                }
            }
            return false
        }
        if messageId == messages.first?.messageId {
            scrolledId = nil
            return true
        } else {
            guard let baseId = messageId.components(separatedBy: "$").first else {
                scrolledId = nil
                return true
            }
            let alreadyLoaded = messages.map(\.id).contains(baseId)
            if alreadyLoaded && baseId != messageId {
                if scrolledId == nil {
                    scrolledId = messageId
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                    self?.scrolledId = nil
                }
                return true
            } else {
                let message = chat.localMessage(for: baseId)
                if let parentMessageId = message?.parentMessageId, !isMessageThread {
                    let parentMessage = chat.localMessage(for: parentMessageId)
                    threadMessage = parentMessage
                    threadMessageShown = true
                    messageCachingUtils.jumpToReplyId = message?.messageId
                    return false
                }
                
                scrolledId = nil
                if loadingMessagesAround {
                    return false
                }
                loadingMessagesAround = true
                Task {
                    try await channelDataSource.loadPageAroundMessageId(baseId)
                    var toJumpId = messageId
                    if toJumpId == baseId, let message = chat.localMessage(for: toJumpId) {
                        toJumpId = message.messageId
                    }
                    let scrolledId = toJumpId
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                        self?.scrolledId = scrolledId
                        self?.loadingMessagesAround = false
                    }
                }
                return false
            }
        }
    }
    
    open func handleMessageAppear(index: Int, scrollDirection: ScrollDirection) {
        if index >= channelDataSource.messages.count || loadingMessagesAround {
            return
        }
        
        let message = messages[index]
        if scrollDirection == .up {
            checkForOlderMessages(index: index)
        } else {
            checkForNewerMessages(index: index)
        }
        if let firstUnreadMessageId, firstUnreadMessageId.contains(message.id) {
            canMarkRead = true
        }
        if utils.messageListConfig.dateIndicatorPlacement == .overlay {
            save(lastDate: message.createdAt)
        }
        if index == 0 {
            let isActive = UIApplication.shared.applicationState == .active
            if isActive && canMarkRead {
                sendReadEventIfNeeded(for: message)
            }
        }
    }
    
    open func groupMessages() {
        var temp = [String: [String]]()
        for (index, message) in messages.enumerated() {
            let date = message.createdAt
            temp[message.id] = []
            if index == 0 {
                temp[message.id] = [firstMessageKey]
                continue
            } else if index == messages.count - 1 {
                temp[message.id] = [lastMessageKey]
            }
            
            let previous = index - 1
            let previousMessage = messages[previous]
            let currentAuthorId = messageCachingUtils.authorId(for: message)
            let previousAuthorId = messageCachingUtils.authorId(for: previousMessage)

            if currentAuthorId != previousAuthorId {
                temp[message.id]?.append(firstMessageKey)
                var prevInfo = temp[previousMessage.id] ?? []
                prevInfo.append(lastMessageKey)
                temp[previousMessage.id] = prevInfo
            }

            if previousMessage.type == .error
                || previousMessage.type == .ephemeral
                || previousMessage.type == .system {
                temp[message.id] = [firstMessageKey]
                continue
            }

            let delay = previousMessage.createdAt.timeIntervalSince(date)
            let showMessageEditedLabel = utils.messageListConfig.isMessageEditedLabelEnabled
                && message.textUpdatedAt != nil

            if delay > utils.messageListConfig.maxTimeIntervalBetweenMessagesInGroup
                || showMessageEditedLabel {
                temp[message.id]?.append(firstMessageKey)
                var prevInfo = temp[previousMessage.id] ?? []
                prevInfo.append(lastMessageKey)
                temp[previousMessage.id] = prevInfo
            }
            
            if temp[message.id]?.isEmpty == true {
                temp[message.id] = nil
            }
        }
        
        messagesGroupingInfo = temp
    }
    
    func dataSource(
        channelDataSource: ChannelDataSource,
        didUpdateMessages messages: StreamCollection<ChatMessage>
    ) {
        if !isActive {
            return
        }
        
        if let messageId, let message = chat.localMessage(for: messageId) {
            var array = Array(messages)
            array.append(message)
            self.messages = StreamCollection(array)
        } else {
            let animationState = shouldAnimate(from: self.messages, to: messages)
            if animationState == .animated {
                withAnimation {
                    self.messages = messages
                }
            } else if animationState == .notAnimated {
                self.messages = messages
            }
        }
        
        refreshMessageListIfNeeded()
        
        if !showScrollToLatestButton && scrolledId == nil && !loadingNextMessages {
            updateScrolledIdToNewestMessage()
        }
        
        if lastReadMessageId != nil && firstUnreadMessageId == nil {
            firstUnreadMessageId = channelDataSource.firstUnreadMessageId
        }
    }
    
    func dataSource(
        channelDataSource: ChannelDataSource,
        didUpdateChannel channel: ChatChannel
    ) {
        checkReadIndicators(for: channel)
        checkTypingIndicator(for: channel)
        checkHeaderType(for: channel)
        checkOnlineIndicator(for: channel)
    }

    public func showReactionOverlay(for view: AnyView) {
        currentSnapshot = utils.snapshotCreator.makeSnapshot(for: view)
    }
    
    public func messageActionExecuted(_ messageActionInfo: MessageActionInfo) {
        utils.messageActionsResolver.resolveMessageAction(
            info: messageActionInfo,
            viewModel: self
        )
    }
    
    public func onViewAppear() {
        setActive()
        messages = channelDataSource.messages
        firstUnreadMessageId = channelDataSource.firstUnreadMessageId
        checkNameChange()
    }
    
    public func onViewDissappear() {
        isActive = false
    }
    
    public func setActive() {
        isActive = true
    }
    
    // MARK: - private
    
    private func checkForOlderMessages(index: Int) {
        if index < channelDataSource.messages.count - 25 {
            return
        }

        log.debug("Loading previous messages")
        if !loadingPreviousMessages {
            loadingPreviousMessages = true
            Task {
                try? await channelDataSource.loadOlderMessages(
                    limit: utils.messageListConfig.pageSize
                )
                loadingPreviousMessages = false
            }
        }
    }
        
    private func checkForNewerMessages(index: Int) {
        if channelDataSource.hasLoadedAllNextMessages {
            return
        }
        if loadingNextMessages || (index > 5) {
            return
        }
        loadingNextMessages = true
        
        if scrollPosition != messages.first?.messageId {
            scrollPosition = messages[index].messageId
        }

        Task { @MainActor in
            try? await channelDataSource.loadNewerMessages(limit: Self.newerMessagesLimit)
            try? await Task.sleep(nanoseconds: 500_000)
            self.loadingNextMessages = false
        }
    }
    
    private func save(lastDate: Date) {
        if disableDateIndicator {
            enableDateIndicator()
            return
        }
        
        currentDate = lastDate
        timer?.invalidate()
        timer = Timer.scheduledTimer(
            withTimeInterval: 0.5,
            repeats: false,
            block: { [weak self] _ in
                guard let self else { return }
                Task { @MainActor in
                    self.resetCurrentDate()
                }
            }
        )
    }
    
    private func resetCurrentDate() {
        currentDate = nil
    }
    
    private func sendReadEventIfNeeded(for message: ChatMessage) {
        if message.id != lastMessageRead {
            lastMessageRead = message.id
            throttler.throttle { [weak self] in
                guard let self else { return }
                Task {
                    try? await self.chat.markRead()
                    await MainActor.run {
                        self.firstUnreadMessageId = nil
                    }
                }
            }
        }
    }
    
    private func refreshMessageListIfNeeded() {
        let count = messages.count
        if count > lastRefreshThreshold {
            lastRefreshThreshold = lastRefreshThreshold + refreshThreshold
            listId = UUID().uuidString
        }
    }
    
    private func checkReadIndicators(for channel: ChatChannel) {
        let newReadsString = channel.readsString
        if readsString == "" {
            readsString = newReadsString
            return
        }
        if readsString != newReadsString && isActive {
            messages = channelDataSource.messages
            readsString = newReadsString
        }
    }
    
    private func checkNameChange() {
        let currentChannelName = channel?.name ?? ""
        var nameChanged = false
        
        if currentChannelName != channelName {
            channelName = currentChannelName
            nameChanged = true
        }
        
        if nameChanged {
            triggerHeaderChange()
        }
    }
    
    private func checkOnlineIndicator(for channel: ChatChannel) {
        let updated = !channel.lastActiveMembers.filter { member in
            member.id != chatClient.currentUserId && member.isOnline
        }.isEmpty
        
        if updated != onlineIndicatorShown {
            onlineIndicatorShown = updated
            triggerHeaderChange()
        }
    }
    
    private func triggerHeaderChange() {
        // Toolbar is not updated unless there's a state change.
        // Therefore, we manually need to update the state for a short period of time.
        let headerType = channelHeaderType
        channelHeaderType = .typingIndicator
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.channelHeaderType = headerType
        }
    }
    
    private func checkHeaderType(for channel: ChatChannel) {
        let type: ChannelHeaderType
        let typingUsers = channel.currentlyTypingUsersFiltered(
            currentUserId: chatClient.currentUserId
        )
        
        if !reactionsShown && isMessageThread {
            type = .messageThread
        } else if !typingUsers.isEmpty && utils.messageListConfig.typingIndicatorPlacement == .navigationBar {
            type = .typingIndicator
        } else {
            type = .regular
        }
        
        if type != channelHeaderType {
            channelHeaderType = type
        } else if type == .typingIndicator {
            // Toolbar is not updated when new user starts typing.
            // Therefore, we shortly update the state to regular to trigger an update.
            channelHeaderType = .regular
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.channelHeaderType = .typingIndicator
            }
        }
    }
    
    private func checkUnreadCount() {
        guard !isMessageThread else { return }
        if chat.state.channel?.unreadCount.messages ?? 0 > 0 {
            if chat.state.firstUnreadMessageId != nil {
                firstUnreadMessageId = chat.state.firstUnreadMessageId
                canMarkRead = false
            } else if chat.state.lastReadMessageId != nil {
                lastReadMessageId = chat.state.lastReadMessageId
                canMarkRead = false
            }
        }
    }
    
    private func handleDateChange() {
        guard showScrollToLatestButton == true, let currentDate = currentDate else {
            currentDateString = nil
            return
        }
        
        let dateString = messageListDateOverlay.string(from: currentDate)
        if currentDateString != dateString {
            currentDateString = dateString
        }
    }
    
    private func shouldAnimate(from oldMessages: StreamCollection<ChatMessage>, to newMessages: StreamCollection<ChatMessage>) -> AnimationChange {
        if !utils.messageListConfig.messageDisplayOptions.animateChanges || loadingNextMessages {
            return .notAnimated
        }
        // Animate when inserting or removing messages
        if oldMessages.count != newMessages.count {
            return .animated
        }
        
        var skipChanges = true
        var animateChanges = false
        for (firstMessage, secondMessage) in zip(oldMessages, newMessages).reversed() {
            // The order has changed (moved or inserts == removals)
            if firstMessage.messageId != secondMessage.messageId {
                return .animated
            }
            // Updated
            if firstMessage.updatedAt != secondMessage.updatedAt {
                if secondMessage.type == .ephemeral || !secondMessage.linkAttachments.isEmpty  {
                    skipChanges = false
                    if utils.messageListConfig.messageDisplayOptions.shouldAnimateReactions,
                        firstMessage.reactionScoresId != secondMessage.reactionScoresId {
                        animateChanges = secondMessage.linkAttachments.isEmpty
                        if animateChanges {
                            break
                        }
                    }
                }
            }
        }
        if skipChanges {
            return .skip
        }
        
        return animateChanges ? .animated : .notAnimated
    }
    
    private func enableDateIndicator() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.disableDateIndicator = false
        }
    }
    
    private func checkTypingIndicator(for channel: ChatChannel) {
        let shouldShow = !channel.currentlyTypingUsersFiltered(currentUserId: chatClient.currentUserId).isEmpty
            && utils.messageListConfig.typingIndicatorPlacement == .bottomOverlay
            && channel.config.typingEventsEnabled
        if shouldShow != shouldShowTypingIndicator {
            shouldShowTypingIndicator = shouldShow
        }
    }
    
    private func updateScrolledIdToNewestMessage() {
        if scrolledId != nil {
            scrolledId = nil
        }
        scrolledId = messages.first?.messageId
    }
    
    private func cleanupAudioPlayer() {
        guard utils.composerConfig.isVoiceRecordingEnabled else { return }
        utils.audioPlayer.seek(to: 0)
        utils.audioPlayer.updateRate(.normal)
        utils.audioPlayer.stop()
        utils._audioPlayer = nil
    }
    
    deinit {
        Task { @MainActor [weak self] in
            guard let self else { return }
            messageCachingUtils.clearCache()
            if messageId == nil {
                utils.chatCache.clearCurrentChat()
                cleanupAudioPlayer()
                ImageCache.shared.trim(toCost: utils.messageListConfig.cacheSizeOnChatDismiss)
                if !channelDataSource.hasLoadedAllNextMessages {
                    try await channelDataSource.loadFirstPage()
                }
            }
        }
    }
}

extension ChatMessage: Identifiable {
    
    public var scrollMessageId: String {
        messageId
    }
    
    var messageId: String {
        InjectedValues[\.utils].messageIdBuilder.makeMessageId(for: self)
    }
    
    var baseId: String {
        isDeleted ? "\(id)$deleted" : "\(id)$"
    }
    
    var pinStateId: String {
        pinDetails != nil ? "pinned" : "notPinned"
    }
    
    var repliesCountId: String {
        var repliesCountId = ""
        if replyCount > 0 {
            repliesCountId = "\(replyCount)"
        }

        return repliesCountId
    }
    
    var uploadingStatesId: String {
        var states = imageAttachments.compactMap { $0.uploadingState?.state }
        states += giphyAttachments.compactMap { $0.uploadingState?.state }
        states += videoAttachments.compactMap { $0.uploadingState?.state }
        states += fileAttachments.compactMap { $0.uploadingState?.state }
        
        if states.isEmpty {
            if localState == .sendingFailed {
                return "failed"
            } else {
                return localState?.rawValue ?? "empty"
            }
        }
        
        let strings = states.map { "\($0)" }
        let combined = strings.joined(separator: "-")
        return combined
    }
    
    var reactionScoresId: String {
        var output = ""
        if reactionScores.isEmpty {
            return output
        }
        let sorted = reactionScores.keys.sorted { type1, type2 in
            type1.id > type2.id
        }
        for key in sorted {
            let score = reactionScores[key] ?? 0
            output += "\(key.rawValue)\(score)"
        }
        return output
    }
}

extension ChatChannel {
    
    var readsString: String {
        reads.map { read in
            "\(read.user.id)-\(read.lastReadAt)"
        }
        .sorted()
        .joined(separator: "-")
    }
}

/// The type of header shown in the chat channel screen.
public enum ChannelHeaderType {
    /// The regular header showing the channel name and members.
    case regular
    /// The header shown in message threads.
    case messageThread
    /// The header shown when someone is typing.
    case typingIndicator
}

enum AnimationChange {
    case animated
    case notAnimated
    case skip
}

let firstMessageKey = "firstMessage"
let lastMessageKey = "lastMessage"
