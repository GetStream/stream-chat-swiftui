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
    private var isLoadingMoreScheduledMessages = false
    private var actionPendingSheetDismissal: (@MainActor () -> Void)?
    private var scheduledMessageToDelete: ScheduledMessage?

    /// The scheduled messages matching `searchText`, in the order of the controller: pending ones first, then failed ones,
    /// each by the time they are sent. Search covers the loaded pages.
    @Published public var scheduledMessages = [ScheduledMessage]()

    /// The text the scheduled messages are searched for: in the message text, the channel name and the names of the attachments.
    @Published public var searchText = "" {
        didSet { updateScheduledMessages() }
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

    /// A Boolean value indicating whether the snack bar shows the error icon, for an action that failed.
    @Published public private(set) var snackBarShowsErrorIcon = false

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

    /// Loads the first page of the scheduled messages. Call it again to retry after a failure.
    public func loadScheduledMessages() {
        viewState = listedScheduledMessages.isEmpty ? .loading : .loaded
        updateScheduledMessages()
        scheduledMessageListController.synchronize { [weak self] error in
            self?.didLoadFirstPage(error: error)
        }
    }

    /// Called when the scheduled message at the given index of `scheduledMessages` appears on screen.
    ///
    /// By default it loads the next page when the message is near the end of the list.
    public func didAppearScheduledMessage(at index: Int) {
        guard index >= scheduledMessages.count - 5,
              !isLoadingMoreScheduledMessages,
              !scheduledMessageListController.hasLoadedAllScheduledMessages else { return }
        isLoadingMoreScheduledMessages = true
        scheduledMessageListController.loadMoreScheduledMessages { [weak self] result in
            self?.isLoadingMoreScheduledMessages = false
            if case .failure = result {
                self?.showSnackBar(L10n.ScheduledMessages.Error.message, showsErrorIcon: true)
            }
        }
    }

    // MARK: - Actions

    /// Called when a scheduled message is tapped.
    ///
    /// By default it shows the sheet with the actions of the message, which come from
    /// `ScheduledMessagesConfig.supportedScheduledMessageListActions`. A message which is being sent can't be changed,
    /// so a snack bar says so.
    open func scheduledMessageTapped(_ scheduledMessage: ScheduledMessage) {
        if scheduledMessage.status == .sending {
            showSnackBar(L10n.ScheduledMessages.Snackbar.stillSending, showsSpinner: true)
        } else {
            selectedScheduledMessage = scheduledMessage
        }
    }

    /// Called when the sheet with the actions is dismissed. Runs the action that closed the sheet.
    public func actionsSheetDismissed() {
        let action = actionPendingSheetDismissal
        actionPendingSheetDismissal = nil
        action?()
    }

    /// Sends a scheduled message right away. The sheet with the actions is closed first, and a snack bar tells when it
    /// was sent.
    open func sendNow(_ scheduledMessage: ScheduledMessage) {
        performAfterSheetDismissal { [weak self] in
            self?.scheduledMessageListController.sendScheduledMessageNow(id: scheduledMessage.id) { error in
                switch error {
                case nil:
                    self?.showSnackBar(L10n.ScheduledMessages.Snackbar.sent)
                case is ClientError.ScheduledMessageAlreadySent, is ClientError.ScheduledMessageDoesNotExist:
                    // The message already left the list.
                    break
                case is ClientError.ConnectionError:
                    // It is sent once connected.
                    break
                case is ClientError.ScheduledMessageQuotesADeletedMessage:
                    self?.showSnackBar(L10n.ScheduledMessages.Snackbar.quoteDeleted, showsErrorIcon: true)
                default:
                    self?.showSnackBar(L10n.Alert.Error.title, showsErrorIcon: true)
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
        let recipient = scheduledMessageToDelete?.channelName(currentUserId: chatClient.currentUserId)
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
            if error is ClientError.ScheduledMessageIsBeingSent {
                self?.showSnackBar(L10n.ScheduledMessages.Snackbar.stillSending, showsSpinner: true)
            } else if error is ClientError.ScheduledMessageAlreadySent {
                self?.showSnackBar(L10n.ScheduledMessages.Snackbar.alreadySent)
            } else if !(error is ClientError.ScheduledMessageDoesNotExist) {
                // A message deleted on another device only leaves the list.
                self?.showSnackBar(L10n.Alert.Error.title, showsErrorIcon: true)
            }
        }
    }

    /// Opens the composer for editing a scheduled message. The sheet with the actions is closed first.
    ///
    /// A channel which is not stored locally is loaded first. When loading it fails, a snack bar shows the error.
    open func edit(_ scheduledMessage: ScheduledMessage) {
        performAfterSheetDismissal { [weak self] in
            self?.loadChannelIfNeeded(for: scheduledMessage.cid) { [weak self] controller in
                // The message may have been sent or deleted while the sheet was closing or the channel was loading.
                guard let self,
                      let scheduledMessage = self.current(scheduledMessage, in: self.scheduledMessageListController.scheduledMessages) else {
                    return
                }
                self.editedScheduledMessageChannelController = controller
                self.editedScheduledMessageThreadController = scheduledMessage.message.parentMessageId.map {
                    self.chatClient.messageController(cid: scheduledMessage.cid, messageId: $0)
                }
                self.editedScheduledMessage = scheduledMessage
            }
        }
    }

    func channel(of scheduledMessage: ScheduledMessage) -> ChatChannel? {
        utils.channelControllerFactory.makeChannelController(for: scheduledMessage.cid).channel
    }

    // A channel which is not stored locally allows it. Rescheduling loads the channel and shows an error when it doesn't
    // allow scheduling messages.
    func canReschedule(_ scheduledMessage: ScheduledMessage) -> Bool {
        channel(of: scheduledMessage).map(\.canScheduleMessage) ?? true
    }

    // Editing needs the capability that rescheduling needs. Another edit would replace the open one and lose its changes.
    func canEdit(_ scheduledMessage: ScheduledMessage) -> Bool {
        canReschedule(scheduledMessage) && editedScheduledMessage == nil
    }

    /// Opens the sheet for picking a new time for a scheduled message. The sheet with the actions is closed first.
    ///
    /// A channel which is not stored locally is loaded first. When loading it fails, a snack bar shows the error.
    open func reschedule(_ scheduledMessage: ScheduledMessage) {
        performAfterSheetDismissal { [weak self] in
            self?.loadChannelIfNeeded(for: scheduledMessage.cid) { [weak self] controller in
                // The message may have been sent or deleted while the sheet was closing or the channel was loading.
                guard let self,
                      let scheduledMessage = self.current(scheduledMessage, in: self.scheduledMessageListController.scheduledMessages) else {
                    return
                }
                guard scheduledMessage.status == .failed else {
                    self.rescheduleUsage = nil
                    self.rescheduledScheduledMessage = scheduledMessage
                    return
                }
                controller.scheduledMessagesUsage { [weak self] result in
                    self?.rescheduleUsage = try? result.get()
                    self?.rescheduledScheduledMessage = scheduledMessage
                }
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

    /// Checks a scheduled message at the given date with the checks the SDK runs on the device before rescheduling it,
    /// and completes with the error, if there is one.
    open func validateReschedule(
        of scheduledMessage: ScheduledMessage,
        at date: Date,
        completion: @escaping @MainActor (Error?) -> Void
    ) {
        utils.channelControllerFactory.makeChannelController(for: scheduledMessage.cid).validateForScheduling(
            scheduledAt: date,
            editing: scheduledMessage.id,
            completion: completion
        )
    }

    /// Reschedules the message of the reschedule sheet at the given date and closes the sheet, without waiting for the
    /// server.
    ///
    /// Picking the time the message already has closes the sheet without a change. A failed message is scheduled again
    /// as a new message. A message the server fails to reschedule is shown as failed in the list.
    open func rescheduleConfirmed(at date: Date) {
        guard let scheduledMessage = rescheduledScheduledMessage else { return }
        rescheduledScheduledMessage = nil
        let isSameTime = Calendar.current.isDate(date, equalTo: scheduledMessage.scheduledAt, toGranularity: .minute)
        if scheduledMessage.status != .failed, isSameTime {
            return
        }
        scheduledMessageListController.rescheduleMessage(id: scheduledMessage.id, scheduledAt: date) { [weak self] result in
            if case let .failure(error) = result, error is ClientError.ScheduledMessageAlreadySent {
                self?.showSnackBar(L10n.ScheduledMessages.Snackbar.alreadySent)
            }
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

    private func loadChannelIfNeeded(for cid: ChannelId, then action: @escaping @MainActor (ChatChannelController) -> Void) {
        let controller = utils.channelControllerFactory.makeChannelController(for: cid)
        guard controller.channel == nil else {
            action(controller)
            return
        }
        controller.synchronize { [weak self] error in
            // The actions sheet only knows whether a channel which is stored locally allows scheduling messages.
            guard error == nil, controller.channel?.canScheduleMessage == true else {
                self?.showSnackBar(L10n.Alert.Error.title, showsErrorIcon: true)
                return
            }
            action(controller)
        }
    }

    private func didLoadFirstPage(error: Error?) {
        viewState = error == nil ? .empty : .failed
        updateScheduledMessages()
        if error != nil, viewState == .loaded {
            showSnackBar(L10n.ScheduledMessages.Error.message, showsErrorIcon: true)
        }
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

    private func showSnackBar(_ text: String, showsSpinner: Bool = false, showsErrorIcon: Bool = false) {
        snackBarShowsSpinner = showsSpinner
        snackBarShowsErrorIcon = showsErrorIcon
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
        if deleteConfirmationShown, let scheduledMessageToDelete, !all.contains(where: { $0.id == scheduledMessageToDelete.id }) {
            deleteConfirmationShown = false
        }
    }

    // A message that left the list or is being sent closes the sheet it is open in.
    private func current(_ scheduledMessage: ScheduledMessage?, in all: [ScheduledMessage]) -> ScheduledMessage? {
        guard let scheduledMessage else { return nil }
        let current = all.first { $0.id == scheduledMessage.id }
        return current?.status == .sending ? nil : current
    }

    // The scheduled replies of the thread, or all the scheduled messages without a thread.
    private var listedScheduledMessages: [ScheduledMessage] {
        scheduledMessageListController.scheduledMessages.filter {
            parentMessageId == nil || $0.message.parentMessageId == parentMessageId
        }
    }

    private func updateScheduledMessages() {
        let all = listedScheduledMessages
        if !all.isEmpty {
            viewState = .loaded
        } else if viewState == .loaded {
            viewState = .empty
        }
        updateOpenScheduledMessages(from: all)
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        scheduledMessages = query.isEmpty ? all : all.filter { scheduledMessage in
            let channelName = scheduledMessage.channelName(currentUserId: chatClient.currentUserId)
            return ([scheduledMessage.message.text, channelName] + scheduledMessage.attachmentNames)
                .contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }
}
