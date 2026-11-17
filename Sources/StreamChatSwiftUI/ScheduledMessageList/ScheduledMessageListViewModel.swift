//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

/// The view model of the `ScheduledMessageListView`.
@MainActor open class ScheduledMessageListViewModel: ObservableObject, ScheduledMessageListControllerDelegate {
    /// What the scheduled message list shows.
    public enum ViewState: Equatable, Sendable {
        /// The first load is in progress, with no scheduled messages to show yet.
        case loading
        /// There are scheduled messages. `scheduledMessages` is still empty when the search text matches none of them.
        case loaded
        /// There are no scheduled messages.
        case empty
        /// Loading failed and there are no scheduled messages to show.
        case failed
    }

    @Injected(\.chatClient) private var chatClient

    private let scheduledMessageListController: ScheduledMessageListController
    private var hasStartedLoading = false

    /// The scheduled messages matching `searchText`, sorted by the date they are sent.
    @Published public var scheduledMessages = [ScheduledMessage]()

    /// The channels of the scheduled messages, which give the rows their channel name and avatar.
    ///
    /// A channel is missing when it is not stored locally.
    @Published public var channels = [ChannelId: ChatChannel]()

    /// The text the scheduled messages are searched for: in the message text, the channel name and the names of the attachments.
    @Published public var searchText = "" {
        didSet { updateScheduledMessages(readingChannels: false) }
    }

    /// What the list shows: the loading view, the scheduled messages, the empty view or the error view.
    @Published public var viewState = ViewState.loading

    /// Creates a view model for the `ScheduledMessageListView`.
    ///
    /// - Parameter scheduledMessageListController: A controller providing the scheduled messages. Its query decides
    /// which ones are listed, for example the ones of a single channel.
    public init(scheduledMessageListController: ScheduledMessageListController) {
        self.scheduledMessageListController = scheduledMessageListController
    }

    /// Called when the view appears on screen.
    ///
    /// By default it loads the scheduled messages and starts observing them, the first time it is called.
    public func viewDidAppear() {
        guard !hasStartedLoading else { return }
        hasStartedLoading = true
        scheduledMessageListController.delegate = self
        loadScheduledMessages()
    }

    /// Loads all the scheduled messages, page by page. Call it again to retry after a failure.
    public func loadScheduledMessages() {
        viewState = scheduledMessageListController.scheduledMessages.isEmpty ? .loading : .loaded
        updateScheduledMessages()
        scheduledMessageListController.synchronize { [weak self] error in
            self?.didLoadPage(error: error)
        }
    }

    // MARK: - ScheduledMessageListControllerDelegate

    public func controller(
        _ controller: ScheduledMessageListController,
        didChangeScheduledMessages scheduledMessages: [ScheduledMessage]
    ) {
        updateScheduledMessages()
    }

    // MARK: - Private

    private func didLoadPage(error: Error?) {
        if error == nil, !scheduledMessageListController.hasLoadedAllScheduledMessages {
            scheduledMessageListController.loadMoreScheduledMessages { [weak self] result in
                if case let .failure(error) = result {
                    self?.didLoadPage(error: error)
                } else {
                    self?.didLoadPage(error: nil)
                }
            }
            return
        }
        viewState = error == nil ? .empty : .failed
        updateScheduledMessages()
    }

    private func updateScheduledMessages(readingChannels: Bool = true) {
        // The server returns pending messages before failed ones, so the rows of a first load would move around
        // while its pages arrive. They are shown when every page is loaded.
        guard viewState != .loading else { return }
        let all = scheduledMessageListController.scheduledMessages.sorted {
            ($0.scheduledAt, $0.message.text, $0.id) < ($1.scheduledAt, $1.message.text, $1.id)
        }
        if !all.isEmpty {
            viewState = .loaded
        } else if viewState == .loaded {
            viewState = .empty
        }
        if readingChannels {
            readLocalChannels(Set(all.map(\.cid)))
        }
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        scheduledMessages = query.isEmpty ? all : all.filter { scheduledMessage in
            let channelName = scheduledMessage.channelName(
                in: channels[scheduledMessage.cid],
                currentUserId: chatClient.currentUserId
            )
            return ([scheduledMessage.message.text, channelName] + scheduledMessage.attachmentNames)
                .contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }

    // TODO: [CHA-6892] Use the members of the scheduled message's channel when the backend sends them.
    private func readLocalChannels(_ ids: Set<ChannelId>) {
        let localChannels = ids.subtracting(channels.keys)
            .compactMap { scheduledMessageListController.dataStore.channel(cid: $0) }
        guard !localChannels.isEmpty else { return }
        channels.merge(localChannels.map { ($0.cid, $0) }) { current, _ in current }
    }
}
