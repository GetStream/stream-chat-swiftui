//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

@MainActor final class ScheduledMessageActionsSheetView_Tests: StreamChatTestCase {
    private var performedActions = [String]()

    override func tearDown() {
        performedActions = []
        super.tearDown()
    }

    // MARK: - Snapshots

    func test_scheduledMessageActionsSheetView_scheduled() {
        AssertSnapshot(makeView(for: .mock(status: .scheduled)), size: size)
    }

    func test_scheduledMessageActionsSheetView_failed() {
        AssertSnapshot(makeView(for: failedMessage()), size: size)
    }

    func test_scheduledMessageActionsSheetView_channelDeleted() {
        AssertSnapshot(makeView(for: channelDeletedMessage(text: "Booking confirmed for the 14th. See you there")), size: size)
    }

    // MARK: - Default actions

    func test_defaultActions_forAScheduledMessage_areRescheduleSendNowAndDelete() {
        let actions = defaultActions(for: .mock(status: .scheduled))

        XCTAssertEqual(
            actions.map(\.id),
            [ScheduledMessageListActionId.reschedule, ScheduledMessageListActionId.sendNow, ScheduledMessageListActionId.delete]
        )
        XCTAssertEqual(actions.map(\.isDestructive), [false, false, true])
    }

    func test_defaultActions_forAMessageWaitingToBeScheduled_areRescheduleSendNowAndDelete() {
        let actions = defaultActions(for: .mock(status: .preparingToSchedule))

        XCTAssertEqual(
            actions.map(\.id),
            [ScheduledMessageListActionId.reschedule, ScheduledMessageListActionId.sendNow, ScheduledMessageListActionId.delete]
        )
    }

    func test_defaultActions_forAFailedMessage_areRescheduleAndDelete() {
        XCTAssertEqual(
            defaultActions(for: failedMessage()).map(\.id),
            [ScheduledMessageListActionId.reschedule, ScheduledMessageListActionId.delete]
        )
    }

    func test_defaultActions_forAMessageTheServerFailedToSend_areRescheduleAndDelete() {
        let failed = ScheduledMessage.mock(status: .failed, failure: .serverFailedPublishing(.init(reason: .banned)))

        XCTAssertEqual(
            defaultActions(for: failed).map(\.id),
            [ScheduledMessageListActionId.reschedule, ScheduledMessageListActionId.delete]
        )
    }

    func test_defaultActions_withoutReschedule_leaveItOut() {
        let scheduled = defaultActions(for: .mock(status: .scheduled), canReschedule: false)
        let failed = defaultActions(for: failedMessage(), canReschedule: false)

        XCTAssertEqual(scheduled.map(\.id), [ScheduledMessageListActionId.sendNow, ScheduledMessageListActionId.delete])
        XCTAssertEqual(failed.map(\.id), [ScheduledMessageListActionId.delete])
    }

    func test_defaultActions_forAMessageQuotingADeletedMessage_isDelete() {
        let quotesDeleted = ScheduledMessage.mock(message: .mock(quotedMessage: .mock(deletedAt: Date())))

        XCTAssertEqual(defaultActions(for: quotesDeleted).map(\.id), [ScheduledMessageListActionId.delete])
    }

    func test_defaultActions_forAMessageOfADeletedChannel_areCopyTextAndDelete() {
        let actions = defaultActions(for: channelDeletedMessage(text: "Booking confirmed"))

        XCTAssertEqual(actions.map(\.id), [ScheduledMessageListActionId.copyText, ScheduledMessageListActionId.delete])
    }

    func test_defaultActions_forAMessageOfADeletedChannelWithoutText_isDelete() {
        let actions = defaultActions(for: channelDeletedMessage(text: ""))

        XCTAssertEqual(actions.map(\.id), [ScheduledMessageListActionId.delete])
    }

    func test_defaultActions_callTheCallbacksOfTheOptions() {
        defaultActions(for: .mock(status: .scheduled)).forEach { $0.action() }
        defaultActions(for: channelDeletedMessage(text: "Booking confirmed")).first?.action()

        XCTAssertEqual(performedActions, ["reschedule", "sendNow", "delete", "copyText"])
    }

    // MARK: - Helpers

    private var size: CGSize {
        CGSize(width: defaultScreenSize.width, height: 200)
    }

    private func makeView(for scheduledMessage: ScheduledMessage) -> some View {
        ScheduledMessageActionsSheetView(actions: defaultActions(for: scheduledMessage), onDismiss: {})
            .frame(width: size.width, height: size.height)
    }

    private func defaultActions(
        for scheduledMessage: ScheduledMessage,
        canReschedule: Bool = true
    ) -> [ScheduledMessageListAction] {
        var onReschedule: (@MainActor () -> Void)?
        if canReschedule {
            onReschedule = { [weak self] in self?.performedActions.append("reschedule") }
        }
        return ScheduledMessageListAction.defaultActions(
            for: SupportedScheduledMessageListActionsOptions(
                scheduledMessage: scheduledMessage,
                onCopyText: { [weak self] in self?.performedActions.append("copyText") },
                onDelete: { [weak self] in self?.performedActions.append("delete") },
                onReschedule: onReschedule,
                onSendNow: { [weak self] in self?.performedActions.append("sendNow") }
            )
        )
    }

    private func failedMessage() -> ScheduledMessage {
        .mock(status: .failed, failure: .localDeviceFailedScheduling(.init(reason: .requestFailed)))
    }

    private func channelDeletedMessage(text: String) -> ScheduledMessage {
        .mock(
            message: .mock(text: text),
            status: .failed,
            failure: .serverFailedPublishing(.init(reason: .channelDeleted))
        )
    }
}
