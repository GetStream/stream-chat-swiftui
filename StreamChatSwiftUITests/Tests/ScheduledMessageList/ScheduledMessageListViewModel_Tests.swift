//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import XCTest

@MainActor final class ScheduledMessageListViewModel_Tests: StreamChatTestCase {
    private var controller: ScheduledMessageListController_Mock!
    private var viewModel: ScheduledMessageListViewModel!

    override func setUp() {
        super.setUp()
        controller = .mock(client: chatClient)
        // A loaded state and mocked scheduled messages keep the controller away from the database.
        controller.state_mock = .localDataFetched
        controller.scheduledMessages_mock = []
        viewModel = ScheduledMessageListViewModel(scheduledMessageListController: controller)
    }

    override func tearDown() {
        viewModel = nil
        controller = nil
        super.tearDown()
    }

    func test_viewDidAppear_loadsAllPagesBeforeShowingTheScheduledMessages() {
        let later = ScheduledMessage.mock(id: "later", scheduledAt: Date(timeIntervalSince1970: 200))
        let earlier = ScheduledMessage.mock(id: "earlier", scheduledAt: Date(timeIntervalSince1970: 100))

        viewModel.viewDidAppear()
        controller.scheduledMessages_mock = [later]
        controller.synchronize_completion?(nil)

        XCTAssertEqual(viewModel.viewState, .loading)
        XCTAssertEqual(viewModel.scheduledMessages, [])
        XCTAssertEqual(controller.loadMoreScheduledMessages_callCount, 1)

        controller.scheduledMessages_mock = [later, earlier]
        controller.hasLoadedAllScheduledMessages_mock = true
        controller.loadMoreScheduledMessages_completion?(.success([earlier]))

        XCTAssertEqual(viewModel.viewState, .loaded)
        XCTAssertEqual(viewModel.scheduledMessages.map(\.id), ["earlier", "later"])
        XCTAssertEqual(controller.loadMoreScheduledMessages_callCount, 1)
    }

    func test_viewDidAppear_withAParentMessage_listsTheScheduledRepliesOfTheThread() {
        viewModel = ScheduledMessageListViewModel(scheduledMessageListController: controller, parentMessageId: "parent")
        controller.scheduledMessages_mock = [
            .mock(id: "channel"),
            .mock(id: "reply", message: .mock(parentMessageId: "parent")),
            .mock(id: "other-reply", message: .mock(parentMessageId: "other-parent"))
        ]
        controller.hasLoadedAllScheduledMessages_mock = true

        viewModel.viewDidAppear()
        controller.synchronize_completion?(nil)

        XCTAssertEqual(viewModel.viewState, .loaded)
        XCTAssertEqual(viewModel.scheduledMessages.map(\.id), ["reply"])
    }

    func test_viewDidAppear_withAParentMessage_whenTheThreadHasNoScheduledReplies_isEmpty() {
        viewModel = ScheduledMessageListViewModel(scheduledMessageListController: controller, parentMessageId: "parent")
        controller.scheduledMessages_mock = [.mock(id: "channel")]
        controller.hasLoadedAllScheduledMessages_mock = true

        viewModel.viewDidAppear()
        controller.synchronize_completion?(nil)

        XCTAssertEqual(viewModel.viewState, .empty)
        XCTAssertEqual(viewModel.scheduledMessages, [])
    }

    func test_viewDidAppear_whenCalledAgain_doesNotLoadAgain() {
        viewModel.viewDidAppear()
        viewModel.viewDidAppear()

        XCTAssertEqual(controller.synchronize_callCount, 1)
    }

    func test_loadScheduledMessages_afterAFailure_loadsAgain() {
        viewModel.viewDidAppear()
        controller.synchronize_completion?(ClientError())

        XCTAssertEqual(viewModel.viewState, .failed)

        viewModel.loadScheduledMessages()

        XCTAssertEqual(viewModel.viewState, .loading)
        XCTAssertEqual(controller.synchronize_callCount, 2)
    }

    func test_whenALaterPageFails_showsTheLoadedScheduledMessages() {
        viewModel.viewDidAppear()
        controller.scheduledMessages_mock = [.mock(id: "first")]
        controller.synchronize_completion?(nil)
        controller.loadMoreScheduledMessages_completion?(.failure(ClientError()))

        XCTAssertEqual(viewModel.viewState, .loaded)
        XCTAssertEqual(viewModel.scheduledMessages.map(\.id), ["first"])
    }

    // MARK: - Tapping a scheduled message

    func test_scheduledMessageTapped_selectsTheMessage() {
        let scheduledMessage = ScheduledMessage.mock(id: "scheduled")

        viewModel.scheduledMessageTapped(scheduledMessage)

        XCTAssertEqual(viewModel.selectedScheduledMessage?.id, "scheduled")
        XCTAssertNil(viewModel.snackBarText)
    }

    func test_scheduledMessageTapped_whenSending_showsTheStillSendingSnackBar() {
        viewModel.scheduledMessageTapped(.mock(status: .sending))

        XCTAssertNil(viewModel.selectedScheduledMessage)
        XCTAssertEqual(viewModel.snackBarText, L10n.ScheduledMessages.Snackbar.stillSending)
        XCTAssertTrue(viewModel.snackBarShowsSpinner)
    }

    func test_scheduledMessageTapped_whenUploadingAttachments_doesNothing() {
        let uploading = ScheduledMessage.mock(
            message: .mock(attachments: [
                ChatMessageImageAttachment.mock(id: .unique, localState: .uploading(progress: 0.4)).asAnyAttachment
            ]),
            status: .preparingToSchedule
        )

        viewModel.scheduledMessageTapped(uploading)

        XCTAssertNil(viewModel.selectedScheduledMessage)
        XCTAssertNil(viewModel.snackBarText)
    }

    func test_selectedScheduledMessage_whenTheMessageStartsSending_isCleared() {
        load([.mock(id: "scheduled")])
        viewModel.scheduledMessageTapped(viewModel.scheduledMessages[0])

        controller.scheduledMessages_mock = [.mock(id: "scheduled", status: .sending)]
        viewModel.controller(controller, didChangeScheduledMessages: [])

        XCTAssertNil(viewModel.selectedScheduledMessage)
    }

    func test_selectedScheduledMessage_whenTheMessageIsGone_isCleared() {
        load([.mock(id: "scheduled"), .mock(id: "other")])
        viewModel.scheduledMessageTapped(viewModel.scheduledMessages[0])

        controller.scheduledMessages_mock = [.mock(id: "other")]
        viewModel.controller(controller, didChangeScheduledMessages: [])

        XCTAssertNil(viewModel.selectedScheduledMessage)
    }

    func test_selectedScheduledMessage_whenTheMessageChanges_isReplaced() {
        load([.mock(id: "scheduled")])
        viewModel.scheduledMessageTapped(viewModel.scheduledMessages[0])

        controller.scheduledMessages_mock = [.mock(id: "scheduled", status: .failed)]
        viewModel.controller(controller, didChangeScheduledMessages: [])

        XCTAssertEqual(viewModel.selectedScheduledMessage?.status, .failed)
    }

    // MARK: - Actions

    func test_action_runsWhenTheSheetIsDismissed() {
        let scheduledMessage = ScheduledMessage.mock(id: "scheduled")
        viewModel.scheduledMessageTapped(scheduledMessage)

        viewModel.sendNow(scheduledMessage)

        XCTAssertNil(viewModel.selectedScheduledMessage)
        XCTAssertEqual(controller.sendScheduledMessageNow_callCount, 0)

        viewModel.actionsSheetDismissed()

        XCTAssertEqual(controller.sendScheduledMessageNow_callCount, 1)
    }

    func test_action_withoutASheet_runsRightAway() {
        viewModel.sendNow(.mock(id: "scheduled"))

        XCTAssertEqual(controller.sendScheduledMessageNow_id, "scheduled")
    }

    func test_actionsSheetDismissed_withoutAnAction_doesNothing() {
        viewModel.scheduledMessageTapped(.mock())
        viewModel.selectedScheduledMessage = nil

        viewModel.actionsSheetDismissed()

        XCTAssertEqual(controller.sendScheduledMessageNow_callCount, 0)
        XCTAssertEqual(controller.deleteScheduledMessage_callCount, 0)
        XCTAssertFalse(viewModel.deleteConfirmationShown)
    }

    // MARK: - Send now

    func test_sendNow_sendsTheMessageNow() {
        viewModel.sendNow(.mock(id: "scheduled"))

        XCTAssertEqual(controller.sendScheduledMessageNow_id, "scheduled")

        controller.sendScheduledMessageNow_completion?(nil)

        XCTAssertNil(viewModel.snackBarText)
    }

    func test_sendNow_whenTheQuotedMessageIsDeleted_showsASnackBar() {
        viewModel.sendNow(.mock())

        controller.sendScheduledMessageNow_completion?(ClientError.ScheduledMessageQuotesADeletedMessage())

        XCTAssertEqual(viewModel.snackBarText, L10n.ScheduledMessages.Item.quoteDeleted)
        XCTAssertFalse(viewModel.snackBarShowsSpinner)
    }

    func test_sendNow_whenTheMessageIsGone_showsNothing() {
        viewModel.sendNow(.mock(id: "scheduled"))

        controller.sendScheduledMessageNow_completion?(ClientError.ScheduledMessageDoesNotExist(id: "scheduled"))

        XCTAssertNil(viewModel.snackBarText)
    }

    func test_sendNow_whenItFails_showsTheGenericError() {
        viewModel.sendNow(.mock())

        controller.sendScheduledMessageNow_completion?(ClientError())

        XCTAssertEqual(viewModel.snackBarText, L10n.Alert.Error.title)
    }

    // MARK: - Delete

    func test_delete_asksForConfirmationNamingTheRecipient() {
        viewModel.delete(.mock(channelName: "Maya Ross"))

        XCTAssertTrue(viewModel.deleteConfirmationShown)
        XCTAssertEqual(viewModel.deleteConfirmation.title, L10n.ScheduledMessages.DeleteConfirmation.title)
        XCTAssertEqual(viewModel.deleteConfirmation.message, L10n.ScheduledMessages.DeleteConfirmation.message("Maya Ross"))
        XCTAssertEqual(viewModel.deleteConfirmation.buttonTitle, L10n.Alert.Actions.delete)
        XCTAssertEqual(controller.deleteScheduledMessage_callCount, 0)
    }

    func test_delete_asksForConfirmationWhenTheSheetIsDismissed() {
        let scheduledMessage = ScheduledMessage.mock()
        viewModel.scheduledMessageTapped(scheduledMessage)

        viewModel.delete(scheduledMessage)

        XCTAssertNil(viewModel.selectedScheduledMessage)
        XCTAssertFalse(viewModel.deleteConfirmationShown)

        viewModel.actionsSheetDismissed()

        XCTAssertTrue(viewModel.deleteConfirmationShown)
    }

    func test_deleteConfirmed_deletesTheMessage() {
        viewModel.delete(.mock(id: "scheduled"))

        viewModel.deleteConfirmed()

        XCTAssertEqual(controller.deleteScheduledMessage_id, "scheduled")

        controller.deleteScheduledMessage_completion?(nil)

        XCTAssertNil(viewModel.snackBarText)
    }

    func test_delete_whenTheServerIsSendingTheMessage_showsTheStillSendingSnackBar() {
        let apiError = APIError(code: 121, message: "scheduled message is being sent", statusCode: 409)
        apiError.exceptionFields = ["reason": "scheduled_message_sending"]

        delete(.mock(), completingWith: ClientError(with: apiError))

        XCTAssertEqual(viewModel.snackBarText, L10n.ScheduledMessages.Snackbar.stillSending)
        XCTAssertTrue(viewModel.snackBarShowsSpinner)
    }

    func test_delete_whenTheMessageWasAlreadySent_showsTheAlreadySentSnackBar() {
        delete(.mock(id: "scheduled"), completingWith: ClientError.ScheduledMessageDoesNotExist(id: "scheduled"))

        XCTAssertEqual(viewModel.snackBarText, L10n.ScheduledMessages.Snackbar.alreadySent)
        XCTAssertFalse(viewModel.snackBarShowsSpinner)
    }

    func test_delete_whenAFailedMessageIsGone_showsNothing() {
        let failed = ScheduledMessage.mock(id: "scheduled", status: .failed, failure: .serverFailedPublishing(.init(reason: .banned)))

        delete(failed, completingWith: ClientError.ScheduledMessageDoesNotExist(id: "scheduled"))

        XCTAssertNil(viewModel.snackBarText)
    }

    func test_delete_whenItFails_showsTheGenericError() {
        delete(.mock(), completingWith: ClientError())

        XCTAssertEqual(viewModel.snackBarText, L10n.Alert.Error.title)
        XCTAssertFalse(viewModel.snackBarShowsSpinner)
    }

    // MARK: - Reschedule

    func test_reschedule_opensTheSheetWhenTheActionsSheetIsDismissed() {
        let scheduledMessage = ScheduledMessage.mock(id: "scheduled")
        viewModel.scheduledMessageTapped(scheduledMessage)

        viewModel.reschedule(scheduledMessage)

        XCTAssertNil(viewModel.rescheduledScheduledMessage)

        viewModel.actionsSheetDismissed()

        XCTAssertEqual(viewModel.rescheduledScheduledMessage?.id, "scheduled")
        XCTAssertNil(viewModel.rescheduleUsage)
    }

    func test_canReschedule_needsTheChannelStoredLocally() {
        let cid = ChannelId.unique
        let scheduledMessage = ScheduledMessage.mock(cid: cid)

        XCTAssertFalse(viewModel.canReschedule(scheduledMessage))

        viewModel.channels = [cid: .mock(cid: cid)]

        XCTAssertTrue(viewModel.canReschedule(scheduledMessage))
    }

    func test_reschedulePreview_showsTheScheduledTimeAndTheText() {
        let scheduledAt = Date(timeIntervalSince1970: 1_800_000_000)
        let scheduledMessage = ScheduledMessage.mock(message: .mock(text: "Booking confirmed"), scheduledAt: scheduledAt)

        let preview = viewModel.reschedulePreview(for: scheduledMessage)

        let date = streamChat?.utils.scheduledMessagesConfig.dateFormatter.format(scheduledAt) ?? ""
        XCTAssertEqual(preview.title, L10n.Composer.ScheduledMessagesBanner.scheduledFor(date))
        XCTAssertEqual(preview.subtitle, "Booking confirmed")
    }

    func test_rescheduleConfirmed_withTheSameTime_closesTheSheetWithoutRescheduling() {
        let scheduledAt = Date(timeIntervalSince1970: 1_800_000_000)
        viewModel.rescheduledScheduledMessage = .mock(scheduledAt: scheduledAt)
        var completionError: Error? = ClientError()

        viewModel.rescheduleConfirmed(at: scheduledAt) { completionError = $0 }

        XCTAssertNil(completionError)
        XCTAssertNil(viewModel.rescheduledScheduledMessage)
        XCTAssertEqual(controller.rescheduleMessage_callCount, 0)
    }

    func test_rescheduleConfirmed_withANewTime_reschedulesAndClosesTheSheet() {
        let newDate = Date(timeIntervalSince1970: 1_800_003_600)
        viewModel.rescheduledScheduledMessage = .mock(id: "scheduled", scheduledAt: Date(timeIntervalSince1970: 1_800_000_000))
        var completed = false

        viewModel.rescheduleConfirmed(at: newDate) { _ in completed = true }

        XCTAssertEqual(controller.rescheduleMessage_id, "scheduled")
        XCTAssertEqual(controller.rescheduleMessage_scheduledAt, newDate)
        XCTAssertNotNil(viewModel.rescheduledScheduledMessage)

        controller.rescheduleMessage_completion?(.success(.mock(id: "scheduled", scheduledAt: newDate)))

        XCTAssertTrue(completed)
        XCTAssertNil(viewModel.rescheduledScheduledMessage)
    }

    func test_rescheduleConfirmed_ofAFailedMessageWithTheSameTime_reschedules() {
        let scheduledAt = Date(timeIntervalSince1970: 1_800_000_000)
        viewModel.rescheduledScheduledMessage = .mock(id: "failed", scheduledAt: scheduledAt, status: .failed)

        viewModel.rescheduleConfirmed(at: scheduledAt) { _ in }

        XCTAssertEqual(controller.rescheduleMessage_id, "failed")
    }

    func test_rescheduleConfirmed_whenItFails_keepsTheSheetOpenAndReturnsTheError() {
        viewModel.rescheduledScheduledMessage = .mock(id: "scheduled", scheduledAt: Date(timeIntervalSince1970: 1_800_000_000))
        var completionError: Error?

        viewModel.rescheduleConfirmed(at: Date(timeIntervalSince1970: 1_800_003_600)) { completionError = $0 }
        controller.rescheduleMessage_completion?(.failure(ClientError.ScheduledMessageQuotesADeletedMessage()))

        XCTAssertTrue(completionError is ClientError.ScheduledMessageQuotesADeletedMessage)
        XCTAssertEqual(viewModel.rescheduledScheduledMessage?.id, "scheduled")
    }

    func test_rescheduledScheduledMessage_whenTheMessageStartsSending_isCleared() {
        load([.mock(id: "scheduled")])
        viewModel.rescheduledScheduledMessage = viewModel.scheduledMessages[0]

        controller.scheduledMessages_mock = [.mock(id: "scheduled", status: .sending)]
        viewModel.controller(controller, didChangeScheduledMessages: [])

        XCTAssertNil(viewModel.rescheduledScheduledMessage)
    }

    func test_rescheduledScheduledMessage_whenTheMessageIsGone_isCleared() {
        load([.mock(id: "scheduled"), .mock(id: "other")])
        viewModel.rescheduledScheduledMessage = viewModel.scheduledMessages[0]

        controller.scheduledMessages_mock = [.mock(id: "other")]
        viewModel.controller(controller, didChangeScheduledMessages: [])

        XCTAssertNil(viewModel.rescheduledScheduledMessage)
    }

    // MARK: - Edit

    func test_edit_opensTheComposerWhenTheActionsSheetIsDismissed() {
        let cid = ChannelId.unique
        let scheduledMessage = ScheduledMessage.mock(id: "scheduled", cid: cid)
        viewModel.scheduledMessageTapped(scheduledMessage)

        viewModel.edit(scheduledMessage)

        XCTAssertNil(viewModel.editedScheduledMessage)

        viewModel.actionsSheetDismissed()

        XCTAssertEqual(viewModel.editedScheduledMessage?.id, "scheduled")
        XCTAssertEqual(viewModel.editedScheduledMessageChannelController?.cid, cid)
        XCTAssertNil(viewModel.editedScheduledMessageThreadController)
    }

    func test_edit_ofAReply_usesTheControllerOfTheThread() {
        let cid = ChannelId.unique
        let scheduledMessage = ScheduledMessage.mock(cid: cid, message: .mock(parentMessageId: "parent"))

        viewModel.edit(scheduledMessage)

        XCTAssertEqual(viewModel.editedScheduledMessageChannelController?.cid, cid)
        XCTAssertEqual(viewModel.editedScheduledMessageThreadController?.cid, cid)
        XCTAssertEqual(viewModel.editedScheduledMessageThreadController?.messageId, "parent")
    }

    func test_canEdit_needsTheChannelStoredLocally() {
        let cid = ChannelId.unique
        let scheduledMessage = ScheduledMessage.mock(cid: cid)

        XCTAssertFalse(viewModel.canEdit(scheduledMessage))

        viewModel.channels = [cid: .mock(cid: cid)]

        XCTAssertTrue(viewModel.canEdit(scheduledMessage))
    }

    // MARK: - Copy text

    func test_copyText_copiesTheTextOfTheMessage() {
        // Reading the pasteboard waits for the paste permission in tests, so only the change is checked.
        let changeCount = UIPasteboard.general.changeCount

        viewModel.copyText(of: .mock(message: .mock(text: "Booking confirmed")))

        XCTAssertGreaterThan(UIPasteboard.general.changeCount, changeCount)
    }

    // MARK: - Helpers

    /// Finishes loading with the scheduled messages on a single page.
    private func load(_ scheduledMessages: [ScheduledMessage]) {
        controller.scheduledMessages_mock = scheduledMessages
        controller.hasLoadedAllScheduledMessages_mock = true
        viewModel.viewDidAppear()
        controller.synchronize_completion?(nil)
    }

    private func delete(_ scheduledMessage: ScheduledMessage, completingWith error: Error) {
        viewModel.delete(scheduledMessage)
        viewModel.deleteConfirmed()
        controller.deleteScheduledMessage_completion?(error)
    }
}
