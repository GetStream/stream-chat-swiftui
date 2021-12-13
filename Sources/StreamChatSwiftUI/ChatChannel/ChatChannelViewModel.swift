//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Combine
import Nuke
import StreamChat
import SwiftUI

/// View model for the `ChatChannelView`.
public class ChatChannelViewModel: ObservableObject, MessagesDataSource {
    
    @Injected(\.chatClient) private var chatClient
    @Injected(\.utils) private var utils
    
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

    private var isActive = true
    
    private let messageListDateOverlay: DateFormatter = {
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate("MMMdd")
        df.locale = .autoupdatingCurrent
        return df
    }()
    
    private lazy var messagesDateFormatter = utils.dateFormatter
    
    @Atomic private var loadingPreviousMessages: Bool = false
    @Atomic private var lastMessageRead: String?
    
    var channelController: ChatChannelController
    var messageController: ChatMessageController?
    
    @Published var scrolledId: String?
    @Published var listId = UUID().uuidString

    @Published var showScrollToLatestButton = false
    @Published var currentDateString: String?
    @Published var messages = LazyCachedMapCollection<ChatMessage>() {
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

    @Published var messagesGroupingInfo = [String: [String]]()
    @Published var currentSnapshot: UIImage? {
        didSet {
            withAnimation {
                reactionsShown = currentSnapshot != nil
            }
        }
    }

    @Published var reactionsShown = false
    
    var channel: ChatChannel {
        channelController.channel!
    }
    
    var isMessageThread: Bool {
        messageController != nil
    }
            
    public init(
        channelController: ChatChannelController,
        messageController: ChatMessageController? = nil
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
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }
    
    @objc
    private func didReceiveMemoryWarning() {
        Nuke.ImageCache.shared.removeAll()
    }
    
    func scrollToLastMessage() {
        if scrolledId != messages.first?.messageId {
            scrolledId = messages.first?.messageId
        }
    }
    
    func handleMessageAppear(index: Int) {
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
        
        if !showScrollToLatestButton {
            scrollToLastMessage()
        }
    }
    
    func dataSource(
        channelDataSource: ChannelDataSource,
        didUpdateChannel channel: EntityChange<ChatChannel>,
        channelController: ChatChannelController
    ) {
        messages = channelController.messages
    }

    func showReactionOverlay() {
        guard let view: UIView = topVC()?.view else {
            currentSnapshot = UIImage(systemName: "photo")
            return
        }
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        currentSnapshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    func onViewAppear() {
        reactionsShown = false
        isActive = true
        messages = channelDataSource.messages
    }
    
    func onViewDissappear() {
        isActive = false
    }
    
    // MARK: - private
    
    private func checkForNewMessages(index: Int) {
        if index < channelDataSource.messages.count - 25 {
            return
        }

        if _loadingPreviousMessages.compareAndSwap(old: false, new: true) {
            channelDataSource.loadPreviousMessages(
                before: nil,
                limit: refreshThreshold,
                completion: { [weak self] _ in
                    guard let self = self else { return }
                    self.loadingPreviousMessages = false
                }
            )
        }
    }
    
    private func topVC() -> UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
        
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            return topController
        }
        
        return nil
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
        
        return baseId + statesId + reactionScoresId + repliesCountId
    }
    
    private var baseId: String {
        isDeleted ? "\(id)-deleted" : id
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
