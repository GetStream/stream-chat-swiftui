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
            guard showScrollToLatestButton == true, let currentDate = currentDate else {
                currentDateString = nil
                return
            }
            currentDateString = messageListDateOverlay.string(from: currentDate)
        }
    }

    private var isActive = true {
        didSet {
            if oldValue == false && isActive == true {
                messages = channelDataSource.messages
            }
        }
    }
    
    private let messageListDateOverlay: DateFormatter = {
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate("MMMdd")
        df.locale = .autoupdatingCurrent
        return df
    }()
    
    private lazy var messagesDateFormatter = utils.dateFormatter
    
    @Atomic private var loadingPreviousMessages: Bool = false
    @Atomic private var lastMessageRead: String?
    
    public var channelController: ChatChannelController
    public var messageController: ChatMessageController?
    
    @Published public var scrolledId: String?
    @Published public var listId = UUID().uuidString

    @Published public var showScrollToLatestButton = false {
        didSet {
            isActive = !showScrollToLatestButton
        }
    }

    @Published public var currentDateString: String?
    @Published public var messages = LazyCachedMapCollection<ChatMessage>() {
        didSet {
            var temp = [String: [String]]()
            for (index, message) in messages.enumerated() {
                let dateString = messagesDateFormatter.string(from: message.createdAt)
                let prefix = message.author.id
                let key = "\(prefix)-\(dateString)"
                if temp[key] == nil {
                    temp[key] = [message.id]
                } else {
                    // check if the previous message is not sent by the same user.
                    let previousIndex = index - 1
                    if previousIndex >= 0 {
                        let previous = messages[previousIndex]
                        
                        let shouldAddKey = message.author.id != previous.author.id
                        if shouldAddKey {
                            temp[key]?.append(message.id)
                        }
                    }
                }
            }
            messagesGroupingInfo = temp
        }
    }

    @Published public var messagesGroupingInfo = [String: [String]]()
    @Published public var currentSnapshot: UIImage? {
        didSet {
            withAnimation {
                reactionsShown = currentSnapshot != nil
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

    @Published public var quotedMessage: ChatMessage?
    @Published public var editedMessage: ChatMessage?
    @Published public var channelHeaderType: ChannelHeaderType = .regular
    
    public var channel: ChatChannel {
        channelController.channel!
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
        channelController.synchronize()
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
        
        checkHeaderType()
    }
    
    @objc
    private func didReceiveMemoryWarning() {
        Nuke.ImageCache.shared.removeAll()
    }
    
    public func scrollToLastMessage() {
        if scrolledId != messages.first?.messageId {
            scrolledId = messages.first?.messageId
        }
    }
    
    public func handleMessageAppear(index: Int) {
        let message = messages[index]
        checkForNewMessages(index: index)
        save(lastDate: message.createdAt)
        if index == 0 {
            maybeSendReadEvent(for: message)
        }
    }
    
    func dataSource(
        channelDataSource: ChannelDataSource,
        didUpdateMessages messages: LazyCachedMapCollection<ChatMessage>
    ) {
        if !isActive {
            return
        }
        
        if let message = messageController?.message {
            var array = Array(messages)
            array.append(message)
            self.messages = LazyCachedMapCollection(source: array, map: { $0 })
        } else {
            self.messages = messages
        }
        
        let count = messages.count
        if count > lastRefreshThreshold {
            lastRefreshThreshold = lastRefreshThreshold + refreshThreshold
            listId = UUID().uuidString
        }
        
        if !showScrollToLatestButton && scrolledId == nil {
            scrollToLastMessage()
        }
    }
    
    func dataSource(
        channelDataSource: ChannelDataSource,
        didUpdateChannel channel: EntityChange<ChatChannel>,
        channelController: ChatChannelController
    ) {
        if isActive {
            messages = channelController.messages
        }
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
        reactionsShown = false
        isActive = true
    }
    
    public func onViewDissappear() {
        isActive = false
    }
    
    // MARK: - private
    
    private func checkForNewMessages(index: Int) {
        if index < messages.count - 20 {
            return
        }

        if _loadingPreviousMessages.compareAndSwap(old: false, new: true) {
            channelDataSource.loadPreviousMessages(
                before: nil,
                limit: refreshThreshold,
                completion: { [weak self] _ in
                    guard let self = self else { return }
                    self.loadingPreviousMessages = false
                    self.messages = self.channelDataSource.messages
                }
            )
        }
    }
    
    private func save(lastDate: Date) {
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
    
    private func checkHeaderType() {
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
}

extension ChatMessage: Identifiable {
    var messageId: String {
        let statesId = uploadingStatesId

        if statesId.isEmpty {
            if !reactionScores.isEmpty {
                return baseId + reactionScoresId
            } else {
                return baseId
            }
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
            return ""
        }
        
        let strings = states.map { "\($0)" }
        let combined = strings.joined(separator: "-")
        return combined
    }
    
    var reactionScoresId: String {
        var output = ""
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

/// The type of header shown in the chat channel screen.
public enum ChannelHeaderType {
    /// The regular header showing the channel name and members.
    case regular
    /// The header shown in message threads.
    case messageThread
    /// The header shown when someone is typing.
    case typingIndicator
}
