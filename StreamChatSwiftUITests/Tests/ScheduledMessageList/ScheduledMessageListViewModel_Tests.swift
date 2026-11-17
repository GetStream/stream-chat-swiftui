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
}
