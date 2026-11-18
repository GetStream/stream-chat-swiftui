//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import UIKit

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
    @Injected(\.utils) private var utils

    private let scheduledMessageListController: ScheduledMessageListController
    private let parentMessageId: MessageId?
    private var hasStartedLoading = false
    private var actionPendingSheetDismissal: (@MainActor () -> Void)?
    private var scheduledMessageToDelete: ScheduledMessage?

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

    /// The scheduled message whose actions are shown in a sheet.
    ///
    /// It is kept up to date with the list, and cleared when the message leaves the list or starts sending.
    @Published public var selectedScheduledMessage: ScheduledMessage?

    /// The scheduled message whose time is changed in the reschedule sheet.
    ///
    /// It is kept up to date with the list, and cleared when the message leaves the list or starts sending, which closes
    /// the sheet.
    @Published public var rescheduledScheduledMessage: ScheduledMessage?

    /// The scheduled message which is edited in the composer under the list.
    ///
    /// The composer watches the message, and clears it when the edit ends.
    @Published public var editedScheduledMessage: ScheduledMessage?

    /// The controller of the channel of `editedScheduledMessage`, which the composer uses.
    public private(set) var editedScheduledMessageChannelController: ChatChannelController?

    /// The controller of the thread of `editedScheduledMessage`, when it is a reply.
    public private(set) var editedScheduledMessageThreadController: ChatMessageController?

    /// How many scheduled messages the current user has, shown in the reschedule sheet of a failed message, because
    /// rescheduling it adds a pending message. `nil` for other messages.
    @Published public private(set) var rescheduleUsage: ScheduledMessagesUsage?

    /// A Boolean value indicating whether the confirmation for deleting a scheduled message is shown.
    @Published public var deleteConfirmationShown = false

    /// The text of the snack bar, which tells the outcome of an action when the list does not show it.
    @Published public var snackBarText: String?

    /// A Boolean value indicating whether the snack bar shows a spinner, for a message which is still sending.
    @Published public private(set) var snackBarShowsSpinner = false

    /// Creates a view model for the `ScheduledMessageListView`.
    ///
    /// - Parameters:
    ///   - scheduledMessageListController: A controller providing the scheduled messages. Its query decides
    ///   which ones are listed, for example the ones of a single channel.
    ///   - parentMessageId: The thread whose scheduled replies are listed. All the scheduled messages of the
    ///   controller are listed when `nil`.
    public init(scheduledMessageListController: ScheduledMessageListController, parentMessageId: MessageId? = nil) {
        self.scheduledMessageListController = scheduledMessageListController
        self.parentMessageId = parentMessageId
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

    // MARK: - Actions

    /// Called when a scheduled message is tapped.
    ///
    /// By default it shows the sheet with the actions of the message, which come from
    /// `ScheduledMessagesConfig.supportedScheduledMessageListActions`. A message which is being sent can't be changed,
    /// so a snack bar says so, and a message whose attachments are uploading does nothing.
    open func scheduledMessageTapped(_ scheduledMessage: ScheduledMessage) {
        if scheduledMessage.status == .sending {
            showSnackBar(L10n.ScheduledMessages.Snackbar.stillSending, showsSpinner: true)
        } else if !scheduledMessage.isUploadingAttachments {
            selectedScheduledMessage = scheduledMessage
        }
    }

    /// Called when the sheet with the actions is dismissed. Runs the action that closed the sheet.
    public func actionsSheetDismissed() {
        let action = actionPendingSheetDismissal
        actionPendingSheetDismissal = nil
        action?()
    }

    /// Sends a scheduled message right away. The sheet with the actions is closed first.
    open func sendNow(_ scheduledMessage: ScheduledMessage) {
        performAfterSheetDismissal { [weak self] in
            self?.scheduledMessageListController.sendScheduledMessageNow(id: scheduledMessage.id) { error in
                switch error {
                case nil, is ClientError.ScheduledMessageDoesNotExist:
                    // The message is sent, or already left the list.
                    break
                case is ClientError.ScheduledMessageQuotesADeletedMessage:
                    self?.showSnackBar(L10n.ScheduledMessages.Item.quoteDeleted)
                default:
                    self?.showSnackBar(L10n.Alert.Error.title)
                }
            }
        }
    }

    /// Asks for confirmation to delete a scheduled message. The sheet with the actions is closed first.
    ///
    /// The message is deleted by `deleteConfirmed()`.
    open func delete(_ scheduledMessage: ScheduledMessage) {
        performAfterSheetDismissal { [weak self] in
            self?.scheduledMessageToDelete = scheduledMessage
            self?.deleteConfirmationShown = true
        }
    }

    /// The confirmation shown before a scheduled message is deleted.
    open var deleteConfirmation: ConfirmationPopup {
        let recipient = scheduledMessageToDelete.map {
            $0.channelName(in: channels[$0.cid], currentUserId: chatClient.currentUserId)
        }
        return ConfirmationPopup(
            title: L10n.ScheduledMessages.DeleteConfirmation.title,
            message: L10n.ScheduledMessages.DeleteConfirmation.message(recipient ?? ""),
            buttonTitle: L10n.Alert.Actions.delete
        )
    }

    /// Called when deleting a scheduled message is confirmed. Deletes the message, so it is never sent.
    open func deleteConfirmed() {
        guard let scheduledMessage = scheduledMessageToDelete else { return }
        scheduledMessageListController.deleteScheduledMessage(id: scheduledMessage.id) { [weak self] error in
            guard let error else { return }
            if ScheduledMessageFailure.ServerRejection.Reason(error: error) == .scheduledMessageSending {
                self?.showSnackBar(L10n.ScheduledMessages.Snackbar.stillSending, showsSpinner: true)
            } else if error is ClientError.ScheduledMessageDoesNotExist {
                // The server no longer has it. A failed message was never sent, so there is nothing to tell.
                if scheduledMessage.status != .failed {
                    self?.showSnackBar(L10n.ScheduledMessages.Snackbar.alreadySent)
                }
            } else {
                self?.showSnackBar(L10n.Alert.Error.title)
            }
        }
    }

    /// A Boolean value indicating whether a scheduled message can be edited. The composer needs the config of the
    /// channel, so its channel has to be stored locally.
    open func canEdit(_ scheduledMessage: ScheduledMessage) -> Bool {
        channels[scheduledMessage.cid] != nil
    }

    /// Opens the composer for editing a scheduled message. The sheet with the actions is closed first.
    open func edit(_ scheduledMessage: ScheduledMessage) {
        performAfterSheetDismissal { [weak self] in
            guard let self else { return }
            let cid = scheduledMessage.cid
            editedScheduledMessageChannelController = chatClient.channelController(for: cid)
            editedScheduledMessageThreadController = scheduledMessage.message.parentMessageId.map {
                chatClient.messageController(cid: cid, messageId: $0)
            }
            editedScheduledMessage = scheduledMessage
        }
    }

    /// A Boolean value indicating whether a scheduled message can be rescheduled. The reschedule sheet needs the config
    /// of the channel, so its channel has to be stored locally.
    open func canReschedule(_ scheduledMessage: ScheduledMessage) -> Bool {
        channels[scheduledMessage.cid] != nil
    }

    /// Opens the sheet for picking a new time for a scheduled message. The sheet with the actions is closed first.
    open func reschedule(_ scheduledMessage: ScheduledMessage) {
        performAfterSheetDismissal { [weak self] in
            guard let self else { return }
            guard scheduledMessage.status == .failed else {
                rescheduleUsage = nil
                rescheduledScheduledMessage = scheduledMessage
                return
            }
            chatClient.channelController(for: scheduledMessage.cid).scheduledMessagesUsage { [weak self] result in
                self?.rescheduleUsage = try? result.get()
                self?.rescheduledScheduledMessage = scheduledMessage
            }
        }
    }

    /// The preview of the message in the reschedule sheet: when it is scheduled for, and its text or attachments.
    open func reschedulePreview(for scheduledMessage: ScheduledMessage) -> ScheduleMessagePreview {
        let resolver = MessageAttachmentPreviewResolver(message: scheduledMessage.message)
        let text = scheduledMessage.message.text
        let date = utils.scheduledMessagesConfig.dateFormatter.format(scheduledMessage.scheduledAt)
        return ScheduleMessagePreview(
            title: L10n.Composer.ScheduledMessagesBanner.scheduledFor(date),
            subtitle: text.isEmpty ? resolver.previewDescription ?? "" : text,
            icon: resolver.previewIcon,
            thumbnail: resolver.previewThumbnail
        )
    }

    /// Reschedules the message of the reschedule sheet at the given date, and closes the sheet when it succeeds.
    ///
    /// Picking the time the message already has closes the sheet without a change. A failed message is scheduled again
    /// as a new message.
    open func rescheduleConfirmed(at date: Date, completion: @escaping @MainActor (Error?) -> Void) {
        guard let scheduledMessage = rescheduledScheduledMessage else {
            completion(nil)
            return
        }
        let isSameTime = Calendar.current.isDate(date, equalTo: scheduledMessage.scheduledAt, toGranularity: .minute)
        if scheduledMessage.status != .failed, isSameTime {
            rescheduledScheduledMessage = nil
            completion(nil)
            return
        }
        scheduledMessageListController.rescheduleMessage(id: scheduledMessage.id, scheduledAt: date) { [weak self] result in
            if case let .failure(error) = result {
                completion(error)
                return
            }
            self?.rescheduledScheduledMessage = nil
            completion(nil)
        }
    }

    /// Copies the text of a scheduled message to the pasteboard. The sheet with the actions is closed first.
    open func copyText(of scheduledMessage: ScheduledMessage) {
        performAfterSheetDismissal {
            UIPasteboard.general.string = scheduledMessage.message.text
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

    // Alerts and sheets opened by an action would be dropped while the sheet is still being dismissed.
    private func performAfterSheetDismissal(_ action: @escaping @MainActor () -> Void) {
        guard selectedScheduledMessage != nil else {
            action()
            return
        }
        actionPendingSheetDismissal = action
        selectedScheduledMessage = nil
    }

    private func showSnackBar(_ text: String, showsSpinner: Bool = false) {
        snackBarShowsSpinner = showsSpinner
        snackBarText = text
    }

    private func updateOpenScheduledMessages(from all: [ScheduledMessage]) {
        let selected = current(selectedScheduledMessage, in: all)
        if selected !== selectedScheduledMessage {
            selectedScheduledMessage = selected
        }
        let rescheduled = current(rescheduledScheduledMessage, in: all)
        if rescheduled !== rescheduledScheduledMessage {
            rescheduledScheduledMessage = rescheduled
        }
    }

    // A message that left the list or can't be changed right now closes the sheet it is open in.
    private func current(_ scheduledMessage: ScheduledMessage?, in all: [ScheduledMessage]) -> ScheduledMessage? {
        guard let scheduledMessage else { return nil }
        let current = all.first { $0.id == scheduledMessage.id }
        return current?.isInProgress == false ? current : nil
    }

    private func updateScheduledMessages(readingChannels: Bool = true) {
        // The server returns pending messages before failed ones, so the rows of a first load would move around
        // while its pages arrive. They are shown when every page is loaded.
        guard viewState != .loading else { return }
        let all = scheduledMessageListController.scheduledMessages
            .filter { parentMessageId == nil || $0.message.parentMessageId == parentMessageId }
            .sorted { ($0.scheduledAt, $0.message.text, $0.id) < ($1.scheduledAt, $1.message.text, $1.id) }
        if !all.isEmpty {
            viewState = .loaded
        } else if viewState == .loaded {
            viewState = .empty
        }
        if readingChannels {
            readLocalChannels(Set(all.map(\.cid)))
        }
        updateOpenScheduledMessages(from: all)
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
