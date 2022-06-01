//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import Combine
import Nuke
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
    private var timer: Timer?
    private var currentDate: Date? {
        didSet {
            handleDateChange()
        }
    }

    private var isActive = true
    private var readsString = ""
    
    private let messageListDateOverlay: DateFormatter = DateFormatter.messageListDateOverlay
    
    private lazy var messagesDateFormatter = utils.dateFormatter
    private lazy var messageCachingUtils = utils.messageCachingUtils
    
    private var loadingPreviousMessages: Bool = false
    private var lastMessageRead: String?
    private var disableDateIndicator = false
    private var channelName = ""
    
    public var channelController: ChatChannelController
    public var messageController: ChatMessageController?
    
    @Published public var scrolledId: String?
    @Published public var listId = UUID().uuidString

    @Published public var showScrollToLatestButton = false

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
                reactionsShown = currentSnapshot != nil && utils.messageListConfig.messagePopoverEnabled
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

    @Published public var quotedMessage: ChatMessage? {
        didSet {
            if oldValue != nil && quotedMessage == nil {
                disableDateIndicator = true
            }
        }
    }

    @Published public var editedMessage: ChatMessage?
    @Published public var channelHeaderType: ChannelHeaderType = .regular
    
    public var channel: ChatChannel? {
        channelController.channel
    }
    
    public var isMessageThread: Bool {
        messageController != nil
    }
            
    public init(
        channelController: ChatChannelController,
        messageController: ChatMessageController? = nil,
        scrollToMessage: ChatMessage? = nil
    ) {
        self.channelController = channelController
        if InjectedValues[\.utils].shouldSyncChannelControllerOnAppear(channelController) {
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.scrolledId = scrollToMessage?.messageId
        }
              
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
        
        channelName = channel?.name ?? ""
        checkHeaderType()
    }
    
    @objc
    private func didReceiveMemoryWarning() {
        Nuke.ImageCache.shared.removeAll()
        messageCachingUtils.clearCache()
    }
    
    public func scrollToLastMessage() {
        if scrolledId != nil {
            scrolledId = nil
        }
        scrolledId = messages.first?.messageId
    }
    
    open func handleMessageAppear(index: Int) {
        if index >= messages.count {
            return
        }
        
        let message = messages[index]
        checkForNewMessages(index: index)
        if utils.messageListConfig.dateIndicatorPlacement == .overlay {
            save(lastDate: message.createdAt)
        }
        if index == 0 {
            maybeSendReadEvent(for: message)
        }
    }
    
    func dataSource(
        channelDataSource: ChannelDataSource,
        didUpdateMessages messages: LazyCachedMapCollection<ChatMessage>,
        changes: [ListChange<ChatMessage>]
    ) {
        if !isActive {
            return
        }
        
        if let message = messageController?.message {
            var array = Array(messages)
            array.append(message)
            self.messages = LazyCachedMapCollection(source: array, map: { $0 })
        } else {
            let animationState = shouldAnimate(changes: changes)
            if animationState == .animated {
                withAnimation {
                    self.messages = messages
                }
            } else if animationState == .notAnimated {
                self.messages = messages
            }
        }
        
        maybeRefreshMessageList()
        
        if !showScrollToLatestButton && scrolledId == nil {
            scrollToLastMessage()
        }
    }
    
    func dataSource(
        channelDataSource: ChannelDataSource,
        didUpdateChannel channel: EntityChange<ChatChannel>,
        channelController: ChatChannelController
    ) {
        checkReadIndicators(for: channel)
        checkHeaderType()
    }

    public func showReactionOverlay() {
        guard let view: UIView = topVC()?.view else {
            currentSnapshot = images.snapshot
            return
        }
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        currentSnapshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    public func messageActionExecuted(_ messageActionInfo: MessageActionInfo) {
        utils.messageActionsResolver.resolveMessageAction(
            info: messageActionInfo,
            viewModel: self
        )
    }
    
    public func onViewAppear() {
        isActive = true
        messages = channelDataSource.messages
        checkNameChange()
    }
    
    public func onViewDissappear() {
        isActive = false
    }
    
    // MARK: - private
    
    private func checkForNewMessages(index: Int) {
        if index < channelDataSource.messages.count - 25 {
            return
        }

        if !loadingPreviousMessages {
            loadingPreviousMessages = true
            channelDataSource.loadPreviousMessages(
                before: nil,
                limit: utils.messageListConfig.pageSize,
                completion: { [weak self] _ in
                    guard let self = self else { return }
                    self.loadingPreviousMessages = false
                }
            )
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
    
    private func maybeSendReadEvent(for message: ChatMessage) {
        if message.id != lastMessageRead {
            lastMessageRead = message.id
            channelController.markRead()
        }
    }
    
    private func maybeRefreshMessageList() {
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
            // Toolbar is not updated unless there's a state change.
            // Therefore, we manually need to update the state for a short period of time.
            let headerType = channelHeaderType
            channelHeaderType = .typingIndicator
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.channelHeaderType = headerType
            }
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
        } else if !typingUsers.isEmpty {
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
    
    private func groupMessages() {
        var temp = [String: [String]]()
        let primary = "primary"
        for (index, message) in messages.enumerated() {
            let date = message.createdAt
            if index == 0 {
                temp[message.id] = [primary]
                continue
            }

            let previous = index - 1
            let previousMessage = messages[previous]
            let currentAuthorId = messageCachingUtils.authorId(for: message)
            let previousAuthorId = messageCachingUtils.authorId(for: previousMessage)

            if currentAuthorId != previousAuthorId {
                temp[message.id] = [primary]
            }

            if previousMessage.type == .error
                || previousMessage.type == .ephemeral
                || previousMessage.type == .system {
                temp[message.id] = [primary]
                continue
            }

            let delay = previousMessage.createdAt.timeIntervalSince(date)

            if delay > utils.messageListConfig.maxTimeIntervalBetweenMessagesInGroup {
                temp[message.id] = [primary]
            }
        }
        
        messagesGroupingInfo = temp
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
    
    private func shouldAnimate(changes: [ListChange<ChatMessage>]) -> AnimationChange {
        if !utils.messageListConfig.messageDisplayOptions.animateChanges {
            return .notAnimated
        }
        
        var skipChanges = true
        var animateChanges = false
        for change in changes {
            switch change {
            case .insert(_, index: _),
                 .remove(_, index: _):
                return .animated
            case let .update(message, index: index):
                if index.row < messages.count,
                   message.messageId != messages[index.row].messageId
                   || message.type == .ephemeral {
                    skipChanges = false
                    if index.row < messages.count && message.reactionScoresId != messages[index.row].reactionScoresId {
                        animateChanges = message.linkAttachments.isEmpty
                    }
                }
            default:
                skipChanges = false
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
    
    deinit {
        messageCachingUtils.clearCache()
    }
}

extension ChatMessage: Identifiable {
    
    public var scrollMessageId: String {
        messageId
    }
    
    var messageId: String {
        var statesId = "empty"
        if localState != nil {
            statesId = uploadingStatesId
        }
        return baseId + statesId + reactionScoresId + repliesCountId + "\(updatedAt)" + pinStateId
    }
    
    private var baseId: String {
        isDeleted ? "\(id)-deleted" : id
    }
    
    private var pinStateId: String {
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
                return "empty"
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
