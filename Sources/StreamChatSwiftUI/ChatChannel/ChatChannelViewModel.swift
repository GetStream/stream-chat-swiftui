//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import Combine
import StreamChat
import SwiftUI

/// View model for the `ChatChannelView`.
open class ChatChannelViewModel: ObservableObject, MessagesDataSource {
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
    private var canMarkRead = false
    private var hasSetInitialCanMarkRead = false
    private var currentUserSentNewMessage = false

    private let messageListDateOverlay: DateFormatter = DateFormatter.messageListDateOverlay
    
    private lazy var messagesDateFormatter = utils.dateFormatter
    private lazy var messageCachingUtils = utils.messageCachingUtils
    
    private var loadingPreviousMessages: Bool = false
    private var loadingMessagesAround: Bool = false
    private var scrollsToUnreadAfterJumpToMessage = false
    private var disableDateIndicator = false
    private var channelName = ""
    private var onlineIndicatorShown = false
    private var lastReadMessageId: String?
    var throttler = Throttler(interval: 3, broadcastLatestEvent: true)
    
    public var channelController: ChatChannelController
    public var messageController: ChatMessageController?
    
    @Published public var scrolledId: String?
    @Published public var highlightedMessageId: String?
    @Published public var listId = UUID().uuidString
    // A boolean to skip highlighting of a message when scrolling to it.
    // This is used for scenarios when scrolling to message Id should not highlight it.
    var skipHighlightMessageId: String?

    @Published public var showScrollToLatestButton = false
    @Published var showAlertBanner = false

    @Published public var currentDateString: String?
    @Published public var messages = LazyCachedMapCollection<ChatMessage>() {
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
            checkHeaderType()
        }
    }

    @Published public var bouncedMessage: ChatMessage?
    @Published public var bouncedActionsViewShown = false {
        didSet {
            if bouncedActionsViewShown == false {
                bouncedMessage = nil
            }
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
                channelController.markRead()
            }
        }
    }

    // A boolean value indicating if the user marked a message as unread
    // in the current session of the channel. If it is true,
    // it should not call markRead() in any scenario.
    public var currentUserMarkedMessageUnread: Bool = false

    @Published public private(set) var channel: ChatChannel?

    public var isMessageThread: Bool {
        messageController != nil
    }
            
    public init(
        channelController: ChatChannelController,
        messageController: ChatMessageController? = nil,
        scrollToMessage: ChatMessage? = nil
    ) {
        self.channelController = channelController
        if InjectedValues[\.utils].shouldSyncChannelControllerOnAppear(channelController)
            && messageController == nil {
            channelController.synchronize()
        }
        if let messageController = messageController {
            self.messageController = messageController
            messageController.synchronize()
            channelDataSource = MessageThreadDataSource(
                channelController: channelController,
                messageController: messageController
            )
        } else {
            channelDataSource = ChatChannelDataSource(controller: channelController)
        }
        channelDataSource.delegate = self
        messages = channelDataSource.messages
        channel = channelController.channel

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            if let scrollToMessage, let parentMessageId = scrollToMessage.parentMessageId, messageController == nil {
                let message = channelController.dataStore.message(id: parentMessageId)
                self?.threadMessage = message
                self?.threadMessageShown = true
                self?.messageCachingUtils.jumpToReplyId = scrollToMessage.messageId
            } else if messageController != nil, let jumpToReplyId = self?.messageCachingUtils.jumpToReplyId {
                self?.scrolledId = jumpToReplyId
                // Clear scroll ID after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                    self?.scrolledId = nil
                }
                self?.highlightMessage(withId: jumpToReplyId)
                self?.messageCachingUtils.jumpToReplyId = nil
            } else if messageController == nil {
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
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onViewAppear),
            name: .messageSheetHiddenNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onViewDissappear),
            name: .messageSheetShownNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onShowChannelAlertBanner),
            name: .showChannelAlertBannerNotification,
            object: nil
        )
        
        if messageController == nil {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(selectedMessageThread(notification:)),
                name: NSNotification.Name(MessageRepliesConstants.selectedMessageThread),
                object: nil
            )
        }
                
        channelName = channel?.name ?? ""
        checkHeaderType()
        checkUnreadCount()
    }

    @objc
    private func selectedMessageThread(notification: Notification) {
        if let message = notification.userInfo?[MessageRepliesConstants.selectedMessage] as? ChatMessage {
            threadMessage = message
            threadMessageShown = true

            // Only set jumpToReplyId if there's a specific reply message to highlight
            // (for showReplyInChannel messages). The parent message should never be highlighted.
            if let replyMessage = notification.userInfo?[MessageRepliesConstants.threadReplyMessage] as? ChatMessage {
                messageCachingUtils.jumpToReplyId = replyMessage.messageId
            }
        }
    }
    
    @objc
    private func onShowChannelAlertBanner() {
        showAlertBanner = true
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
        if shouldMarkThreadRead {
            sendThreadReadEvent()
        }
    }
    
    public func scrollToLastMessage() {
        if channelDataSource.hasLoadedAllNextMessages {
            updateScrolledIdToNewestMessage()
        } else {
            channelDataSource.loadFirstPage { [weak self] _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self?.scrolledId = self?.messages.first?.messageId
                    self?.showScrollToLatestButton = false
                }
            }
        }
    }

    /// The user tapped on the message sent button.
    public func messageSentTapped() {
        currentUserSentNewMessage = true
    }

    public func jumpToMessage(messageId: String) -> Bool {
        if messageId == .unknownMessageId {
            if firstUnreadMessageId == nil, let lastReadMessageId {
                scrollsToUnreadAfterJumpToMessage = true
                channelDataSource.loadPageAroundMessageId(lastReadMessageId) { error in
                    if error != nil {
                        log.error("Error loading messages around message \(messageId)")
                    }
                }
            }
            return false
        }
        if messageId == messages.first?.messageId {
            scrolledId = nil
            return true
        } else {
            let baseId = messageId
            let alreadyLoaded = messages.map(\.id).contains(baseId)
            if alreadyLoaded {
                if scrolledId == nil {
                    scrolledId = messageId
                }
                // Clear scroll ID after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                    self?.scrolledId = nil
                }
                highlightMessage(withId: messageId)
                return true
            } else {
                let message = channelController.dataStore.message(id: baseId)
                if let parentMessageId = message?.parentMessageId, !isMessageThread {
                    let parentMessage = channelController.dataStore.message(id: parentMessageId)
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
                channelDataSource.loadPageAroundMessageId(baseId) { [weak self] error in
                    if error != nil {
                        log.error("Error loading messages around message \(messageId)")
                        return
                    }
                    var toJumpId = messageId
                    if toJumpId == baseId, let message = self?.channelController.dataStore.message(id: toJumpId) {
                        toJumpId = message.messageId
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                        self?.scrolledId = toJumpId
                        self?.loadingMessagesAround = false
                        self?.highlightMessage(withId: toJumpId)
                    }
                }
                return false
            }
        }
    }

    /// Highlights the message background.
    ///
    /// - Parameter messageId: The ID of the message to highlight.
    public func highlightMessage(withId messageId: MessageId) {
        if skipHighlightMessageId == messageId {
            skipHighlightMessageId = nil
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.highlightedMessageId = messageId
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
            withAnimation {
                self?.highlightedMessageId = nil
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
        if let firstUnreadMessageId, firstUnreadMessageId.contains(message.id), hasSetInitialCanMarkRead {
            canMarkRead = true
        }
        if utils.messageListConfig.dateIndicatorPlacement == .overlay {
            save(lastDate: message.createdAt)
        }
        if channelDataSource.hasLoadedAllNextMessages {
            let isActive = UIApplication.shared.applicationState == .active
            if isActive && canMarkRead {
                sendReadEventIfNeeded(for: message)
            }
        }
        if index == 0 && shouldMarkThreadRead {
            sendThreadReadEvent()
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
            let currentAuthorId = message.author.id
            let previousAuthorId = previousMessage.author.id

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
        didUpdateMessages messages: LazyCachedMapCollection<ChatMessage>,
        changes: [ListChange<ChatMessage>]
    ) {
        if !isActive {
            return
        }
        
        // Set unread state before updating messages for ensuring the state is up to date before `handleMessageAppear` is called
        if lastReadMessageId != nil && firstUnreadMessageId == nil {
            firstUnreadMessageId = channelDataSource.firstUnreadMessageId
        }
        
        if shouldAnimate(changes: changes) {
            withAnimation {
                self.messages = messages
            }
        } else {
            self.messages = messages
        }
        
        refreshMessageListIfNeeded()
        
        // Jump to a message but we were already scrolled to the bottom
        if !channelDataSource.hasLoadedAllNextMessages {
            showScrollToLatestButton = true
        }
        
        // Set scroll id after the message id has changed
        if scrollsToUnreadAfterJumpToMessage, let firstUnreadMessageId {
            scrollsToUnreadAfterJumpToMessage = false
            scrolledId = firstUnreadMessageId
        }
        
        if !showScrollToLatestButton && scrolledId == nil && !loadingNextMessages {
            updateScrolledIdToNewestMessage()
        } else if changes.first?.isInsertion == true && currentUserSentNewMessage {
            updateScrolledIdToNewestMessage()
            currentUserSentNewMessage = false
        }
    }
    
    func dataSource(
        channelDataSource: ChannelDataSource,
        didUpdateChannel channel: EntityChange<ChatChannel>,
        channelController: ChatChannelController
    ) {
        self.channel = channel.item
        checkReadIndicators(for: channel)
        checkTypingIndicator()
        checkHeaderType()
        checkOnlineIndicator()
        checkUnreadCount()
    }

    public func showReactionOverlay(for view: AnyView) {
        currentSnapshot = utils.snapshotCreator.makeSnapshot(for: view)
    }

    public func showBouncedActionsView(for message: ChatMessage) {
        bouncedActionsViewShown = true
        bouncedMessage = message
    }

    public func deleteMessage(_ message: ChatMessage) {
        guard let cid = message.cid else { return }
        let messageController = chatClient.messageController(cid: cid, messageId: message.id)
        messageController.deleteMessage()
    }

    public func resendMessage(_ message: ChatMessage) {
        guard let cid = message.cid else { return }
        let messageController = chatClient.messageController(cid: cid, messageId: message.id)
        messageController.resendMessage()
    }

    public func editMessage(_ message: ChatMessage) {
        messageActionExecuted(.init(message: message, identifier: "edit"))
    }

    open func messageActionExecuted(_ messageActionInfo: MessageActionInfo) {
        utils.messageActionsResolver.resolveMessageAction(
            info: messageActionInfo,
            viewModel: self
        )
    }
    
    @objc public func onViewAppear() {
        utils.originalTranslationsStore.clear()
        setActive()
        messages = channelDataSource.messages
        firstUnreadMessageId = channelDataSource.firstUnreadMessageId
        checkNameChange()
    }
    
    @objc public func onViewDissappear() {
        isActive = false
    }
    
    public func setActive() {
        isActive = true
    }
    
    // MARK: - private

    private func checkForOlderMessages(index: Int) {
        guard index >= channelDataSource.messages.count - 25 else { return }
        guard !loadingPreviousMessages else { return }
        guard !channelController.hasLoadedAllPreviousMessages else { return }
        
        log.debug("Loading previous messages")
        loadingPreviousMessages = true
        channelDataSource.loadPreviousMessages(
            before: nil,
            limit: utils.messageListConfig.pageSize,
            completion: { [weak self] _ in
                guard let self = self else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.loadingPreviousMessages = false
                }
            }
        )
    }
        
    private func checkForNewerMessages(index: Int) {
        guard index <= 5 else { return }
        guard !loadingNextMessages else { return }
        guard !channelController.hasLoadedAllNextMessages else { return }
        
        loadingNextMessages = true
        
        if scrollPosition != messages.first?.messageId {
            scrollPosition = messages[index].messageId
        }

        channelDataSource.loadNextMessages(limit: Self.newerMessagesLimit) { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.loadingNextMessages = false
            }
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
                self?.currentDate = nil
            }
        )
    }
    
    private func sendReadEventIfNeeded(for message: ChatMessage) {
        guard let channel, channel.unreadCount.messages > 0 else {
            return
        }
        if currentUserMarkedMessageUnread {
            return
        }
        throttler.execute { [weak self] in
            self?.channelController.markRead()
            // We keep `firstUnreadMessageId` value set which keeps showing the new messages header in the channel view
        }
    }
    
    private func refreshMessageListIfNeeded() {
        let count = messages.count
        if count > lastRefreshThreshold {
            lastRefreshThreshold = lastRefreshThreshold + refreshThreshold
            listId = UUID().uuidString
        }
    }
    
    private func checkReadIndicators(for channel: EntityChange<ChatChannel>) {
        switch channel {
        case let .update(chatChannel):
            let newReadsString = chatChannel.readsString
            if readsString == "" {
                readsString = newReadsString
                return
            }
            if readsString != newReadsString && isActive {
                messages = channelDataSource.messages
                readsString = newReadsString
            }
        default:
            log.debug("skip updating of messages in channel update")
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
    
    private func checkOnlineIndicator() {
        guard let channel else { return }
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
    
    private func checkHeaderType() {
        guard let channel = channel else {
            return
        }
        
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
        
        guard let channel = channelController.channel else { return }
        // Delay marking any messages as read until channel has loaded for the first time (slow internet + observer delay)
        guard !hasSetInitialCanMarkRead else { return }
        hasSetInitialCanMarkRead = true
        canMarkRead = true
        
        if channel.unreadCount.messages > 0 {
            if channelDataSource.firstUnreadMessageId != nil {
                firstUnreadMessageId = channelController.firstUnreadMessageId
                canMarkRead = false
            } else if channelController.lastReadMessageId != nil {
                lastReadMessageId = channelController.lastReadMessageId
                canMarkRead = false
            }
        }
    }

    private var shouldMarkThreadRead: Bool {
        guard UIApplication.shared.applicationState == .active else {
            return false
        }
        guard messageController?.replies.isEmpty == false else {
            return false
        }
        
        return channelDataSource.hasLoadedAllNextMessages
    }

    private func sendThreadReadEvent() {
        throttler.execute { [weak self] in
            self?.messageController?.markThreadRead()
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
    
    private func shouldAnimate(changes: [ListChange<ChatMessage>]) -> Bool {
        if !utils.messageListConfig.messageDisplayOptions.animateChanges {
            return false
        }
        if loadingMessagesAround || loadingPreviousMessages || loadingNextMessages {
            return false
        }
        if channelController.channel == nil {
            return false
        }
        
        var animateChanges = false
        for change in changes {
            switch change {
            case .insert,
                 .remove:
                return true
            case let .update(message, index: index):
                guard index.row >= messages.startIndex, index.row < messages.endIndex else { continue }
                let existingDisplayedMessage = messages[index.row]
                let animateReactions = message.reactionScoresId != existingDisplayedMessage.reactionScoresId
                    && utils.messageListConfig.messageDisplayOptions.shouldAnimateReactions
                if animateReactions,
                   message.messageId != existingDisplayedMessage.messageId
                   || message.type == .ephemeral
                   || !message.linkAttachments.isEmpty {
                    animateChanges = message.linkAttachments.isEmpty
                }
            case .move:
                continue
            }
        }
        
        return animateChanges
    }
    
    private func enableDateIndicator() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.disableDateIndicator = false
        }
    }
    
    private func checkTypingIndicator() {
        guard let channel = channel else { return }
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
        messageCachingUtils.clearCache()
        if messageController == nil {
            utils.channelControllerFactory.clearCurrentController()
            cleanupAudioPlayer()
            ImageCache.shared.trim(toCost: utils.messageListConfig.cacheSizeOnChatDismiss)
            if !channelDataSource.hasLoadedAllNextMessages {
                channelDataSource.loadFirstPage { _ in }
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

let firstMessageKey = "firstMessage"
let lastMessageKey = "lastMessage"

extension Notification.Name {
    /// A notification for notifying when an error occured and an alert banner should be shown at the top of the message list.
    static let showChannelAlertBannerNotification = Notification.Name("showChannelAlertBannerNotification")
    
    /// A notification for notifying when message dismissed a sheet.
    static let messageSheetHiddenNotification = Notification.Name("messageSheetHiddenNotification")
    
    /// A notification for notifying when message view displays a sheet.
    ///
    /// When a sheet is presented, the message cell is not reloaded.
    static let messageSheetShownNotification = Notification.Name("messageSheetShownNotification")
}
