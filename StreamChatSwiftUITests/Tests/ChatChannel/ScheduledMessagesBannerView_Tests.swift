//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatCommonUI
@testable import StreamChatSwiftUI
import StreamSwiftTestHelpers
import SwiftUI
import XCTest

@MainActor final class ScheduledMessagesBannerView_Tests: StreamChatTestCase {
    override func setUp() {
        super.setUp()
        streamChat?.utils.scheduledMessagesConfig.dateFormatter = FixedDateFormatter()
    }

    func test_scheduledMessagesBannerView_single() {
        AssertSnapshot(makeView(.single(scheduledAt: Date())), size: size)
    }

    func test_scheduledMessagesBannerView_multiple() {
        AssertSnapshot(makeView(.multiple(count: 3)), size: size)
    }

    func test_scheduledMessagesBannerView_limitReached() {
        AssertSnapshot(makeView(.limitReached(count: 10, limit: 10)), size: size)
    }

    func test_scheduledMessagesBannerView_failed() {
        AssertSnapshot(makeView(.failed(count: 1)), size: size)
    }

    func test_scheduledMessagesBannerState_linksToAllMessagesWhenThereAreSeveral() {
        XCTAssertEqual(ScheduledMessagesBannerState.single(scheduledAt: Date()).linkText, "View")
        XCTAssertEqual(ScheduledMessagesBannerState.failed(count: 1).linkText, "View")
        XCTAssertEqual(ScheduledMessagesBannerState.failed(count: 2).linkText, "View all")
        XCTAssertEqual(ScheduledMessagesBannerState.multiple(count: 2).linkText, "View all")
        XCTAssertEqual(ScheduledMessagesBannerState.limitReached(count: 10, limit: 10).linkText, "View all")
    }

    func test_scheduledMessagesBannerState_text() {
        XCTAssertEqual(ScheduledMessagesBannerState.single(scheduledAt: Date()).text, "Scheduled for Fri, Oct 23 at 09:00")
        XCTAssertEqual(ScheduledMessagesBannerState.multiple(count: 3).text, "3 scheduled messages")
        XCTAssertEqual(ScheduledMessagesBannerState.limitReached(count: 10, limit: 10).text, "10 of 10 scheduled messages")
        XCTAssertEqual(ScheduledMessagesBannerState.failed(count: 2).text, "2 failed to send")
    }

    // MARK: - Helpers

    private let size = CGSize(width: 375, height: 100)

    private func makeView(_ state: ScheduledMessagesBannerState) -> some View {
        ScheduledMessagesBannerView(state: state, onView: {})
            .padding()
            .frame(width: size.width)
    }
}

private struct FixedDateFormatter: ScheduledMessageDateFormatter {
    func format(_ date: Date) -> String {
        "Fri, Oct 23 at 09:00"
    }

    func formatAbsolute(_ date: Date) -> String {
        format(date)
    }

    func formatTimeZone(_ timeZone: TimeZone) -> String {
        "GMT"
    }
}
