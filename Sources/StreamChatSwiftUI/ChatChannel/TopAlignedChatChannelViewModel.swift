//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Combine
import StreamChat
import SwiftUI

/// View model backing the non-inverted, top-aligned message list.
///
/// Unlike ``ChatChannelViewModel`` (which renders newest-first in an inverted
/// list), this model drives a `.bottomToTop` controller so the messages are
/// naturally oldest→newest and can be rendered in a non-inverted `LazyVStack`.
/// A short conversation therefore sits at the top for free, while a long one
/// starts at the newest message and scrolls like a regular chat.
@MainActor
public class TopAlignedChatChannelViewModel: ObservableObject, MessagesDataSource {
    @Injected(\.utils) private var utils
    @Injected(\.chatClient) private var chatClient

    /// Messages ordered oldest → newest (the natural non-inverted order).
    @Published public private(set) var messages = [ChatMessage]()
    @Published public private(set) var messagesGroupingInfo = [String: [String]]()
    @Published public private(set) var channel: ChatChannel?
    @Published public var scrolledId: String?
    @Published public var quotedMessage: ChatMessage?
    @Published public var editedMessage: ChatMessage?
    @Published public var showScrollToLatestButton = false
    @Published public var firstUnreadMessageId: String?
    /// Incremented when the current user sends a message, so the list scrolls to
    /// the newest message.
    @Published public private(set) var scrollToNewestToken = 0
    @Published public private(set) var listId = UUID().uuidString

    public let channelController: ChatChannelController
    private let channelDataSource: ChannelDataSource

    private var loadingPreviousMessages = false
    private var loadingNextMessages = false
    private var lastMessageRead: String?

    private var maxTimeInterval: TimeInterval {
        utils.messageListConfig.maxTimeIntervalBetweenMessagesInGroup
    }

    public init(channelController: ChatChannelController) {
        // The passed controller renders newest-first; recreate a bottom-to-top one
        // for the same channel so the messages come oldest-first.
        let bottomToTopController: ChatChannelController
        if let cid = channelController.cid {
            bottomToTopController = InjectedValues[\.chatClient].channelController(
                for: cid,
                messageOrdering: .bottomToTop
            )
        } else {
            bottomToTopController = channelController
        }
        self.channelController = bottomToTopController
        channelDataSource = ChatChannelDataSource(controller: bottomToTopController)

        if utils.shouldSyncChannelControllerOnAppear(bottomToTopController) {
            bottomToTopController.synchronize()
        }
        channelDataSource.delegate = self
        messages = channelDataSource.messages
        channel = bottomToTopController.channel
        groupMessages()
    }

    // MARK: - MessagesDataSource

    func dataSource(
        channelDataSource: ChannelDataSource,
        didUpdateMessages messages: [ChatMessage],
        changes: [ListChange<ChatMessage>]
    ) {
        self.messages = messages
        groupMessages()
    }

    func dataSource(
        channelDataSource: ChannelDataSource,
        didUpdateChannel channel: EntityChange<ChatChannel>,
        channelController: ChatChannelController
    ) {
        self.channel = channelController.channel
    }

    // MARK: - Pagination

    /// Loads the previous (older) page of messages, which prepend at the top of
    /// the oldest-first list. Guarded so overlapping/complete loads are ignored.
    public func loadOlderIfNeeded() {
        guard !loadingPreviousMessages,
              !channelController.hasLoadedAllPreviousMessages else { return }
        loadingPreviousMessages = true
        channelDataSource.loadPreviousMessages(
            before: nil,
            limit: utils.messageListConfig.pageSize
        ) { [weak self] _ in
            self?.loadingPreviousMessages = false
        }
    }

    /// Loads the next (newer) page of messages when the list was opened around an
    /// older message and hasn't loaded up to the newest yet.
    public func loadNewerIfNeeded() {
        guard !loadingNextMessages,
              !channelController.hasLoadedAllNextMessages else { return }
        loadingNextMessages = true
        channelDataSource.loadNextMessages(limit: utils.messageListConfig.pageSize) { [weak self] _ in
            self?.loadingNextMessages = false
        }
    }

    public func scrollToLastMessage() {
        scrollToNewestToken += 1
    }

    /// Called by the composer right before a message is sent, so the list scrolls
    /// down to the newest message.
    public func messageSentTapped() {
        scrollToNewestToken += 1
    }

    public func jumpToMessage(messageId: String) -> Bool {
        // Milestone 1: jumping is handled by the list's scrollTo; always allow.
        messageId != scrolledId
    }

    // MARK: - Grouping

    /// Groups adjacent messages by author / time so the row can decide whether to
    /// show the sender header and the last-in-group info. The algorithm mirrors
    /// ``ChatChannelViewModel/groupMessages()`` but runs on the oldest-first array.
    private func groupMessages() {
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
            if message.author.id != previousMessage.author.id {
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

            let delay = date.timeIntervalSince(previousMessage.createdAt)
            if delay > maxTimeInterval {
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
}
