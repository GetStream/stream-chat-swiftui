//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatCommonUI
@testable import StreamChatSwiftUI
@testable import StreamChatTestTools
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

@MainActor final class ScheduledMessageListView_Tests: StreamChatTestCase {
    private var controller: ScheduledMessageListController_Mock!
    private var viewModel: ScheduledMessageListViewModel!

    override func setUp() {
        super.setUp()
        streamChat?.utils.scheduledMessagesConfig.dateFormatter = FixedScheduledMessageDateFormatter()
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

    // MARK: - States

    func test_scheduledMessageListView_withScheduledMessages() {
        let mayaRoss = directMessageChannel(with: "Maya Ross")
        let sdkDesign = groupChannel(name: "SDK Design")
        // The controller's order: pending messages first, then failed ones.
        load(
            [
                scheduledMessage("Agreed, let's go with that one.", channelName: "Product Leadership", day: 23, hour: 9),
                scheduledMessage("Heads up: the launch moved to Monday", channel: mayaRoss, day: 23, hour: 9),
                scheduledMessage("", channel: sdkDesign, day: 23, hour: 13, attachments: [imageAttachment()]),
                scheduledMessage("Kickoff notes are in the doc. Please read them.", channelName: "Growth Squad", day: 26, hour: 9),
                scheduledMessage(
                    "Can you review the venue shortlist before lunch?",
                    channel: mayaRoss,
                    day: 21,
                    hour: 8,
                    status: .failed,
                    failure: .localDeviceFailedScheduling(.init(reason: .requestFailed))
                ),
                scheduledMessage(
                    "Booking confirmed for the 14th. See you there",
                    channelName: "Amsterdam Office",
                    day: 22,
                    hour: 9,
                    status: .failed,
                    failure: .serverFailedPublishing(.init(reason: .channelDeleted))
                )
            ]
        )

        AssertSnapshot(makeView(), size: defaultScreenSize)
    }

    func test_scheduledMessageListView_loading() {
        viewModel.viewDidAppear()

        AssertSnapshot(makeView(), size: defaultScreenSize)
    }

    func test_scheduledMessageListView_loadError() {
        viewModel.viewDidAppear()
        controller.synchronize_completion?(ClientError())

        AssertSnapshot(makeView(), size: defaultScreenSize)
    }

    func test_scheduledMessageListView_empty() {
        load([])

        AssertSnapshot(makeView(), size: defaultScreenSize)
    }

    // MARK: - Rows

    func test_scheduledMessageListView_inProgress() {
        load([
            scheduledMessage("Heads up: the launch moved to Monday", channelName: "Maya Ross", day: 23, hour: 9, status: .sending),
            scheduledMessage(
                "",
                channelName: "SDK Design",
                day: 23,
                hour: 13,
                status: .preparingToSchedule,
                attachments: [imageAttachment(localState: .uploading(progress: 0.4))]
            ),
            // Waits for the connection, with nothing to upload.
            scheduledMessage("Kickoff notes are in the doc.", channelName: "Growth Squad", day: 26, hour: 9, status: .preparingToSchedule)
        ])

        AssertSnapshot(makeView(), size: defaultScreenSize)
    }

    func test_scheduledMessageListView_failedReasons() {
        let failures: [ScheduledMessageFailure?] = [
            .serverFailedPublishing(.init(reason: .internalError)),
            .localDeviceFailedScheduling(.init(reason: .attachmentUploadFailed)),
            .serverFailedPublishing(.init(reason: .pendingNotSupported)),
            .serverRejectedScheduling(.init(reason: .scheduledLimitChannel, message: "Limit reached")),
            .serverFailedPublishing(.init(reason: .banned)),
            nil
        ]
        load(failures.enumerated().map { index, failure in
            scheduledMessage(
                "We shipped the fix for the login issue.",
                channelName: "#support",
                day: 21,
                hour: 6 + index,
                status: .failed,
                failure: failure
            )
        })

        AssertSnapshot(makeView(), size: defaultScreenSize)
    }

    func test_scheduledMessageListView_attachments() {
        load([
            scheduledMessage("Venue options", channelName: "SDK Design", day: 23, hour: 13, attachments: [fileAttachment("Venues.pdf")]),
            scheduledMessage("", channelName: "Product Leadership", day: 23, hour: 15, attachments: [fileAttachment("Budget-2027.pdf")]),
            scheduledMessage(
                "",
                channelName: "Growth Squad",
                day: 26,
                hour: 9,
                attachments: [ChatMessageVoiceRecordingAttachment.mock(id: .unique, duration: 8).asAnyAttachment]
            ),
            scheduledMessage("", channelName: "Maya Ross", day: 26, hour: 10, attachments: [imageAttachment(), imageAttachment()])
        ])

        AssertSnapshot(makeView(), size: defaultScreenSize)
    }

    func test_scheduledMessageListView_threadReplyAndQuote() {
        let quotedMessage = ChatMessage.mock(text: "Lunch?", author: .mock(id: .unique, name: "Alex Ross"))
        load([
            scheduledMessage("@Maya Ross, can you take a look?", channelName: "SDK Design", day: 23, hour: 9, parentMessageId: .unique),
            scheduledMessage("Looks good to me", channelName: "Maya Ross", day: 23, hour: 13, quotedMessage: quotedMessage),
            scheduledMessage(
                "",
                channelName: "Amsterdam Office",
                day: 26,
                hour: 9,
                attachments: [imageAttachment()],
                parentMessageId: .unique
            )
        ])

        AssertSnapshot(makeView(), size: defaultScreenSize)
    }

    // MARK: - Search

    func test_scheduledMessageListView_search_matchesTextChannelNameAndAttachmentName() {
        let mayaRoss = directMessageChannel(with: "Maya Ross")
        load(
            [
                scheduledMessage("Hello", channel: mayaRoss, day: 21, hour: 8),
                scheduledMessage("Ask Maya about the venue", channelName: "SDK Design", day: 22, hour: 9),
                scheduledMessage("", channelName: "Growth Squad", day: 23, hour: 9, attachments: [fileAttachment("Maya-notes.pdf")]),
                scheduledMessage("Kickoff notes are in the doc.", channelName: "Product Leadership", day: 26, hour: 9)
            ]
        )
        viewModel.searchText = "maya"

        AssertSnapshot(makeView(), size: defaultScreenSize)
    }

    func test_scheduledMessageListView_search_withoutMatches() {
        load([scheduledMessage("Hello", channelName: "SDK Design", day: 21, hour: 8)])
        viewModel.searchText = "venue"

        AssertSnapshot(makeView(), size: defaultScreenSize)
    }

    func test_scheduledMessageListView_quoteDeleted() {
        load([
            scheduledMessage(
                "Heads up: the launch moved to Monday",
                channelName: "Maya Ross",
                day: 23,
                hour: 9,
                quotedMessage: .mock(text: "When is the launch?", author: .mock(id: .unique, name: "Maya Ross"), deletedAt: Date())
            ),
            scheduledMessage("Kickoff notes are in the doc.", channelName: "Growth Squad", day: 26, hour: 9)
        ])

        AssertSnapshot(makeView(), size: defaultScreenSize)
    }

    // MARK: - Snack bars

    func test_scheduledMessageListView_stillSendingSnackBar() {
        let sending = scheduledMessage("Heads up: the launch moved to Monday", channelName: "Maya Ross", day: 23, hour: 9, status: .sending)
        load([sending])

        viewModel.scheduledMessageTapped(sending)

        AssertSnapshot(makeView(), size: defaultScreenSize)
    }

    // MARK: - Helpers

    private func makeView() -> some View {
        ScheduledMessageListView(viewModel: self.viewModel)
            .applyDefaultSize()
    }

    private func load(_ scheduledMessages: [ScheduledMessage]) {
        controller.scheduledMessages_mock = scheduledMessages
        controller.hasLoadedAllScheduledMessages_mock = true
        viewModel.viewDidAppear()
        controller.synchronize_completion?(nil)
    }

    private func scheduledMessage(
        _ text: String,
        channel: Recipient? = nil,
        channelName: String? = nil,
        day: Int,
        hour: Int,
        status: ScheduledMessageStatus = .scheduled,
        failure: ScheduledMessageFailure? = nil,
        attachments: [AnyChatMessageAttachment] = [],
        parentMessageId: MessageId? = nil,
        quotedMessage: ChatMessage? = nil
    ) -> ScheduledMessage {
        .mock(
            id: "\(day)-\(hour)-\(text)-\(channelName ?? "")",
            cid: channel?.cid ?? .unique,
            channelName: channel?.name ?? channelName,
            channelMemberCount: channel?.memberCount ?? 0,
            channelMembers: channel?.members ?? [],
            message: .mock(
                text: text,
                parentMessageId: parentMessageId,
                quotedMessage: quotedMessage,
                attachments: attachments,
                isSentByCurrentUser: true
            ),
            scheduledAt: DateComponents(
                calendar: Calendar(identifier: .gregorian),
                timeZone: TimeZone(secondsFromGMT: 0),
                year: 2026,
                month: 10,
                day: day,
                hour: hour
            ).date!,
            status: status,
            failure: failure
        )
    }

    private func directMessageChannel(with name: String) -> Recipient {
        Recipient(
            cid: ChannelId(type: .messaging, id: "!members-\(String.unique)"),
            name: nil,
            memberCount: 2,
            members: [.mock(id: chatClient.currentUserId!), .mock(id: .unique, name: name)]
        )
    }

    private func groupChannel(name: String) -> Recipient {
        Recipient(
            cid: .unique,
            name: name,
            memberCount: 12,
            members: [.mock(id: chatClient.currentUserId!), .mock(id: .unique, name: "Emma Chen"), .mock(id: .unique, name: "Noah Kim")]
        )
    }

    private func imageAttachment(localState: LocalAttachmentState? = nil) -> AnyChatMessageAttachment {
        ChatMessageImageAttachment.mock(id: .unique, localState: localState).asAnyAttachment
    }

    private func fileAttachment(_ title: String) -> AnyChatMessageAttachment {
        ChatMessageFileAttachment.mock(id: .unique, title: title).asAnyAttachment
    }
}

private struct Recipient {
    let cid: ChannelId
    let name: String?
    let memberCount: Int
    let members: [ChatChannelMember]
}

// Formats dates without looking at the current date, so the snapshots don't change over time.
private struct FixedScheduledMessageDateFormatter: ScheduledMessageDateFormatter {
    func format(_ date: Date) -> String {
        formatAbsolute(date)
    }

    func formatAbsolute(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "EEE, MMM d 'at' HH:mm"
        return formatter.string(from: date)
    }

    func formatTimeZone(_ timeZone: TimeZone) -> String {
        "GMT"
    }
}
